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
import GpuImageBin, OpenGLES3Surface, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3Map
import OpenGLES3/Context, OpenGLES3/NativeWindow

OpenGLES3Context: class extends GpuContext {
	_backend: Context
	_bgrMapDefault: OpenGLES3MapBgr
	_bgraMapDefault: OpenGLES3MapBgra
	_monochromeMapDefault: OpenGLES3MapMonochrome
	_monochromeMapTransform: OpenGLES3MapMonochromeTransform
	_uvMapDefault: OpenGLES3MapUv
	_uvMapTransform: OpenGLES3MapUvTransform
	_pyramidMapMonochrome: OpenGLES3MapPyramidGeneration
	_pyramidMapMonochromeMipmap: OpenGLES3MapPyramidGenerationMipmap
	_packMonochrome: OpenGLES3MapPackMonochrome
	_packUv: OpenGLES3MapPackUv
	_onDispose: Func

	init: func (context: Context) {
		super()
		this _bgrMapDefault = OpenGLES3MapBgr new()
		this _bgraMapDefault = OpenGLES3MapBgra new()
		this _monochromeMapDefault = OpenGLES3MapMonochrome new()
		this _monochromeMapTransform = OpenGLES3MapMonochromeTransform new()
		this _uvMapDefault = OpenGLES3MapUv new()
		this _uvMapTransform = OpenGLES3MapUvTransform new()
		this _pyramidMapMonochrome = OpenGLES3MapPyramidGeneration new()
		this _pyramidMapMonochromeMipmap = OpenGLES3MapPyramidGenerationMipmap new()
		this _packMonochrome = OpenGLES3MapPackMonochrome new()
		this _packUv = OpenGLES3MapPackUv new()
		this _backend = context
	}
	init: func ~unshared (onDispose: Func) {
		this _onDispose = onDispose
		this init(Context create())
	}
	init: func ~shared (other: This, onDispose: Func) {
		this _onDispose = onDispose
		this init(Context create(other _backend))
	}
	init: func ~window (nativeWindow: NativeWindow, onDispose: Func) {
		this _onDispose = onDispose
		this init(Context create(nativeWindow))
	}
	dispose: func {
		this _backend makeCurrent()
		this _onDispose()
		this _bgrMapDefault dispose()
		this _bgraMapDefault dispose()
		this _monochromeMapDefault dispose()
		this _uvMapDefault dispose()
		this _pyramidMapMonochrome dispose()
		this _imageBin dispose()
		this _surfaceBin dispose()
		this _backend dispose()
	}
	recycle: func ~image (gpuImage: GpuImage) {
		this _imageBin add(gpuImage)
	}
	recycle: func ~surface (surface: GpuSurface) {
		this _surfaceBin add(surface)
	}
	getMap: func (gpuImage: GpuImage, mapType := GpuMapType defaultmap) -> GpuMap {
		result := match (mapType) {
			case GpuMapType defaultmap =>
				match (gpuImage) {
					case (i : GpuMonochrome) => this _monochromeMapDefault
					case (i : GpuUv) => this _uvMapDefault
					case (i : GpuBgr) => this _bgrMapDefault
					case (i : GpuBgra) => this _bgraMapDefault
					case => null
				}
			case GpuMapType transform =>
				match (gpuImage) {
					case (i : GpuMonochrome) => this _monochromeMapTransform
					case (i : GpuUv) => this _uvMapTransform
					case => null
				}
			case GpuMapType pyramid =>
				match (gpuImage) {
					case (i : GpuMonochrome) => this _pyramidMapMonochrome
					case => null
				}
			case GpuMapType pyramidMipmap =>
				match (gpuImage) {
					case (i : GpuMonochrome) => this _pyramidMapMonochromeMipmap
					case => null
				}
			case GpuMapType pack =>
				match (gpuImage) {
					case (i : GpuMonochrome) => this _packMonochrome
					case (i : GpuUv) => this _packUv
					case => null
				}
			case => null
		}
		if (result == null)
			raise("Could not find Map implementation of specified type")
		result
	}
	searchImageBin: func (type: GpuImageType, size: IntSize2D) -> GpuImage {
		this _imageBin find(type, size)
	}
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
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		result := match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(rasterImage as RasterMonochrome)
			case image: RasterBgr => this _createBgr(rasterImage as RasterBgr)
			case image: RasterBgra => this _createBgra(rasterImage as RasterBgra)
			case image: RasterUv => this _createUv(rasterImage as RasterUv)
			case image: RasterYuv420Semiplanar => this _createYuv420Semiplanar(rasterImage as RasterYuv420Semiplanar)
			case image: RasterYuv420Planar => this _createYuv420Planar(rasterImage as RasterYuv420Planar)
		}
		result
	}
	createSurface: func -> GpuSurface {
		result := this _surfaceBin find()
		if(result == null)
			result = OpenGLES3Surface create(this)
		result
	}
	update: func {
		this _backend swapBuffers()
	}
	setViewport: func (viewport: Viewport) {
		Fbo setViewport(viewport offset width, viewport offset height, viewport resolution width, viewport resolution height)
	}
}
