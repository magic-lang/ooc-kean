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
use ooc-opengl
use ooc-draw
use ooc-math
use ooc-base
import GpuPacker, GpuPackerBin, AndroidTexture, GraphicBuffer
import threading/Thread
import math
AndroidContext: class extends OpenGLES3Context {
	_packerBin: GpuPackerBin
	_unpackRgbaToMonochrome: OpenGLES3MapUnpackRgbaToMonochrome
	_unpackRgbaToUv: OpenGLES3MapUnpackRgbaToUv
	init: func {
		super()
		this _initialize()
	}
	init: func ~other (other: This) {
		super(other)
		this _initialize()
	}
	_initialize: func {
		this _packerBin = GpuPackerBin new()
		this _unpackRgbaToMonochrome = OpenGLES3MapUnpackRgbaToMonochrome new(this)
		this _unpackRgbaToUv = OpenGLES3MapUnpackRgbaToUv new(this)
	}
	free: override func {
		this _backend makeCurrent()
		this _packerBin free()
		this _unpackRgbaToMonochrome free()
		this _unpackRgbaToUv free()
		super()
	}
	toRaster: func ~Yuv420Sp (gpuImage: GpuYuv420Semiplanar) -> RasterImage {
		yPacker, uvPacker: GpuPacker

		yPacker = this createPacker(gpuImage y size, 1)
		uvPacker = this createPacker(gpuImage uv size, 2)
		this _packMonochrome imageWidth = gpuImage y size width
		yPacker pack(gpuImage y, this _packMonochrome)
		this _packUv imageWidth = gpuImage uv size width
		uvPacker pack(gpuImage uv, this _packUv)

		yBuffer, uvBuffer: ByteBuffer
		if (gpuImage size height == 1080) {
			yBuffer = yPacker readRows()
			uvBuffer = uvPacker readRows()
			yPacker recycle()
			uvPacker recycle()
		} else {
			yBuffer = yPacker read()
			uvBuffer = uvPacker read()
		}

		yRaster := RasterMonochrome new(yBuffer, gpuImage size)
		uvRaster := RasterUv new(uvBuffer, gpuImage size / 2)
		result := RasterYuv420Semiplanar new(yRaster, uvRaster)
		result
	}
	toRaster: func ~monochrome (gpuImage: GpuMonochrome, async: Bool = false) -> RasterImage {
		result: RasterImage
		bytesPerPixel := 1
		if (!this isAligned(gpuImage size width * bytesPerPixel))
			result = gpuImage toRasterDefault()
		else {
			yPacker := this createPacker(gpuImage size, bytesPerPixel)
			this _packMonochrome imageWidth = gpuImage size width
			yPacker pack(gpuImage, this _packMonochrome)
			result = RasterMonochrome new(yPacker read(async), gpuImage size, 64)
		}
		result
	}
	toRaster: func ~uv (gpuImage: GpuUv, async: Bool = false) -> RasterImage {
		result: RasterImage
		bytesPerPixel := 2
		if (!this isAligned(gpuImage size width * bytesPerPixel))
			result = gpuImage toRasterDefault()
		else {
			uvPacker := this createPacker(gpuImage size, bytesPerPixel)
			this _packUv imageWidth = gpuImage size width
			uvPacker pack(gpuImage, this _packUv)
			result = RasterUv new(uvPacker read(async), gpuImage size, 64)
		}
		result
	}
	toRaster: override func (gpuImage: GpuImage, async: Bool = false) -> RasterImage {
		result := match(gpuImage) {
			case (i : GpuYuv420Semiplanar) => this toRaster(gpuImage as GpuYuv420Semiplanar)
			case (i : GpuUv) => this toRaster(gpuImage as GpuUv, async)
			case (i : GpuMonochrome) => this toRaster(gpuImage as GpuMonochrome, async)
			case => super(gpuImage)
		}
		result
	}
	recycle: func ~GpuPacker (packer: GpuPacker) { this _packerBin add(packer) }
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			version(debugGL) { Debug print("Could not find a recycled GpuPacker!")}
			result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
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
		target y canvas draw(source, _unpackRgbaToMonochrome, Viewport new(target y size))
		this _unpackRgbaToUv targetSize = target uv size
		this _unpackRgbaToUv sourceSize = source size
		target uv canvas draw(source, _unpackRgbaToUv, Viewport new(target uv size))
		target
	}

	alignWidth: override func (width: Int, align := AlignWidth Nearest) -> Int { GraphicBuffer alignWidth(width, align) }
	isAligned: override func (width: Int) -> Bool { GraphicBuffer isAligned(width) }
}

AndroidContextManager: class extends GpuContextManager {
	_motherContext: AndroidContext
	_sharedContexts: Bool
	_mutex: Mutex
	currentContext: AndroidContext { get { this _getContext() as AndroidContext } }
	init: func (contexts: Int, sharedContexts := false) {
		super(contexts)
		this _sharedContexts = sharedContexts
		this _mutex = Mutex new()
	}
	_createContext: func -> GpuContext {
		result: GpuContext
		if (this _sharedContexts) {
			this _mutex lock()
			if (this _motherContext == null) {
				this _motherContext = AndroidContext new()
				result = this _motherContext
			} else
				result = AndroidContext new(this _motherContext)
			this _mutex unlock()
		} else
			result = AndroidContext new()
		result
	}
	createBgra: func ~fromGraphicBuffer (buffer: GraphicBuffer) -> OpenGLES3Bgra { this currentContext createBgra(buffer) }
	unpackBgraToYuv420Semiplanar: func (source: GpuBgra, targetSize: IntSize2D) -> GpuYuv420Semiplanar {
		this currentContext unpackBgraToYuv420Semiplanar(source, targetSize)
	}
	alignWidth: override func (width: Int, align := AlignWidth Nearest) -> Int { GraphicBuffer alignWidth(width, align) }
	isAligned: override func (width: Int) -> Bool { GraphicBuffer isAligned(width) }
}
