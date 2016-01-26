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

import Color

Pen: cover {
	color: ColorBgra { get set }
	width: Float { get set }
	alpha ::= this color alpha
	alphaAsFloat ::= this alpha as Float / 255.0
	init: func@ (=color, =width)
	init: func@ ~color (color: ColorBgra) { this init(color, 1.0f) }
	init: func@ ~default { this init(ColorBgra new(0, 0, 0, 255)) }
	init: func@ ~withBgr (colorBgr: ColorBgr) { this init(colorBgr toBgra()) }
	setAlpha: func@ (alpha: Byte) {
		this color = ColorBgra new(this color toBgr(), alpha)
	}
	setAlpha: func@ ~withFloat (value: Float) {
		this color = ColorBgra new(this color toBgr(), value * 255)
	}
}
