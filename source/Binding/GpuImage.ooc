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

use ooc-draw
use ooc-math
import GpuBgra, GpuBgr, GpuMonochrome, GpuYuv420, GpuCanvas, OpenGLES3/Texture

GpuImage: abstract class extends Image {
  _textures: Texture[]
  textures: Texture[] { get { _textures } }

  init: func (=size)
  bind: abstract func
  create: static func ~Monochrome (image: RasterMonochrome) -> GpuMonochrome {
    GpuMonochrome create(image size, image pointer)
  }
  create: static func ~Bgr (image: RasterBgr) -> GpuBgr {
    GpuBgr create(image size, image pointer)
  }
  create: static func ~Bgra (image: RasterBgra) -> GpuBgra {
    GpuBgra create(image size, image pointer)
  }
  create: static func ~Yuv420 (image: RasterYuv420) -> GpuYuv420 {
    GpuYuv420 create(image size, image y pointer, image u pointer, image v pointer)
  }

  //TODO: Implement abstract functions
  resizeTo: func (size: IntSize2D) -> This {null}
  copy: func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This {null}
  shift: func (offset: IntSize2D) -> This {null}
  distance: func (other: This) -> Float {0.0f}

}
