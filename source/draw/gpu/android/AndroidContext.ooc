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
import GpuPacker, GpuMapAndroid, GpuPackerBin, EglRgba
AndroidContext: class extends OpenGLES3Context {
	_packerBin: GpuPackerBin
	_packMonochrome1080p: OpenGLES3MapPackMonochrome1080p
	_packUv1080p: OpenGLES3MapPackUv1080p
	_unpackMonochrome1080p: OpenGLES3MapUnpackMonochrome1080p
	_unpackUv1080p: OpenGLES3MapUnpackUv1080p
	packTimer, readTimer: Logging
	_eglImageBin: GpuImageBin
	init: func {
		super(func { this onDispose() })
		this _packerBin = GpuPackerBin new()
		this _packMonochrome1080p = OpenGLES3MapPackMonochrome1080p new()
		this _packUv1080p = OpenGLES3MapPackUv1080p new()
		this _unpackMonochrome1080p = OpenGLES3MapUnpackMonochrome1080p new()
		this _unpackUv1080p = OpenGLES3MapUnpackUv1080p new()
		this packTimer = Logging new("Packing", 0)
		this readTimer = Logging new("Reading", 0)
		this _eglImageBin = GpuImageBin new()
	}
	onDispose: func {
		this _packerBin dispose()
		this _eglImageBin dispose()
		this _packMonochrome dispose()
		this _packUv dispose()
		EglRgba disposeAll()
	}
	toRaster: func ~overwrite (gpuImage: GpuImage, rasterImage: RasterImage) {
		if (gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			rasterYuv420Semiplanar := rasterImage as RasterYuv420Semiplanar
			semiPlanar := gpuImage as GpuYuv420Semiplanar

			if (gpuImage size width == 1920) {
				this packTimer start()
				yPacker := this createPacker(IntSize2D new(1920, 270), 4)
				uvPacker := this createPacker(IntSize2D new(1920, 135), 4)
				yPacker pack(semiPlanar y, this _packMonochrome1080p)
				uvPacker pack(semiPlanar uv, this _packUv1080p)
				GpuPacker finish()
				this packTimer stop()
				this readTimer start()
				yPacker read(rasterYuv420Semiplanar y)
				uvPacker read(rasterYuv420Semiplanar uv)
				yPacker recycle()
				uvPacker recycle()
				this readTimer stop()
			} else {
				yPacker := this createPacker(semiPlanar y size, 1)
				uvPacker := this createPacker(semiPlanar uv size, 2)
				yPacker pack(semiPlanar y, this _packMonochrome)
				uvPacker pack(semiPlanar uv, this _packUv)
				GpuPacker finish()
				yPacker read(rasterYuv420Semiplanar y)
				uvPacker read(rasterYuv420Semiplanar uv)
				yPacker recycle()
				uvPacker recycle()
			}
		} else
			raise("Using toRaster on unimplemented image format")
	}
	toRaster: func (gpuImage: GpuImage) -> RasterImage {
		result := null
		if (gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			semiPlanar := gpuImage as GpuYuv420Semiplanar
			if (gpuImage size width == 1920) {
				yPacker := this createPacker(IntSize2D new(1920, 270), 4)
				uvPacker := this createPacker(IntSize2D new(1920, 135), 4)
				yPacker pack(semiPlanar y, this _packMonochrome1080p)
				uvPacker pack(semiPlanar uv, this _packUv1080p)
				GpuPacker finish()
				yBuffer := yPacker read()
				uvBuffer := uvPacker read()
				yRaster := RasterMonochrome new(yBuffer, semiPlanar size, 64)
				uvRaster := RasterUv new(uvBuffer, semiPlanar size / 2, 64)
				result = RasterYuv420Semiplanar new(yRaster, uvRaster)
			} else {
				yPacker := this createPacker(semiPlanar y size, 1)
				uvPacker := this createPacker(semiPlanar uv size, 2)
				yPacker pack(semiPlanar y, this _packMonochrome)
				uvPacker pack(semiPlanar uv, this _packUv)
				GpuPacker finish()
				yBuffer := yPacker read()
				uvBuffer := uvPacker read()
				yRaster := RasterMonochrome new(yBuffer, semiPlanar size, 64)
				uvRaster := RasterUv new(uvBuffer, semiPlanar size / 2, 64)
				result = RasterYuv420Semiplanar new(yRaster, uvRaster)
			}
		} else if (gpuImage instanceOf?(GpuMonochrome)) {
			monochrome := gpuImage as GpuMonochrome
			yPacker := this createPacker(monochrome size, 1)
			yPacker pack(monochrome, this _packMonochrome)
			GpuPacker finish()
			buffer := yPacker read()
			raster := RasterMonochrome new(buffer, monochrome size, 64)
			result = raster
		} else
			raise("Using toRaster on unimplemented image format")
		result
	}
	/*
	toRasterCopy: func (gpuImage: GpuImage) -> RasterImage {
		result := null
		if (gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			raster := RasterYuv420Semiplanar new(gpuImage size)
			semiPlanar := gpuImage as GpuYuv420Semiplanar
			yPacker := this createPacker(semiPlanar y size, 1)
			yPacker pack(semiPlanar y, this _packMonochrome, raster y)
			yPacker recycle()
			uvPacker := this createPacker(semiPlanar uv size, 2)
			uvPacker pack(semiPlanar uv, this _packUv, raster uv)
			uvPacker recycle()
			result = raster
		} else if (gpuImage instanceOf?(GpuMonochrome)) {
			raster := RasterMonochrome new(gpuImage size)
			monochrome := gpuImage as GpuMonochrome
			yPacker := this createPacker(monochrome size, 1)
			yPacker pack(monochrome, this _packMonochrome)
			yPacker recycle()
			result = raster
		} else
			raise("Using toRaster on unimplemented image format")
		result
	}
	*/
	recycle: func ~GpuPacker (packer: GpuPacker) {
		this _packerBin add(packer)
	}
	/*
	recycle: func ~image (gpuImage: GpuImage) {
		DebugPrinting printDebug("Recycling gpuimage")
		texture := gpuImage _backend as Texture
		if (texture instanceOf?(EglRgba)) {
			DebugPrinting printDebug("Recycled EGLImage")
			this _eglImageBin add(gpuImage)
		}
		else {
			DebugPrinting printDebug("Recycled normal gpuimage")
			this _imageBin add(gpuImage)
		}
	}
	*/
	_createEglYuv420Semiplanar: func (rasterImage: RasterYuv420Semiplanar) -> GpuImage {
		if (rasterImage y size width != 1920)
			return this _createYuv420Semiplanar(rasterImage)
		packedY := this _eglImageBin find(GpuImageType monochrome, rasterImage y size) as OpenGLES3Monochrome
		packedUv := this _eglImageBin find(GpuImageType uv, rasterImage uv size) as OpenGLES3Uv
		if (packedY != null) {
			DebugPrinting printDebug("Upload monochrome")
			packedY upload(rasterImage y)
		}
		else {
			DebugPrinting printDebug("Allocating new EglRgba for monochrome")
			texture := this createEglRgba(IntSize2D new(rasterImage y size width, rasterImage y size height / 4), rasterImage y pointer, 1)
			packedY = OpenGLES3Monochrome new(texture, rasterImage y size, this)
		}
		if (packedUv != null) {
			DebugPrinting printDebug("Upload uv")
			packedUv upload(rasterImage uv)
		}
		else {
			DebugPrinting printDebug("Allocating new EglRgba for uv")
			texture := this createEglRgba(IntSize2D new(1920, 135), rasterImage uv pointer, 1)
			packedUv = OpenGLES3Uv new(texture, rasterImage uv size, this)
		}

		result := this createYuv420Semiplanar(rasterImage size) as OpenGLES3Yuv420Semiplanar
		this _unpackMonochrome1080p transform = FloatTransform2D identity
		this _unpackMonochrome1080p imageSize = rasterImage y size
		this _unpackMonochrome1080p screenSize = rasterImage y size
		result y canvas draw(packedY, this _unpackMonochrome1080p, Viewport new(rasterImage y size))
		this _unpackUv1080p transform = FloatTransform2D identity
		this _unpackUv1080p imageSize = rasterImage uv size
		this _unpackUv1080p screenSize = rasterImage uv size
		result uv canvas draw(packedUv, this _unpackUv1080p, Viewport new(rasterImage uv size))
		this _eglImageBin add(packedY)
		this _eglImageBin add(packedUv)
		result
	}
	_createEglMonochrome: func (rasterImage: RasterMonochrome) -> OpenGLES3Monochrome {
		packed := this _eglImageBin find(GpuImageType monochrome, rasterImage size) as OpenGLES3Monochrome
		if (packed != null) {
			DebugPrinting printDebug("Found recycled eglMonochrome")
			packed upload(rasterImage)
		}
		else {
			eglRgba: EglRgba
			eglRgba = match (rasterImage size width) {
				case 1920 => this createEglRgba(IntSize2D new(rasterImage size width, rasterImage size height / 4))
				case 1280 => this createEglRgba(IntSize2D new(rasterImage size width / 4, rasterImage size height))
				case 720 => this _createMonochrome(rasterImage)
				case => null
			}
			pointer := eglRgba write()
			memcpy(pointer, rasterImage pointer, rasterImage size width * rasterImage size height)
			eglRgba unlock()
			packed = OpenGLES3Monochrome new(eglRgba, rasterImage size, this)
		}

		result := this createMonochrome(rasterImage size) as OpenGLES3Monochrome
		this _unpackMonochrome1080p transform = FloatTransform2D identity
		this _unpackMonochrome1080p imageSize = result size
		this _unpackMonochrome1080p screenSize = result size
		result canvas draw(packed, this _unpackMonochrome1080p, Viewport new(rasterImage size))
		packed recycle()
		result
	}
	_createEglUv: func (rasterImage: RasterUv) -> OpenGLES3Uv {
		packed := this _eglImageBin find(GpuImageType uv, rasterImage size) as OpenGLES3Uv
		if (packed != null) {
			DebugPrinting printDebug("Found recycled eglUv")
			packed upload(rasterImage)
		}
		else {
			DebugPrinting printDebug("Creating eglRgba")
			eglRgba: EglRgba
			eglRgba = match (rasterImage size width) {
				case 960 => this createEglRgba(IntSize2D new(1920, 135))
				case 640 => this createEglRgba(IntSize2D new(rasterImage size width / 4, rasterImage size height))
				case 360 => this createEglRgba(rasterImage size)
				case => null
			}
			pointer := eglRgba write()
			memcpy(pointer, rasterImage pointer, rasterImage size width * rasterImage size height)
			eglRgba unlock()
			packed = OpenGLES3Uv new(eglRgba, rasterImage size, this)
		}

		result := this createUv(rasterImage size) as OpenGLES3Uv
		this _unpackUv1080p transform = FloatTransform2D identity
		this _unpackUv1080p imageSize = result size
		this _unpackUv1080p screenSize = result size
		result canvas draw(packed, this _unpackUv1080p, Viewport new(rasterImage size))
		packed recycle()
		result
	}
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
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
	}
	createEglRgba: func (size: IntSize2D, pixels: Pointer = null, write: Int = 0) -> EglRgba {
			EglRgba new(this _backend _eglDisplay, size, pixels, write)
	}
}

AndroidContextManager: class extends GpuContextManager {
	init: func {
		setShaderSources()
		super(3)
	}
	_createContext: func -> GpuContext {
		AndroidContext new()
	}
	createEglRgba: func (size: IntSize2D, pixels: Pointer = null) -> EglRgba {
		this _getContext() as AndroidContext createEglRgba(size, pixels, 1)
	}
}
