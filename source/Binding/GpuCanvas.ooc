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
import OpenGLES3/Fbo, OpenGLES3/Quad
import GpuImage, GpuMap, Surface, GpuMonochrome, GpuBgra, GpuBgr, GpuYuv420

GpuCanvas: class extends Surface {
  _renderTarget: Fbo

  _monochromeToMonochrome: static const GpuMapMonochrome
  _bgrToBgr: static const GpuMapBgr
  _bgraToBgra: static const GpuMapBgra
  _yuvToYuv: static const GpuMapYuv

  init: func (=ratio)

  dispose: func {
    this _renderTarget dispose()
  }

  draw: func ~Monochrome (image: GpuMonochrome, transform: FloatTransform2D) {
    This _monochromeToMonochrome transform = transform
    This _monochromeToMonochrome ratio = this ratio
    this draw(image, This _monochromeToMonochrome)
  }

  draw: func ~Bgr (image: GpuBgr, transform: FloatTransform2D) {
    This _bgrToBgr transform = transform
    This _bgrToBgr ratio = this ratio
    this draw(image, This _bgrToBgr)
  }

  draw: func ~Bgra (image: GpuBgra, transform: FloatTransform2D) {
    This _bgraToBgra transform = transform
    This _bgraToBgra ratio = this ratio
    this draw(image, This _bgraToBgra)
  }

  draw: func ~Yuv420 (image: GpuYuv420, transform: FloatTransform2D) {
    This _yuvToYuv transform = transform
    This _yuvToYuv ratio = this ratio
    this draw(image, This _yuvToYuv)
  }

  bind: func {
    this _renderTarget bind()
  }

  unbind: func {
    this _renderTarget unbind()
  }

  clear: func {
    this _renderTarget clear()
  }

  create: static func (image: GpuImage) -> This {
    result := This new((image size width) as Float / (image size height) as Float)
    result _renderTarget = Fbo create(image textures)
    result quad = Quad create(result ratio)

    if(This _monochromeToMonochrome == null)
      This _monochromeToMonochrome = GpuMapMonochrome new()
    if(This _bgrToBgr == null)
      This _bgrToBgr = GpuMapBgr new()
    if(This _bgraToBgra == null)
      This _bgraToBgra = GpuMapBgra new()
    if(This _yuvToYuv == null)
      This _yuvToYuv = GpuMapYuv new()

    result _renderTarget != null ? result : null
  }

}
