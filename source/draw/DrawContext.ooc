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
use base
use draw
use ooc-geometry

AlignWidth: enum {
	Nearest
	Floor
	Ceiling
}

DrawContext: abstract class {
	init: func
	createMonochrome: abstract func (size: IntVector2D) -> Image
	createBgr: abstract func (size: IntVector2D) -> Image
	createBgra: abstract func (size: IntVector2D) -> Image
	createUv: abstract func (size: IntVector2D) -> Image
	createImage: abstract func (rasterImage: RasterImage) -> Image
	createYuv420Semiplanar: abstract func (size: IntVector2D) -> Image
	createYuv420Semiplanar: abstract func ~fromImages (y, uv: Image) -> Image
	createYuv420Semiplanar: abstract func ~fromRaster (raster: RasterYuv420Semiplanar) -> Image
	alignWidth: virtual func (width: Int, align := AlignWidth Nearest) -> Int { width }
	update: abstract func
	isAligned: virtual func (width: Int) -> Bool { true }
}
