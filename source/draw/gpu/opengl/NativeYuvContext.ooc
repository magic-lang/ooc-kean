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
NativeYuvContext: class extends OpenGLContext {
	defaultMap ::= this _yuvShader as Map
	_yuvShader: OpenGLMapTransform
	_eglBin := RecycleBin<EGLYuv> new(100, |image| image _recyclable = false; image free())
	init: func (other: This = null) {
		super(other)
		this _yuvShader = OpenGLMapTransform new(slurp("shaders/yuv.frag"), this)
	}
	free: override func {
		this _backend makeCurrent()
		(this _eglBin, this _yuvShader) free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		match(rasterImage) {
			case (graphicBufferImage: GraphicBufferYuv420Semiplanar) => this createEGLYuv(graphicBufferImage)
			case => super(rasterImage)
		}
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
