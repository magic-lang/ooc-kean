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
AndroidContext: class extends OpenGLES3Context {
	_packerBin: GpuPackerBin
	_packMonochrome1080p: OpenGLES3MapPackMonochrome1080p
	_packUv1080p: OpenGLES3MapPackUv1080p
	_unpackMonochrome1080p: OpenGLES3MapUnpackMonochrome1080p
	_unpackUv1080p: OpenGLES3MapUnpackUv1080p
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
		this _packMonochrome1080p = OpenGLES3MapPackMonochrome1080p new(this)
		this _packUv1080p = OpenGLES3MapPackUv1080p new(this)
		this _unpackMonochrome1080p = OpenGLES3MapUnpackMonochrome1080p new(this)
		this _unpackUv1080p = OpenGLES3MapUnpackUv1080p new(this)
		this _unpackRgbaToMonochrome = OpenGLES3MapUnpackRgbaToMonochrome new(this)
		this _unpackRgbaToUv = OpenGLES3MapUnpackRgbaToUv new(this)
	}
	free: override func {
		this _backend makeCurrent()
		this _packerBin free()
		this _packMonochrome free()
		this _packUv free()
		super()
	}
	clean: func {
		this _packerBin clean()
	}
	toRaster: func ~Yuv420SpOverwrite (gpuImage: GpuYuv420Semiplanar, rasterImage: RasterYuv420Semiplanar) {
		yPacker, uvPacker: GpuPacker
		/*
		//Special case to deal with padding for 1080p
		if (gpuImage size height == 1080) {
			yPacker = this createPacker(IntSize2D new(1920, 270), 4)
			uvPacker = this createPacker(IntSize2D new(1920, 135), 4)
			yPacker pack(gpuImage y, this _packMonochrome1080p)
			uvPacker pack(gpuImage uv, this _packUv1080p)
		}
		else {
			yPacker = this createPacker(gpuImage y size, 1)
			uvPacker = this createPacker(gpuImage uv size, 2)
			yPacker pack(gpuImage y, this _packMonochrome)
			uvPacker pack(gpuImage uv, this _packUv)
		}
		*/
		yPacker = this createPacker(gpuImage y size, 1)
		uvPacker = this createPacker(gpuImage uv size, 2)
		this _packMonochrome imageWidth = gpuImage y size width
		yPacker pack(gpuImage y, this _packMonochrome)
		this _packUv imageWidth = gpuImage uv size width
		uvPacker pack(gpuImage uv, this _packUv)
		if (rasterImage size height == 1080) {
			yPacker readRows(rasterImage y)
			uvPacker readRows(rasterImage uv)
		}
		else {
			yPacker read(rasterImage y)
			uvPacker read(rasterImage uv)
		}
		yPacker recycle()
		uvPacker recycle()
	}
	toRaster: override func ~overwrite (gpuImage: GpuImage, rasterImage: RasterImage) {
		match(gpuImage) {
			case (i : GpuYuv420Semiplanar) => this toRaster(gpuImage as GpuYuv420Semiplanar, rasterImage as RasterYuv420Semiplanar)
			case => raise("Using toRaster on unimplemented image format")
		}
	}
	toRaster: func ~Yuv420Sp (gpuImage: GpuYuv420Semiplanar) -> RasterImage {
		yPacker, uvPacker: GpuPacker
		/*
		if (gpuImage size height == 1080) {
			yPacker = this createPacker(IntSize2D new(1920, 270), 4)
			uvPacker = this createPacker(IntSize2D new(1920, 135), 4)
			yPacker pack(gpuImage y, this _packMonochrome1080p)
			uvPacker pack(gpuImage uv, this _packUv1080p)
		}
		else {
			yPacker = this createPacker(gpuImage y size, 1)
			uvPacker = this createPacker(gpuImage uv size, 2)
			yPacker pack(gpuImage y, this _packMonochrome)
			uvPacker pack(gpuImage uv, this _packUv)
		}
		*/

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
		}
		else {
			yBuffer = yPacker read()
			uvBuffer = uvPacker read()
		}

		yRaster := RasterMonochrome new(yBuffer, gpuImage size)
		uvRaster := RasterUv new(uvBuffer, gpuImage size / 2)
		result := RasterYuv420Semiplanar new(yRaster, uvRaster)
		result
	}
	toRaster: func ~monochrome (gpuImage: GpuMonochrome) -> RasterImage {
		yPacker := this createPacker(gpuImage size, 1)
		this _packMonochrome imageWidth = gpuImage size width
		yPacker pack(gpuImage, this _packMonochrome)
		buffer := yPacker read()
		result := RasterMonochrome new(buffer, gpuImage size, 64)
		result
	}
	toRaster: override func (gpuImage: GpuImage) -> RasterImage {
		result := match(gpuImage) {
			case (i : GpuYuv420Semiplanar) => this toRaster(gpuImage as GpuYuv420Semiplanar)
			case (i : GpuMonochrome) => this toRaster(gpuImage as GpuMonochrome)
			case => super(gpuImage)
		}
		result
	}
	recycle: func ~GpuPacker (packer: GpuPacker) {
		this _packerBin add(packer)
	}
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			DebugPrint print("Could not find a recycled GpuPacker in list with size " + this _packerBin _packers size toString() + " with size " + size toString())
			result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
	}
	createAndroidRgba: func (size: IntSize2D, read: Bool, write: Bool) -> AndroidRgba { AndroidRgba new(size, read, write, this _backend _eglDisplay) }
	createBgra: func ~fromGpuTexture (texture: GpuTexture) -> OpenGLES3Bgra { OpenGLES3Bgra new(texture, this) }
	createBgra: func ~fromGraphicBuffer (buffer: GraphicBuffer) -> OpenGLES3Bgra {
		androidTexture := this createAndroidRgba(buffer)
		result := this createBgra(androidTexture)
		result
	}
	createAndroidRgba: func ~fromGraphicBuffer (buffer: GraphicBuffer) -> AndroidRgba { AndroidRgba new(buffer, this _backend _eglDisplay) }
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

}

AndroidContextManager: class extends GpuContextManager {
	_motherContext: AndroidContext
	_sharedContexts: Bool
	_mutex: Mutex
	currentAndroidContext: AndroidContext { get { this _getContext() as AndroidContext } }
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
			}
			else
				result = AndroidContext new(this _motherContext)
			this _mutex unlock()
		}
		else
			result = AndroidContext new()

		result
	}
	createBgra: func ~fromGraphicBuffer (buffer: GraphicBuffer) -> OpenGLES3Bgra { this currentAndroidContext createBgra(buffer) }
	unpackBgraToYuv420Semiplanar: func (source: GpuBgra, targetSize: IntSize2D) -> GpuYuv420Semiplanar { this currentAndroidContext unpackBgraToYuv420Semiplanar(source, targetSize) }
}
