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

Viewport: class {
	resolution: IntSize2D { get set }
	offset: IntSize2D { get set }
	init: func (offsetX: Int, offsetY: Int, resolutionX: Int, resolutionY: Int) {
		this resolution = IntSize2D new(resolutionX, resolutionY)
		this offset = IntSize2D new(offsetX, offsetY)
	}
	init: func ~resolutionOnly (resolution: IntSize2D) {
		this resolution = resolution
		this offset = IntSize2D new()
	}
	init: func ~both (=offset, =resolution)
	toString: func -> String {
		"Resolution: " + this resolution toString() + " Offset: " + this offset toString()
	}
}
