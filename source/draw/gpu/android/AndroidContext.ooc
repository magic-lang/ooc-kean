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
use ooc-opengl
use ooc-draw
use ooc-math
use ooc-base
import AndroidTexture, GraphicBuffer
import threading/Thread
import math
AndroidContext: class extends OpenGLES3Context {
	_unpackRgbaToMonochrome := OpenGLES3MapUnpackRgbaToMonochrome new(this)
	_unpackRgbaToUv := OpenGLES3MapUnpackRgbaToUv new(this)
	_packers := VectorList<OpenGLES3Bgra> new()
	init: func { super() }
	init: func ~other (other: This) { super(other) }
	free: override func {
		this _backend makeCurrent()
		this _unpackRgbaToMonochrome free()
		this _unpackRgbaToUv free()
		this _packers free()
		super()
	}
	recyclePacker: func (packer: OpenGLES3Bgra) { this _packers add(packer) }
	getPacker: func (size: IntSize2D) -> OpenGLES3Bgra {
		result: OpenGLES3Bgra = null
		index := -1
		for (i in 0..this _packers count) {
			if (this _packers[i] size == size) {
				index = i
				break
			}
		}
		if (index == -1) {
			androidTexture := this createAndroidRgba(size)
			result = OpenGLES3Bgra new(androidTexture, this)
			result _recyclable = false
		}
		else
			result = this _packers remove(index)
		result
	}
	toBuffer: func (gpuImage: GpuImage, packMap: OpenGLES3MapPack) -> (ByteBuffer, GpuFence) {
		packSize := IntSize2D new(gpuImage size width / (4 / gpuImage channels), gpuImage size height)
		gpuRgba := this getPacker(packSize)
		this packToRgba(gpuImage, gpuRgba, IntBox2D new(gpuRgba size))
		fence := this createFence()
		fence sync()
		androidTexture := gpuRgba texture as AndroidTexture
		sourcePointer := androidTexture lock(false)
		buffer := ByteBuffer new(sourcePointer, androidTexture stride * androidTexture size height,
			func (buffer: ByteBuffer) {
				androidTexture unlock()
				this recyclePacker(gpuRgba)
			})
		(buffer, fence)
	}
	toRaster: func ~monochrome (gpuImage: GpuMonochrome, async: Bool) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packMonochrome)
		if (!async)
			fence wait()
		fence free()
		RasterMonochrome new(buffer, gpuImage size)
	}
	toRaster: func ~uv (gpuImage: GpuUv, async: Bool) -> RasterImage {
		(buffer, fence) := this toBuffer(gpuImage, this _packUv)
		if (!async)
			fence wait()
		fence free()
		RasterUv new(buffer, gpuImage size)
	}
	toRaster: override func (gpuImage: GpuImage, async: Bool = false) -> RasterImage {
		result: RasterImage = null
		if (!this isAligned(gpuImage channels * gpuImage size width))
			result = super(gpuImage, async)
		else {
			result = match(gpuImage) {
				case (image : GpuUv) => this toRaster(image, async)
				case (image : GpuMonochrome) => this toRaster(image, async)
				case => super(gpuImage)
			}
		}
		result
	}
	toRasterAsync: func~monochrome (gpuImage: GpuMonochrome) -> (RasterImage, GpuFence) {
		(buffer, fence) := this toBuffer(gpuImage, this _packMonochrome)
		(RasterMonochrome new(buffer, gpuImage size), fence)
	}
	toRasterAsync: func~uv (gpuImage: GpuUv) -> (RasterImage, GpuFence) {
		(buffer, fence) := this toBuffer(gpuImage, this _packUv)
		(RasterUv new(buffer, gpuImage size), fence)
	}
	toRasterAsync: override func (gpuImage: GpuImage) -> (RasterImage, GpuFence) {
		imageResult: RasterImage
		fenceResult: GpuFence
		if (!this isAligned(gpuImage channels * gpuImage size width))
			(imageResult, fenceResult) = super(gpuImage)
		else {
			match(gpuImage) {
				case (image : GpuMonochrome) => (imageResult, fenceResult) = this toRasterAsync(image)
				case (image : GpuUv) => (imageResult, fenceResult) = this toRasterAsync(image)
				case => Debug raise("Unknown format in toRasterAsync");
			}
		}
		(imageResult, fenceResult)
	}
	createAndroidRgba: func (size: IntSize2D) -> AndroidRgba { AndroidRgba new(size, this _backend _eglDisplay) }
	createBgra: func ~fromGraphicBuffer (buffer: GraphicBuffer) -> OpenGLES3Bgra {
		androidTexture := AndroidRgba new(buffer, this _backend _eglDisplay)
		result := OpenGLES3Bgra new(androidTexture, this)
		result _recyclable = false
		result
	}
	unpackBgraToYuv420Semiplanar: func (source: GpuBgra, targetSize: IntSize2D) -> GpuYuv420Semiplanar {
		target := this createYuv420Semiplanar(targetSize) as GpuYuv420Semiplanar
		this _unpackRgbaToMonochrome targetSize = target y size
		this _unpackRgbaToMonochrome sourceSize = source size
		this _unpackRgbaToMonochrome transform = FloatTransform3D createScaling(source transform a, -source transform e, 1.0f)
		//TODO: Verify adaptation to new kean
		target y canvas map = this _unpackRgbaToMonochrome
		target y canvas draw(source)
		this _unpackRgbaToUv targetSize = target uv size
		this _unpackRgbaToUv sourceSize = source size
		this _unpackRgbaToUv transform = FloatTransform3D createScaling(source transform a, -source transform e, 1.0f)
		//TODO: Verify adaptation to new kean
		target uv canvas map = this _unpackRgbaToUv
		target uv canvas draw(source)
		target
	}

	alignWidth: override func (width: Int, align := AlignWidth Nearest) -> Int { GraphicBuffer alignWidth(width, align) }
	isAligned: override func (width: Int) -> Bool { GraphicBuffer isAligned(width) }
}
