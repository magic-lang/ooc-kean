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
import GpuImage, GpuMap, Surface, GpuMonochrome, GpuBgra, GpuBgr, GpuYuv420, GpuPlanar

GpuCanvas: abstract class extends Surface {

  _monochromeToMonochrome: static const GpuMapMonochrome
  _bgrToBgr: static const GpuMapBgr
  _bgraToBgra: static const GpuMapBgra

  init: func (=ratio) {
    if(This _monochromeToMonochrome == null)
      This _monochromeToMonochrome = GpuMapMonochrome new()
    if(This _bgrToBgr == null)
      This _bgrToBgr = GpuMapBgr new()
    if(This _bgraToBgra == null)
      This _bgraToBgra = GpuMapBgra new()
  }
  dispose: abstract func
}

GpuCanvasPlanar: class extends GpuCanvas {
  _y: GpuCanvasPacked
  _u: GpuCanvasPacked
  _v: GpuCanvasPacked

  init: func (ratio: UInt) {
    super(ratio)
  }
  dispose: func {
    this _y dispose()
    this _u dispose()
    this _v dispose()
  }
  draw: func ~Yuv420 (image: GpuYuv420, transform: FloatTransform2D) {
    GpuCanvas _monochromeToMonochrome transform = transform
    GpuCanvas _monochromeToMonochrome ratio = this ratio
    _y draw(image y, GpuCanvas _monochromeToMonochrome)
    _u draw(image u, GpuCanvas _monochromeToMonochrome )
    _v draw(image v, GpuCanvas _monochromeToMonochrome )
  }
  clear: func
  bind: func
  _generate: func (image: GpuPlanar) -> Bool {
    this quad = Quad create(this ratio)
    this _y = GpuCanvasPacked create(image y)
    this _u = GpuCanvasPacked create(image u)
    this _v = GpuCanvasPacked create(image v)

    this quad != null && this _y != null && this _u != null && this _v != null
  }
  create: static func (image: GpuPlanar) -> This {
    result := This new((image size width) as Float / (image size height) as Float)
    result _generate(image) ? result : null
    result
  }
}

GpuCanvasPacked: class extends GpuCanvas {
  _renderTarget: Fbo

  init: func (ratio: UInt) {
    super(ratio)
  }
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
    result _renderTarget = Fbo create(image textures, image size width, image size height)
    result quad = Quad create(result ratio)
    result _renderTarget != null ? result : null
  }
}
