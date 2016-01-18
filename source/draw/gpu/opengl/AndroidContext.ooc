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
use ooc-geometry
use ooc-base
import OpenGLContext, GraphicBuffer, GraphicBufferYuv420Semiplanar, EGLBgra, OpenGLBgra, OpenGLPacked, OpenGLMonochrome, OpenGLUv, OpenGLMap
import threading/Thread

version(!gpuOff) {
AndroidContext: class extends OpenGLContext {
	_unpackRgbaToMonochrome := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToMonochrome.frag"), this)
	_unpackRgbaToUv := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUv.frag"), this)
	_unpackRgbaToUvPadded := OpenGLMap new(slurp("shaders/unpack.vert"), slurp("shaders/unpackRgbaToUvPadded.frag"), this)
	_packers := VectorList<EGLBgra> new()
	init: func { super() }
	init: func ~other (other: This) { super(other) }
	free: override func {
		this _backend makeCurrent()
		this _unpackRgbaToMonochrome free()
		this _unpackRgbaToUv free()
		this _unpackRgbaToUvPadded free()
		this _packers free()
		super()
	}
	createImage: override func (rasterImage: RasterImage) -> GpuImage {
		result: GpuImage
		version (optiGraphicbufferupload) {
			if (rasterImage instanceOf?(GraphicBufferYuv420Semiplanar)) {
				graphicBufferImage := rasterImage as GraphicBufferYuv420Semiplanar
				rgba := graphicBufferImage toRgba(this)
				result = this unpackBgraToYuv420Semiplanar(rgba, rasterImage size, graphicBufferImage uvPadding % graphicBufferImage stride)
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
	recyclePacker: func (packer: EGLBgra) { this _packers add(packer) }
	getPacker: func (size: IntVector2D) -> EGLBgra {
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
		packSize := IntVector2D new(gpuImage size x / (4 / channels), gpuImage size y)
		gpuRgba := this getPacker(packSize)
		this packToRgba(gpuImage, gpuRgba, IntBox2D new(gpuRgba size))
		fence := this createFence()
		fence sync()
		eglImage := gpuRgba as EGLBgra
		sourcePointer := eglImage buffer lock(GraphicBufferUsage ReadOften) as UInt8*
		length := channels * eglImage size area
		recover := func (b: ByteBuffer) -> Bool {
			eglImage buffer unlock()
			this recyclePacker(gpuRgba)
			false
		}
		(ByteBuffer new(sourcePointer, length, recover), fence)
	}
	toRaster: func ~monochrome (gpuImage: OpenGLMonochrome) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packMonochrome)
		fence free()
		RasterMonochrome new(buffer, gpuImage size)
	}
	toRaster: func ~uv (gpuImage: OpenGLUv) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packUv)
		fence free()
		RasterUv new(buffer, gpuImage size)
	}
	toRaster: override func (gpuImage: GpuImage) -> RasterImage {
		match (gpuImage) {
			case (image : OpenGLMonochrome) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
			case (image : OpenGLUv) =>
				this isAligned(image channels * image size x) ? this toRaster(image) : super(image)
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
		aligned := this isAligned(gpuImage size x)
		if (aligned && gpuImage instanceOf?(OpenGLMonochrome))
			(rasterResult, fenceResult) = this toRasterAsync(gpuImage as OpenGLMonochrome)
		else if (aligned && gpuImage instanceOf?(OpenGLUv))
			(rasterResult, fenceResult) = this toRasterAsync(gpuImage as OpenGLUv)
		else
			(rasterResult, fenceResult) = super(gpuImage)
		(rasterResult, fenceResult)
	}
	unpackBgraToYuv420Semiplanar: func (source: GpuImage, targetSize: IntVector2D, padding := 0) -> GpuYuv420Semiplanar {
		target := this createYuv420Semiplanar(targetSize) as GpuYuv420Semiplanar
		sourceSize := source size
		transform := FloatTransform3D createScaling(source transform a, -source transform e, 1.0f)
		yMap: GpuMap = this _unpackRgbaToMonochrome
		uvMap: GpuMap = this _unpackRgbaToUv
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
	_unpack: static func (source: GpuImage, target: GpuImage, map: GpuMap, targetWidth: Int, transform: FloatTransform3D, scaleX: Float, scaleY: Float, startY: Float) {
		map add("texture0", source)
		map add("targetWidth", targetWidth)
		map add("transform", transform)
		map add("scaleX", scaleX)
		map add("scaleY", scaleY)
		map add("startY", startY)
		target canvas draw(source, map)
	}
}
}
