/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */
use ooc-math
use ooc-draw-gpu
use ooc-draw

import Binding/Canvas
import Binding/GpuMonochrome
import Binding/GpuBgra
import Binding/GpuBgr
import Binding/Window

window := Window create(IntSize2D new (1920/2, 1080/2), "GL Test")

rasterImage := RasterBgr open("input/Space.png")
gpuImage := GpuBgr create(rasterImage pointer, rasterImage size)

//rasterImage := RasterBgra open("input/Space.png")
//gpuImage := GpuBgra create(rasterImage pointer, rasterImage size)

//rasterImage := RasterMonochrome open("input/test.png")
//gpuImage := GpuMonochrome create(rasterImage pointer, rasterImage size)


while(true) {
  window draw(gpuImage, FloatTransform2D identity)
  //Update must be called before a redraw, else unstable
  window update()
}
