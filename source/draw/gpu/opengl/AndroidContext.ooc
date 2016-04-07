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
import OpenGLContext, GraphicBuffer, GraphicBufferYuv420Semiplanar, EGLRgba, OpenGLRgba, OpenGLPacked, OpenGLMonochrome, OpenGLUv, OpenGLMap, OpenGLPromise

version(!gpuOff) {
AndroidContext: class extends OpenGLContext {
	_unpackRgbaToMonochrome := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToMonochrome.frag"), this)
	_unpackRgbaToUv := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUv.frag"), this)
	_unpackRgbaToUvPadded := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUvPadded.frag"), this)
	_packers := RecycleBin<EGLRgba> new(32, func (image: EGLRgba) { image free() })
	init: func (other: This = null) { super(other) }
	free: override func {
		this _backend makeCurrent()
		(this _unpackRgbaToMonochrome, this _unpackRgbaToUv, this _unpackRgbaToUvPadded, this _packers) free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		result: GpuImage
		version (optiGraphicbufferupload) {
			if (rasterImage instanceOf(GraphicBufferYuv420Semiplanar)) {
				graphicBufferImage := rasterImage as GraphicBufferYuv420Semiplanar
				rgba := graphicBufferImage toRgba(this)
				result = this unpackRgbaToYuv420Semiplanar(rgba, rasterImage size, graphicBufferImage uvPadding % graphicBufferImage stride)
				rgba referenceCount decrease()
			}
			else
				result = super(rasterImage)
		}
		else {
			result = super(rasterImage)
		}
		result
	}
	recyclePacker: func (packer: EGLRgba) { this _packers add(packer) }
	getPacker: func (size: IntVector2D) -> EGLRgba {
		result := this _packers search(|image| image size == size) ?? EGLRgba new(size, this)
		result
	}
	toBuffer: func (source: GpuImage, packMap: Map) -> (ByteBuffer, OpenGLPromise) {
		channels := (source as OpenGLPacked) channels
		packSize := IntVector2D new(source size x / (4 / channels), source size y)
		gpuRgba := this getPacker(packSize)
		this packToRgba(source, gpuRgba, IntBox2D new(gpuRgba size))
		promise := OpenGLPromise new(this)
		promise sync()
		eglImage := gpuRgba as EGLRgba
		sourcePointer := eglImage buffer lock(GraphicBufferUsage ReadOften) as Byte*
		length := channels * eglImage size area
		recover := func (b: ByteBuffer) -> Bool {
			eglImage buffer unlock()
			this recyclePacker(gpuRgba)
			false
		}
		(ByteBuffer new(sourcePointer, length, recover), promise)
	}
	toRaster: func ~monochrome (source: OpenGLMonochrome) -> RasterImage {
		(buffer, promise) := this toBuffer(source, this _packMonochrome)
		promise free()
		RasterMonochrome new(buffer, source size)
	}
	toRaster: func ~uv (source: OpenGLUv) -> RasterImage {
		(buffer, promise) := this toBuffer(source, this _packUv)
		promise free()
		RasterUv new(buffer, source size)
	}
	toRaster: override func (source: GpuImage) -> RasterImage {
		match (source) {
			case (image : OpenGLMonochrome) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
			case (image : OpenGLUv) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
			case => super(source)
		}
	}
	toRaster: override func ~target (source: GpuImage, target: RasterImage) -> Promise {
		result: Promise
		if (target instanceOf(GraphicBufferYuv420Semiplanar) && source instanceOf(GpuYuv420Semiplanar)) {
			targetImage := target as GraphicBufferYuv420Semiplanar
			sourceImage := source as GpuYuv420Semiplanar
			targetImageRgba := targetImage toRgba(this)
			targetWidth := sourceImage size x / 4
			padding := targetImage uvPadding % targetImage stride
			this packToRgba(sourceImage y, targetImageRgba, IntBox2D new(0, 0, targetWidth, targetImage y size y), padding)
			this packToRgba(sourceImage uv, targetImageRgba, IntBox2D new(0, targetImageRgba size y - targetImage uv size y, targetWidth, targetImage uv size y), padding)
			result = OpenGLPromise new(this)
			(result as OpenGLPromise) sync()
			targetImageRgba referenceCount decrease()
		} else
			result = super(source, target)
		result
	}
	toRasterAsync: func ~monochrome (gpuImage: OpenGLMonochrome) -> ToRasterFuture {
		(buffer, promise) := this toBuffer(gpuImage, this _packMonochrome)
		_FenceToRasterFuture new(RasterMonochrome new(buffer, gpuImage size), promise)
	}
	toRasterAsync: func ~uv (gpuImage: OpenGLUv) -> ToRasterFuture {
		(buffer, promise) := this toBuffer(gpuImage, this _packUv)
		_FenceToRasterFuture new(RasterUv new(buffer, gpuImage size), promise)
	}
	toRasterAsync: override func (gpuImage: GpuImage) -> ToRasterFuture {
		result: ToRasterFuture
		aligned := this isAligned(gpuImage size x)
		if (aligned && gpuImage instanceOf(OpenGLMonochrome))
			result = this toRasterAsync(gpuImage as OpenGLMonochrome)
		else if (aligned && gpuImage instanceOf(OpenGLUv))
			result = this toRasterAsync(gpuImage as OpenGLUv)
		else
			result = super(gpuImage)
		result
	}
	unpackRgbaToYuv420Semiplanar: func (source: GpuImage, targetSize: IntVector2D, padding := 0) -> GpuYuv420Semiplanar {
		target := this createYuv420Semiplanar(targetSize) as GpuYuv420Semiplanar
		sourceSize := source size
		transform := FloatTransform3D createScaling(source transform a, -source transform e, 1.0f)
		yMap: Map = this _unpackRgbaToMonochrome
		uvMap: Map = this _unpackRgbaToUv
		if (padding > 0) {
			uvMap = this _unpackRgbaToUvPadded
			uvMap add("paddingOffset", padding as Float / (source size x * 4) as Float)
			uvMap add("rowUnit", 1.0f / sourceSize y)
		}
		This _unpack(source, target y, yMap, targetSize x, transform, targetSize x as Float / (4 * sourceSize x), targetSize y as Float / sourceSize y, 0.0f)
		uvSize := target uv size
		startY := (sourceSize y - uvSize y) as Float / sourceSize y
		This _unpack(source, target uv, uvMap, uvSize x, transform, (uvSize x as Float) / (2 * sourceSize x), 1.0f - startY, startY)
		target
	}
	alignWidth: override func (width: Int, align := AlignWidth Nearest) -> Int { GraphicBuffer alignWidth(width, align) }
	isAligned: override func (width: Int) -> Bool { GraphicBuffer isAligned(width) }
	_unpack: static func (source: GpuImage, target: GpuImage, map: Map, targetWidth: Int, transform: FloatTransform3D, scaleX: Float, scaleY: Float, startY: Float) {
		map add("texture0", source)
		map add("targetWidth", targetWidth)
		map add("transform", transform)
		map add("scaleX", scaleX)
		map add("scaleY", scaleY)
		map add("startY", startY)
		DrawState new(target) setMap(map) draw()
	}
}
}
