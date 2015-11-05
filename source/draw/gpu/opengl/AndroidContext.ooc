//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
use ooc-draw-gpu
use ooc-collections
use ooc-draw
use ooc-math
use ooc-base
import OpenGLContext, GraphicBuffer, GraphicBufferYuv420Semiplanar, EGLBgra, OpenGLBgra, OpenGLPacked, OpenGLMonochrome, OpenGLUv
import Map/OpenGLMapPack
import threading/Thread
import math

version(!gpuOff) {
AndroidContext: class extends OpenGLContext {
	_unpackRgbaToMonochrome := OpenGLMapUnpackRgbaToMonochrome new(this)
	_unpackRgbaToUv := OpenGLMapUnpackRgbaToUv new(this)
	_packers := VectorList<EGLBgra> new()
	init: func { super() }
	init: func ~other (other: This) { super(other) }
	free: override func {
		this _backend makeCurrent()
		this _unpackRgbaToMonochrome free()
		this _unpackRgbaToUv free()
		this _packers free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		result: GpuImage
		version (optiGraphicbufferupload) {
			if (rasterImage instanceOf?(GraphicBufferYuv420Semiplanar)) {
				graphicBufferImage := rasterImage as GraphicBufferYuv420Semiplanar
				rgba := graphicBufferImage toRgba(this)
				result = this unpackBgraToYuv420Semiplanar(rgba, rasterImage size)
				rgba free()
			}
			else
				result = super(rasterImage)
		}
		else {
			result = super(rasterImage)
		}
		result
	}
	recyclePacker: func (packer: EGLBgra) { this _packers add(packer) }
	getPacker: func (size: IntSize2D) -> EGLBgra {
		result: EGLBgra = null
		index := -1
		for (i in 0 .. this _packers count) {
			if (this _packers[i] size == size) {
				index = i
				break
			}
		}
		index == -1 ? EGLBgra new(size, this) : this _packers remove(index)
	}
	toBuffer: func (gpuImage: GpuImage, packMap: GpuMap) -> (ByteBuffer, GpuFence) {
		channels := (gpuImage as OpenGLPacked) channels
		packSize := IntSize2D new(gpuImage size width / (4 / channels), gpuImage size height)
		gpuRgba := this getPacker(packSize)
		this packToRgba(gpuImage, gpuRgba, IntBox2D new(gpuRgba size))
		fence := this createFence()
		fence sync()
		eglImage := gpuRgba as EGLBgra
		sourcePointer := eglImage buffer lock(false)
		length := channels * eglImage size width * eglImage size height
		buffer := ByteBuffer new(sourcePointer, length,
			func (b: ByteBuffer) {
				eglImage buffer unlock()
				this recyclePacker(gpuRgba)
				b forceFree()
			})
		(buffer, fence)
	}
	toRaster: func ~monochrome (gpuImage: OpenGLMonochrome, async: Bool) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packMonochrome)
		if (!async)
			fence wait()
		fence free()
		RasterMonochrome new(buffer, gpuImage size)
	}
	toRaster: func ~uv (gpuImage: OpenGLUv, async: Bool) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packUv)
		if (!async)
			fence wait()
		fence free()
		RasterUv new(buffer, gpuImage size)
	}
	toRaster: override func (gpuImage: GpuImage, async: Bool = false) -> RasterImage {
		match (gpuImage) {
			case (image : OpenGLMonochrome) =>
				this isAligned(image channels * image size width) ? this toRaster(image, async) : super(image)
			case (image : OpenGLUv) =>
				this isAligned(image channels * image size width) ? this toRaster(image, async) : super(image)
			case => super(gpuImage)
		}
	}
	toRasterAsync: func ~monochrome (gpuImage: OpenGLMonochrome) -> (RasterImage, GpuFence) {
		(buffer, fence) := this toBuffer(gpuImage, this _packMonochrome)
		(RasterMonochrome new(buffer, gpuImage size), fence)
	}
	toRasterAsync: func ~uv (gpuImage: OpenGLUv) -> (RasterImage, GpuFence) {
		(buffer, fence) := this toBuffer(gpuImage, this _packUv)
		(RasterUv new(buffer, gpuImage size), fence)
	}
	toRasterAsync: override func (gpuImage: GpuImage) -> (RasterImage, GpuFence) {
		rasterResult: RasterImage
		fenceResult: GpuFence
		aligned := this isAligned(gpuImage size width)
		if (aligned && gpuImage instanceOf?(OpenGLMonochrome))
			(rasterResult, fenceResult) = this toRasterAsync(gpuImage as OpenGLMonochrome)
		else if (aligned && gpuImage instanceOf?(OpenGLUv))
			(rasterResult, fenceResult) = this toRasterAsync(gpuImage as OpenGLUv)
		else
			(rasterResult, fenceResult) = super(gpuImage)
		(rasterResult, fenceResult)
	}
	unpackBgraToYuv420Semiplanar: func (source: GpuImage, targetSize: IntSize2D) -> GpuYuv420Semiplanar {
		target := this createYuv420Semiplanar(targetSize) as GpuYuv420Semiplanar
		sourceSize := source size
		this _unpackRgbaToMonochrome add("texture0", source)
		this _unpackRgbaToMonochrome add("targetWidth", target y size width as Int)
		this _unpackRgbaToMonochrome add("transform", FloatTransform3D createScaling(source transform a, -source transform e, 1.0f))
		scaleX := (targetSize width as Float) / (4 * sourceSize width)
		this _unpackRgbaToMonochrome add("scaleX", scaleX)
		scaleY := targetSize height as Float / sourceSize height
		this _unpackRgbaToMonochrome add("scaleY", scaleY)
		this _unpackRgbaToMonochrome add("startY", 0.0f)
		target y canvas draw(source, this _unpackRgbaToMonochrome)

		uvSize := target uv size
		scaleX = (uvSize width as Float) / (2 * sourceSize width)
		this _unpackRgbaToUv add("scaleX", scaleX)
		startY := (sourceSize height - uvSize height) as Float / sourceSize height
		this _unpackRgbaToUv add("startY", startY)
		scaleY = 1.0f - startY
		this _unpackRgbaToUv add("scaleY", scaleY)
		this _unpackRgbaToUv add("transform", FloatTransform3D createScaling(source transform a, -source transform e, 1.0f))
		target uv canvas draw(source, this _unpackRgbaToUv)
		target
	}
	alignWidth: override func (width: Int, align := AlignWidth Nearest) -> Int { GraphicBuffer alignWidth(width, align) }
	isAligned: override func (width: Int) -> Bool { GraphicBuffer isAligned(width) }
}
}
