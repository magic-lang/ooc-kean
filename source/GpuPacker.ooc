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
use ooc-base
import OpenGLES3/Fbo, OpenGLES3/Texture, OpenGLES3/Context, OpenGLES3/Quad
import GpuImage, GpuMap, Surface, GpuMonochrome, GpuBgra, GpuBgr, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar

GpuPacker: abstract class extends Surface {
  _packMonochrome: static GpuMapPackMonochrome
  _packUv: static GpuMapPackUv
  _renderTarget: Fbo
  _targetTexture: Texture
  init: func {
    if(This _packMonochrome == null)
      This _packMonochrome = GpuMapPackMonochrome new()
    if(This _packUv == null)
      This _packUv = GpuMapPackUv new()
    this _quad = Quad create()
  }
  dispose: func {
    this _targetTexture dispose()
    this _renderTarget dispose()
    if(This _packMonochrome != null)
      This _packMonochrome dispose()
  }
  pack: func ~monochrome (image: GpuMonochrome, context: Context) -> Pointer {
    This _packMonochrome transform = FloatTransform2D identity
    This _packMonochrome size = image size
    this draw(image, This _packMonochrome)
    result := context getEGLBuffer(this _targetTexture _eglImage)
    result
  }
  pack: func ~uv (image: GpuUv, context: Context) -> Pointer {
    This _packUv transform = FloatTransform2D identity
    This _packUv size = image size
    this draw(image, This _packUv)
    result := context getEGLBuffer(this _targetTexture _eglImage)
    result
  }
  _bind: func {
    this _renderTarget bind()
  }
  _unbind: func {
    this _renderTarget unbind()
  }
  _clear: func {
    this _renderTarget clear()
  }
  _update: func {
    Fbo finish()
  }
}

GpuPackerY: class extends GpuPacker {
  init: func {
    super()
  }
  initialize: func (context: Context) {
    this _targetTexture = Texture createEGL(1920 / 4, 1080, context)
    this _renderTarget = Fbo create(this _targetTexture, 1920 / 4, 1080)
  }

  create: static func (context: Context) -> This {
    result := This new()
    result initialize(context)
    result
  }
}

GpuPackerUv: class extends GpuPacker {
    init: func {
    super()
  }
    initialize: func (context: Context) {
    this _targetTexture = Texture createEGL(1920 / 4, 1080 / 2, context)
    this _renderTarget = Fbo create(this _targetTexture, 1920 / 4, 1080 / 2)
  }
  create: static func (context: Context) -> This {
    result := This new()
    result initialize(context)
    result
  }
}

GpuPackerU: class extends GpuPacker {
    init: func {
    super()
  }
    initialize: func (context: Context) {
    this _targetTexture = Texture createEGL(1920 / 4, 1080 / 4, context)
    this _renderTarget = Fbo create(this _targetTexture, 1920 / 4, 1080 / 4)
  }
  create: static func (context: Context) -> This {
    result := This new()
    result initialize(context)
    result
  }
}
