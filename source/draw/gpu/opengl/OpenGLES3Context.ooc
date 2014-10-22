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

use ooc-math
use ooc-draw
use ooc-draw-gpu
import GpuImageBin, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3/Context, OpenGLES3/NativeWindow

OpenGLES3Context: class extends GpuContext {
	_backend: Context
	init: func {
		super()
		this _backend = Context create()
	}
	init: func ~shared (other: This) {
		super()
		this _backend = Context create(other _backend)
	}
	init: func ~window (nativeWindow: NativeWindow) {
		super()
		this _backend = Context create(nativeWindow)
	}
	dispose: func {
		this _backend dispose()
		this _imageBin dispose()
	}
	recycle: func ~image (gpuImage: GpuImage) {
		this _imageBin add(gpuImage)
	}
	recycle: func ~surface (surface: GpuSurface) {
		this _surfaceBin add(surface)
	}
	getImage: func (type: GpuImageType, size: IntSize2D) -> GpuImage {
		this _imageBin find(type, size)
	}
	getSurface: func -> GpuSurface {
		this _surfaceBin find()
	}
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Monochrome create(size, this)
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Uv create(size, this)
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Bgr create(size, this)
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Bgra create(size, this)
	}
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Yuv420Semiplanar create(size, this)
	}
	createYuv420Planar: func (size: IntSize2D) -> GpuImage {
		OpenGLES3Yuv420Planar create(size, this)
	}
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		result := match (rasterImage) {
			case image: RasterMonochrome => OpenGLES3Monochrome create(rasterImage as RasterMonochrome, this)
			case image: RasterBgr => OpenGLES3Bgr create(rasterImage as RasterBgr, this)
			case image: RasterBgra => OpenGLES3Bgra create(rasterImage as RasterBgra, this)
			case image: RasterUv => OpenGLES3Uv create(rasterImage as RasterUv, this)
			case image: RasterYuv420Semiplanar => OpenGLES3Yuv420Semiplanar create(rasterImage as RasterYuv420Semiplanar, this)
			case image: RasterYuv420Planar => OpenGLES3Yuv420Planar create(rasterImage as RasterYuv420Planar, this)
		}
		result
	}
	update: func {
		this _backend swapBuffers()
	}
	toRaster: func (gpuImage: GpuImage) {
		raise("Not implemented")
	}
}
