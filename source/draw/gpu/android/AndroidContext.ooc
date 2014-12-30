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
import GpuPacker, GpuPackerBin, EglRgba
AndroidContext: class extends OpenGLES3Context {
	_packerBin: GpuPackerBin
	_packMonochrome1080p: OpenGLES3MapPackMonochrome1080p
	_packUv1080p: OpenGLES3MapPackUv1080p
	_unpackMonochrome1080p: OpenGLES3MapUnpackMonochrome1080p
	_unpackUv1080p: OpenGLES3MapUnpackUv1080p
	init: func {
		super(func { this onDispose() })
		this _packerBin = GpuPackerBin new()
		this _packMonochrome1080p = OpenGLES3MapPackMonochrome1080p new(this)
		this _packUv1080p = OpenGLES3MapPackUv1080p new(this)
		this _unpackMonochrome1080p = OpenGLES3MapUnpackMonochrome1080p new(this)
		this _unpackUv1080p = OpenGLES3MapUnpackUv1080p new(this)
	}
	onDispose: func {
		this _packerBin dispose()
		this _packMonochrome dispose()
		this _packUv dispose()
		EglRgba disposeAll()
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
		GpuPacker finish()
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
	toRaster: func ~overwrite (gpuImage: GpuImage, rasterImage: RasterImage) {
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

		GpuPacker finish()

		yBuffer := yPacker read()
		uvBuffer := uvPacker read()

		yRaster := RasterMonochrome new(yBuffer, gpuImage size, 64)
		yBuffer referenceCount decrease()
		uvRaster := RasterUv new(uvBuffer, gpuImage size / 2, 64)
		uvBuffer referenceCount decrease()
		result := RasterYuv420Semiplanar new(yRaster, uvRaster)
		result
	}
	toRaster: func ~monochrome (gpuImage: GpuMonochrome) -> RasterImage {
		yPacker := this createPacker(gpuImage size, 1)
		this _packMonochrome imageWidth = gpuImage size width
		yPacker pack(gpuImage, this _packMonochrome)
		GpuPacker finish()
		buffer := yPacker read()
		result := RasterMonochrome new(buffer, gpuImage size, 64)
		buffer referenceCount decrease()
		result
	}
	toRaster: func (gpuImage: GpuImage) -> RasterImage {
		result := match(gpuImage) {
			case (i : GpuYuv420Semiplanar) => this toRaster(gpuImage as GpuYuv420Semiplanar)
			case (i : GpuMonochrome) => this toRaster(gpuImage as GpuMonochrome)
			case => raise("Using toRaster on unimplemented image format"); null
		}
		result
	}
	recycle: func ~GpuPacker (packer: GpuPacker) {
		this _packerBin add(packer)
	}
	_createEglYuv420Semiplanar: func (rasterImage: RasterYuv420Semiplanar) -> GpuImage {
		if (rasterImage y size width != 1920)
			return this _createYuv420Semiplanar(rasterImage)
		textureY := this createEglRgba(IntSize2D new(rasterImage y size width, rasterImage y size height / 4), rasterImage y buffer pointer, 1)
		packedY := OpenGLES3Monochrome new(textureY, rasterImage y size, this)
		textureUv := this createEglRgba(IntSize2D new(1920, 135), rasterImage uv buffer pointer, 1)
		packedUv := OpenGLES3Uv new(textureUv, rasterImage uv size, this)
		result := this createYuv420Semiplanar(rasterImage size) as OpenGLES3Yuv420Semiplanar
		result y canvas draw(packedY, this _unpackMonochrome1080p, Viewport new(rasterImage y size))
		packedY dispose()
		result uv canvas draw(packedUv, this _unpackUv1080p, Viewport new(rasterImage uv size))
		packedUv dispose()
		result
	}
	/*
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		result := match (rasterImage) {
			case image: RasterYuv420Semiplanar => this _createYuv420Semiplanar(rasterImage as RasterYuv420Semiplanar)
			case image: RasterMonochrome => this _createMonochrome(rasterImage as RasterMonochrome)
			case image: RasterBgr => this _createBgr(rasterImage as RasterBgr)
			case image: RasterBgra => this _createBgra(rasterImage as RasterBgra)
			case image: RasterUv => this _createUv(rasterImage as RasterUv)
			case image: RasterYuv420Planar => this _createYuv420Planar(rasterImage as RasterYuv420Planar)
		}
		result
	}
	*/
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
	}
	createEglRgba: func (size: IntSize2D, pixels: Pointer = null, write: Int = 0) -> EglRgba { EglRgba new(this _backend _eglDisplay, size, pixels, write) }
}

AndroidContextManager: class extends GpuContextManager {
	init: func { super(3) }
	_createContext: func -> GpuContext { AndroidContext new() }
	createEglRgba: func (size: IntSize2D, pixels: Pointer = null) -> EglRgba { this _getContext() as AndroidContext createEglRgba(size, pixels, 1) }
}
