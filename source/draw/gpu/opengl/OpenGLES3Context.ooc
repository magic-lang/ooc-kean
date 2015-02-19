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
use ooc-base
use ooc-math
use ooc-draw
use ooc-draw-gpu
use ooc-opengl
import GpuImageBin, OpenGLES3Surface, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3Yuv422Semipacked
import Map/OpenGLES3Map, Map/OpenGLES3MapPack
import OpenGLES3/Context, OpenGLES3/NativeWindow

OpenGLES3Context: class extends GpuContext {
	_backend: Context
	_bgrMapDefault: OpenGLES3MapBgr
	_bgraMapDefault: OpenGLES3MapBgra
	_monochromeMapDefault: OpenGLES3MapMonochrome
	_monochromeMapTransform: OpenGLES3MapMonochrome
	_uvMapDefault: OpenGLES3MapUv
	_uvMapTransform: OpenGLES3MapUv
	_packMonochrome: OpenGLES3MapPackMonochrome
	_packUv: OpenGLES3MapPackUv

	init: func (context: Context) {
		super()
		this _bgrMapDefault = OpenGLES3MapBgr new(this)
		this _bgraMapDefault = OpenGLES3MapBgra new(this)
		this _monochromeMapDefault = OpenGLES3MapMonochrome new(this)
		this _monochromeMapTransform = OpenGLES3MapMonochrome new(this, true)
		this _uvMapDefault = OpenGLES3MapUv new(this)
		this _uvMapTransform = OpenGLES3MapUv new(this, true)
		this _packMonochrome = OpenGLES3MapPackMonochrome new(this)
		this _packUv = OpenGLES3MapPackUv new(this)
		this _backend = context
	}
	init: func ~unshared { this init(Context create()) }
	init: func ~shared (other: This) { this init(Context create(other _backend)) }
	init: func ~window (nativeWindow: NativeWindow) { this init(Context create(nativeWindow)) }
	free: func {
		this _backend makeCurrent()
		this _bgrMapDefault free()
		this _bgraMapDefault free()
		this _monochromeMapDefault free()
		this _uvMapDefault free()
		this _backend free()
		super()
	}
	recycle: func ~image (gpuImage: GpuImage) { this _imageBin add(gpuImage) }
	recycle: func ~surface (surface: GpuSurface) { this _surfaceBin add(surface) }
	getMap: func (gpuImage: GpuImage, mapType := GpuMapType defaultmap) -> GpuMap {
		result := match (mapType) {
			case GpuMapType defaultmap =>
				match (gpuImage) {
					case (gpuImage : GpuMonochrome) => this _monochromeMapDefault
					case (gpuImage : GpuUv) => this _uvMapDefault
					case (gpuImage : GpuBgr) => this _bgrMapDefault
					case (gpuImage : GpuBgra) => this _bgraMapDefault
					case => null
				}
			case GpuMapType transform =>
				match (gpuImage) {
					case (gpuImage : GpuMonochrome) => this _monochromeMapTransform
					case (gpuImage : GpuUv) => this _uvMapTransform
					case => null
				}
			case GpuMapType pack =>
				match (gpuImage) {
					case (gpuImage : GpuMonochrome) => this _packMonochrome
					case (gpuImage : GpuUv) => this _packUv
					case => null
				}
			case => null
		}
		if (result == null)
			raise("Could not find Map implementation of specified type")
		result
	}
	searchImageBin: func (type: GpuImageType, size: IntSize2D) -> GpuImage { this _imageBin find(type, size) }
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType monochrome, size)
		if (result == null)
			result = OpenGLES3Monochrome create(size, this)
		result
	}
	_createMonochrome: func (raster: RasterMonochrome) -> GpuImage {
		result := this searchImageBin(GpuImageType monochrome, raster size)
		if (result == null)
			result = OpenGLES3Monochrome create(raster, this)
		else
			result upload(raster)
		result
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType uv, size)
		if (result == null)
			result = OpenGLES3Uv create(size, this)
		result
	}
	_createUv: func (raster: RasterUv) -> GpuImage {
		result := this searchImageBin(GpuImageType uv, raster size)
		if (result == null)
			result = OpenGLES3Uv create(raster, this)
		else
			result upload(raster)
		result
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType bgr, size)
		if (result == null)
			result = OpenGLES3Bgr create(size, this)
		result
	}
	_createBgr: func (raster: RasterBgr) -> GpuImage {
		result := this searchImageBin(GpuImageType bgr, raster size)
		if (result == null)
			result = OpenGLES3Bgr create(raster, this)
		else
			result upload(raster)
		result
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType bgra, size)
		if (result == null)
			result = OpenGLES3Bgra create(size, this)
		result
	}
	_createBgra: func (raster: RasterBgra) -> GpuImage {
		result := this searchImageBin(GpuImageType bgra, raster size)
		if (result == null)
			result = OpenGLES3Bgra create(raster, this)
		else
			result upload(raster)
		result
	}
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType yuvSemiplanar, size)
		if (result == null) {
			result = OpenGLES3Yuv420Semiplanar create(size, this)
		}
		result
	}
	_createYuv420Semiplanar: func (raster: RasterYuv420Semiplanar) -> GpuImage {
		result := this searchImageBin(GpuImageType yuvSemiplanar, raster size)
		if (result == null) {
			result = OpenGLES3Yuv420Semiplanar create(raster, this)
		}
		else {
			result upload(raster)
		}
		result
	}
	createYuv420Planar: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType yuvPlanar, size)
		if (result == null)
			result = OpenGLES3Yuv420Planar create(size, this)
		result
	}
	_createYuv420Planar: func (raster: RasterYuv420Planar) -> GpuImage {
		result := this searchImageBin(GpuImageType yuvPlanar, raster size)
		if (result == null)
			result = OpenGLES3Yuv420Planar create(raster, this)
		else
			result upload(raster)
		result
	}
	createYuv422Semipacked: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType yuv422, size)
		if (result == null)
			result = OpenGLES3Yuv422Semipacked create(size, this)
		result
	}
	_createYuv422Semipacked: func (raster: RasterYuv422Semipacked) -> GpuImage {
		result := this searchImageBin(GpuImageType yuv422, raster size)
		if (result == null)
			result = OpenGLES3Yuv422Semipacked create(raster, this)
		else
			result upload(raster)
		result
	}
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		result := match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(image)
			case image: RasterBgr => this _createBgr(image)
			case image: RasterBgra => this _createBgra(image)
			case image: RasterUv => this _createUv(image)
			case image: RasterYuv420Semiplanar => this _createYuv420Semiplanar(image)
			case image: RasterYuv420Planar => this _createYuv420Planar(image)
			case image: RasterYuv422Semipacked => this _createYuv422Semipacked(image)
			case => null
		}
		if (result == null)
			raise("Unknown input format in OpenGLES3Context createGpuImage")
		result
	}
	createSurface: func -> GpuSurface {
		result := this _surfaceBin find()
		if(result == null)
			result = OpenGLES3Surface create(this)
		result
	}
	update: func { this _backend swapBuffers() }
	setViewport: func (viewport: Viewport) { Fbo setViewport(viewport offset width, viewport offset height, viewport resolution width, viewport resolution height) }
}
