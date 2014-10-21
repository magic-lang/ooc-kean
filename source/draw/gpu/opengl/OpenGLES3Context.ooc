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
import OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3/Context, OpenGLES3/NativeWindow

OpenGLES3Context: class extends GpuContext {
	_backend: Context
	init: func (nativeWindow: NativeWindow) {
		this _backend = Context create(nativeWindow)
		res := this _backend makeCurrent()
	}
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Monochrome create2(size)
		result
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Bgr create2(size)
		result
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Bgra create2(size)
		result
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Uv create2(size)
		result
	}
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Yuv420Semiplanar create2(size)
		result
	}
	createYuv420Planar: func (size: IntSize2D) -> GpuImage {
		result := OpenGLES3Yuv420Planar create2(size)
		result
	}
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		result := match (rasterImage) {
			case image: RasterMonochrome => OpenGLES3Monochrome createStatic(rasterImage as RasterMonochrome)
			case image: RasterBgr => OpenGLES3Bgr createStatic(rasterImage as RasterBgr)
			case image: RasterBgra => OpenGLES3Bgra createStatic(rasterImage as RasterBgra)
			case image: RasterUv => OpenGLES3Uv createStatic(rasterImage as RasterUv)
			case image: RasterYuv420Semiplanar => OpenGLES3Yuv420Semiplanar createStatic(rasterImage as RasterYuv420Semiplanar)
			case image: RasterYuv420Planar => OpenGLES3Yuv420Planar createStatic(rasterImage as RasterYuv420Planar)
		}
		result
	}
	update: func {
		this _backend swapBuffers()
	}
}
