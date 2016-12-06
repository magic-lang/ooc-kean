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
	_unpackRgbaToMonochrome: OpenGLMap
	_unpackRgbaToUv: OpenGLMap
	_unpackRgbaToUvPadded: OpenGLMap
	_packers := RecycleBin<EGLRgba> new(32, |image| image _recyclable = false; image free())
	_eglBin := RecycleBin<EGLRgba> new(100, |image| image _recyclable = false; image free())
	init: func (other: This = null) {
		super(other)
		this _unpackRgbaToMonochrome = OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToMonochrome.frag"), this)
		this _unpackRgbaToUv = OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUv.frag"), this)
		this _unpackRgbaToUvPadded = OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUvPadded.frag"), this)
	}
	free: override func {
		this _eglBin free()
		(this _unpackRgbaToMonochrome, this _unpackRgbaToUv, this _unpackRgbaToUvPadded, this _packers) free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		match(rasterImage) {
			case (graphicBufferImage: GraphicBufferYuv420Semiplanar) =>
				rgba := this createEGLRgba(graphicBufferImage)
				result := this _unpackRgbaToYuv420Semiplanar(rgba, rasterImage size, graphicBufferImage uvPadding % graphicBufferImage stride)
				rgba free()
				result
			case => super(rasterImage)
		}
	}
	_recyclePacker: func (packer: EGLRgba) { this _packers add(packer) }
	_getPacker: func (size: IntVector2D) -> EGLRgba {
		result := this _packers search(|image| image size == size) ?? EGLRgba new(size, this)
		result
	}
	_toBuffer: func (source: GpuImage, packMap: Map) -> (ByteBuffer, OpenGLPromise) {
		channels := (source as OpenGLPacked) channels
		packSize := IntVector2D new(source size x / (4 / channels), source size y)
		gpuRgba := this _getPacker(packSize)
		this packToRgba(source, gpuRgba, IntBox2D new(gpuRgba size))
		promise := OpenGLPromise new(this)
		promise sync()
		eglImage := gpuRgba as EGLRgba
		sourcePointer := eglImage buffer lock(GraphicBufferUsage ReadOften) as Byte*
		length := channels * eglImage size area
		recover := func (b: ByteBuffer) -> Bool {
			eglImage buffer unlock()
			this _recyclePacker(gpuRgba)
			false
		}
		(ByteBuffer new(sourcePointer, length, recover), promise)
	}
	_toRaster: func ~monochrome (source: OpenGLMonochrome) -> RasterImage {
		(buffer, promise) := this _toBuffer(source, this _packMonochrome)
		promise free()
		RasterMonochrome new(buffer, source size)
	}
	_toRaster: func ~uv (source: OpenGLUv) -> RasterImage {
		(buffer, promise) := this _toBuffer(source, this _packUv)
		promise free()
		RasterUv new(buffer, source size)
	}
	toRaster: override func (source: GpuImage) -> RasterImage {
		match (source) {
			case (image: OpenGLMonochrome) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
			case (image: OpenGLUv) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
			case => super(source)
		}
	}
	toRaster: override func ~target (source: GpuImage, target: RasterImage) -> Promise {
		result: Promise
		if (target instanceOf(GraphicBufferYuv420Semiplanar) && source instanceOf(GpuYuv420Semiplanar)) {
			targetImage := target as GraphicBufferYuv420Semiplanar
			sourceImage := source as GpuYuv420Semiplanar
			targetImageRgba := this createEGLRgba(targetImage)
			targetWidth := sourceImage size x / 4
			padding := targetImage uvPadding % targetImage stride
			this packToRgba(sourceImage y, targetImageRgba, IntBox2D new(0, 0, targetWidth, targetImage y size y), padding)
			this packToRgba(sourceImage uv, targetImageRgba, IntBox2D new(0, targetImageRgba size y - targetImage uv size y, targetWidth, targetImage uv size y), padding)
			result = this createFence()
			targetImageRgba free()
		} else
			result = super(source, target)
		result
	}
	_toRasterAsync: func ~monochrome (gpuImage: OpenGLMonochrome) -> ToRasterFuture {
		(buffer, promise) := this _toBuffer(gpuImage, this _packMonochrome)
		_FenceToRasterFuture new(RasterMonochrome new(buffer, gpuImage size), promise)
	}
	_toRasterAsync: func ~uv (gpuImage: OpenGLUv) -> ToRasterFuture {
		(buffer, promise) := this _toBuffer(gpuImage, this _packUv)
		_FenceToRasterFuture new(RasterUv new(buffer, gpuImage size), promise)
	}
	toRasterAsync: override func (gpuImage: GpuImage) -> ToRasterFuture {
		result: ToRasterFuture
		aligned := this isAligned(gpuImage size x)
		if (aligned && gpuImage instanceOf(OpenGLMonochrome))
			result = this _toRasterAsync(gpuImage as OpenGLMonochrome)
		else if (aligned && gpuImage instanceOf(OpenGLUv))
			result = this _toRasterAsync(gpuImage as OpenGLUv)
		else
			result = super(gpuImage)
		result
	}
	_unpackRgbaToYuv420Semiplanar: func (source: GpuImage, targetSize: IntVector2D, padding := 0) -> GpuYuv420Semiplanar {
		target := this createYuv420Semiplanar(targetSize) as GpuYuv420Semiplanar
		sourceSize := source size
		transform := FloatTransform3D identity
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
	preallocate: override func (resolution: IntVector2D) { this _eglBin clear() }
	preregister: override func (image: Image) {
		if (image instanceOf(GraphicBufferYuv420Semiplanar))
			this createEGLRgba(image as GraphicBufferYuv420Semiplanar) free()
	}
	createEGLRgba: func (source: GraphicBufferYuv420Semiplanar) -> EGLRgba {
		result := this _eglBin search(|image| source buffer _handle == image buffer _handle)
		if (result == null) {
			padding := source uvOffset - source stride * source size y
			extraRows := padding align(source stride) / source stride
			height := source size y + source size y / 2 + extraRows
			width := source stride / 4
			rgbaBuffer := source buffer shallowCopy(IntVector2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget)
			result = EGLRgba new(rgbaBuffer, this)
		}
		result
	}
	recycle: override func (image: OpenGLPacked) {
		match (image) {
			case i: EGLRgba => this _eglBin add(i)
			case => super(image)
		}
	}
}
}
