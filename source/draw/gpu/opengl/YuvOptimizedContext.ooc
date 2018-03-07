/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
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
import OpenGLContext, GraphicBuffer, GraphicBufferYuv420Semiplanar, EGLYuv, OpenGLPacked, OpenGLMap, OpenGLPromise, OpenGLMonochrome, OpenGLUv
import backend/gles3/Gles3Debug

YuvOptimizedContext: class extends OpenGLContext {
	defaultMap ::= this _yuvShader as Map
	_yuvShader: OpenGLMapTransform
	_monochromeToYuv: OpenGLMapTransform
	_unpackY, _unpackUv: OpenGLMap
	_compositeYuvToNativeYuv: OpenGLMapTransform
	_yuvLineShader: OpenGLMap
	_eglBin := RecycleBin<EGLYuv> new(100, |image| image _recyclable = false; image free())
	init: func (other: This = null) {
		super(other)
		Debug error(!queryExtension("GL_EXT_YUV_target"), "RENDER_MODE_OPENGL_YUV_OPTIMIZED is not supported on this device")
		this _yuvShader = OpenGLMapTransform new(slurp("shaders/yuv.frag"), this)
		this _monochromeToYuv = OpenGLMapTransform new(slurp("shaders/monochromeToNativeYuv.frag"), this)
		this _yuvLineShader = OpenGLMap new(slurp("shaders/lines.vert"), slurp("shaders/colorToNativeYuv.frag"), this)
		this _unpackY = OpenGLMap new(slurp("shaders/unpackYuv.vert"), slurp("shaders/unpackYuvToMonochrome.frag"), this)
		this _unpackUv = OpenGLMap new(slurp("shaders/unpackYuv.vert"), slurp("shaders/unpackYuvToUv.frag"), this)
		this _compositeYuvToNativeYuv = OpenGLMapTransform new(slurp("shaders/packCompositeYuvToYuv.frag"), this)
	}
	free: override func {
		(this _eglBin, this _yuvShader, this _yuvLineShader, this _monochromeToYuv, this _unpackY, this _unpackUv, this _compositeYuvToNativeYuv) free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		match (rasterImage) {
			case (graphicBufferImage: GraphicBufferYuv420Semiplanar) => this createEGLYuv(graphicBufferImage)
			case => super(rasterImage)
		}
	}
	invalidateBuffers: override func { this _eglBin clear() }
	preregister: override func (image: Image) {
		if (image instanceOf(GraphicBufferYuv420Semiplanar))
			this createEGLYuv(image as GraphicBufferYuv420Semiplanar) free()
	}
	createEGLYuv: func (source: GraphicBufferYuv420Semiplanar) -> EGLYuv {
		this _eglBin search(|eglYuv| source buffer identifier == eglYuv identifier) ?? EGLYuv new(source buffer, this)
	}
	recycle: override func (image: OpenGLPacked) {
		match (image) {
			case eglYuv: EGLYuv =>
				eglYuv onRecycle()
				this _eglBin add(eglYuv)
			case => super(image)
		}
	}
	getDefaultShader: override func (input, output: Image) -> OpenGLMap {
		result: OpenGLMap
		if (input instanceOf(EGLYuv) && output instanceOf(EGLYuv))
			result = this _yuvShader
		else if ((input instanceOf(OpenGLMonochrome) || input instanceOf(RasterMonochrome)) && output instanceOf(EGLYuv))
			result = this _monochromeToYuv
		else if (input instanceOf(GpuYuv420Semiplanar) && output instanceOf(EGLYuv))
			result = this _compositeYuvToNativeYuv
		else if (input instanceOf(EGLYuv) && output instanceOf(OpenGLMonochrome))
			result = this _unpackY
		else if (input instanceOf(EGLYuv) && output instanceOf(OpenGLUv))
			result = this _unpackUv
		else
			result = super(input, output)
		result
	}
	getLineShader: override func -> OpenGLMap { this _yuvLineShader }
	unpackMonochrome: func (input: EGLYuv, target: OpenGLMonochrome) {
		this _unpackY add("texture0", input)
		DrawState new(target) setMap(this _unpackY) draw()
	}
}
