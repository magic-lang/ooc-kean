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
import GpuImage, GpuCanvas, GpuContext

GpuPacked: abstract class extends GpuImage {
	init: func (size: IntSize2D, channels: Int, context: GpuContext) {
		super(size, channels, context)
	}
	toRasterDefault: func ~overwrite (rasterImage: RasterPacked) {
		raster := this toRaster() as RasterPacked
		memcpy(rasterImage buffer pointer, raster buffer pointer, raster buffer size)
		raster referenceCount decrease()
	}
}
