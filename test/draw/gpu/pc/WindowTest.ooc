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
use ooc-draw-gpu-pc
use ooc-draw

transform := FloatTransform2D identity
rotation := 0.01f

screenSize := IntSize2D new (1680.0f, 1050.0f)
window := Window create(screenSize, "GL Test")

//rasterImageMonochrome := RasterMonochrome open("../test/draw/input/Hercules.jpg")
//gpuMonochrome := window createGpuImage(rasterImageMonochrome)

rasterImageBgr := RasterBgr open("../test/draw/input/Space.png")
gpuBgr := window createGpuImage(rasterImageBgr)

gpuTarget := window createGpuImage(rasterImageBgr)
gpuTarget canvas draw(rasterImageBgr)

rasterImageBgra := RasterBgra open("../test/draw/input/Space.png")
gpuBgra := GpuImage create(rasterImageBgra, rasterImageBgra size)

//rasterImageYuv420Planar := RasterYuv420Planar new(rasterImageBgr)
//gpuYuv420Planar := GpuImage create(rasterImageYuv420Planar, rasterImageYuv420Planar size)

//rasterImageYuv420Semiplanar := RasterYuv420Semiplanar new(rasterImageBgra)
//gpuYuv420Semiplanar := GpuImage create(rasterImageYuv420Semiplanar, rasterImageYuv420Semiplanar size)

for(i in 0..300) {
	transform = transform translate(0, 0)
	//window draw(rasterImageBgr, transform)
	window draw(gpuTarget, transform)
}
