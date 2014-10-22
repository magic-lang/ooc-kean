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
	_imageBin: GpuImageBin
	_backend: Context
	init: func {
		this _backend = Context create()
		this _imageBin = GpuImageBin new()
	}
	init: func ~shared (other: This) {
		this _backend = Context create(other _backend)
		this _imageBin = GpuImageBin new()
	}
	init: func ~window (nativeWindow: NativeWindow) {
		this _backend = Context create(nativeWindow)
		this _imageBin = GpuImageBin new()
	}
	dispose: func {
		this _backend dispose()
		this _imageBin dispose()
	}
	recycle: func (gpuImage: GpuImage) {
		this _imageBin add(gpuImage)
	}
	getRecycled: func (type: GpuImageType, size: IntSize2D) -> GpuImage {
		result := this _imageBin find(type, size)
		result
	}
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Monochrome create(size, this)
		result
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Uv create(size, this)
		result
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Bgr create(size, this)
		result
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Bgra create(size, this)
		result
	}
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Yuv420Semiplanar create(size, this)
		result
	}
	createYuv420Planar: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Yuv420Planar create(size, this)
		result
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
}
