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

rasterImageYuv420 := RasterYuv420Planar new(rasterImageBgra)
rasterImageYuv420Semiplanar := RasterYuv420Semiplanar new(rasterImageBgra)

gpuYuv420Planar := GpuImage create(rasterImageYuv420)
gpuYuv420Semiplanar := GpuImage create(rasterImageYuv420Semiplanar)
while(true) {
  transform = transform rotate(rotation)
  window draw(gpuYuv420Semiplanar, transform)
  //Update must be called before a redraw
  window update()
}
