/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw-gpu
use collections
use draw
use geometry
use base
use concurrent
import OpenGLContext, GraphicBuffer, GraphicBufferYuv420Semiplanar, EGLYuv, OpenGLPacked, OpenGLMap, OpenGLPromise

version(!gpuOff) {
YuvExtensionContext: class extends OpenGLContext {
	_yuvShader: OpenGLMapTransform
	_unpackY: OpenGLMap
	_unpackUv: OpenGLMap
	_pack: OpenGLMap
	_eglBin := RecycleBin<EGLYuv> new(100, |image| image _recyclable = false; image free())
	init: func (other: This = null) {
		super(other)
		this _yuvShader = OpenGLMapTransform new(slurp("shaders/yuv.frag"), this)
		this _unpackY = OpenGLMap new(slurp("shaders/unpackYuv.vert"), slurp("shaders/unpackYuvToMonochrome.frag"), this)
		this _unpackUv = OpenGLMap new(slurp("shaders/unpackYuv.vert"), slurp("shaders/unpackYuvToUv.frag"), this)
		this _pack = OpenGLMap new(slurp("shaders/unpackYuv.vert"), slurp("shaders/packCompositeYuvToYuv.frag"), this)
	}
	free: override func {
		this _backend makeCurrent()
		(this _eglBin, this _yuvShader, this _unpackY, this _unpackUv, this _pack) free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		match(rasterImage) {
			case (graphicBufferImage: GraphicBufferYuv420Semiplanar) =>
				yuv := createEGLYuv(graphicBufferImage)
				result := this createYuv420Semiplanar(rasterImage size)
				this _unpack(yuv, result)
				yuv free()
				result
			case => super(rasterImage)
		}
	}
	toRaster: override func ~target (source: GpuImage, target: RasterImage) -> Promise {
		result: Promise
		if (target instanceOf(GraphicBufferYuv420Semiplanar) && source instanceOf(GpuYuv420Semiplanar)) {
			sourceImage := source as GpuYuv420Semiplanar
			targetYuv := createEGLYuv(target as GraphicBufferYuv420Semiplanar)
			this _pack add("y", sourceImage y)
			this _pack add("uv", sourceImage uv)
			DrawState new(targetYuv) setMap(this _pack) draw()
			result = OpenGLPromise new(this)
			(result as OpenGLPromise) sync()
			targetYuv free()
		} else
			result = super(source, target)
		result
	}
	_unpack: func (input: EGLYuv, target: GpuYuv420Semiplanar) {
		this _unpackY add("texture0", input)
		DrawState new(target y) setMap(this _unpackY) draw()
		this _unpackUv add("texture0", input)
		DrawState new(target uv) setMap(this _unpackUv) draw()
	}

	preallocate: override func (resolution: IntVector2D) { this _eglBin clear() }
	preregister: override func (image: Image) {
		if (image instanceOf(GraphicBufferYuv420Semiplanar))
			this createEGLYuv(image as GraphicBufferYuv420Semiplanar) free()
	}
	createEGLYuv: func (source: GraphicBufferYuv420Semiplanar) -> EGLYuv {
		this _eglBin search(|eglYuv| source buffer handle == eglYuv handle) ?? EGLYuv new(source buffer, this)
	}
	recycle: override func (image: OpenGLPacked) {
		match (image) {
			case eglYuv: EGLYuv => this _eglBin add(eglYuv)
			case => super(image)
		}
	}
}
}
