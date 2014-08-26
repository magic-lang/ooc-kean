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

transform := FloatTransform2D identity
rotation := 0.01f

screenSize := IntSize2D new (1680.0f, 1050.0f)
window := Window create(screenSize, "GL Test")

rasterImageMonochrome := RasterMonochrome open("input/test.png")
gpuMonochrome := GpuImage create(rasterImageMonochrome)

rasterImageBgr := RasterBgr open("input/Space.png")
gpuBgr := GpuImage create(rasterImageBgr)

rasterImageBgra := RasterBgra open("input/Space.png")
gpuBgra := GpuImage create(rasterImageBgra)

rasterImageYuv420 := RasterYuv420 new(rasterImageBgra)

gpuYv12 := GpuImage create(rasterImageYuv420)

gpuTarget := GpuYuv420 create(gpuYv12 size, null, null, null)
gpuTarget canvas draw(gpuYv12, transform)

gpuTargetMono := GpuMonochrome create(gpuMonochrome size, null)
gpuTargetMono canvas draw(gpuMonochrome, transform)


while(true) {
  transform = transform rotate(rotation)
  window draw(gpuTarget, transform)
  //Update must be called before a redraw
  window update()
}
