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
import math

//IColor: interface {
//	set: func (color: IColor)
//	asMonochrome: func -> ColorMonochrome
//	asBgr: func -> ColorBgr
//	asBgra: func -> ColorBgra
//	asYuv: func -> ColorYuv
//	copy: func -> IColor
//	blend: func (factor: Float, other: IColor) -> Color
//	distance: func (other: IColor) -> Float
//}

ColorMonochrome: cover {
	y: UInt8
	set: func (color: This) { 
		this y = color y
	}
	init: func@ (=y)
	init: func@ ~default { this init(0) }
	init: func@ ~int (i: Int) { this init(i as UInt8) }
	init: func@ ~float (f: Float) { this init(f*255.0f clamp(0.0f, 255.0f) as UInt8) }
	init: func@ ~double (d: Double) { this init(d*255.0f clamp(0.0f, 255.0f) as UInt8) }
	copy: func -> This { This new(this y) }
	asMonochrome: func -> This { this copy() }
	asBgr: func -> ColorBgr { ColorBgr new() }
	asBgra: func -> ColorBgra { ColorBgra new() }
	asYuv: func -> ColorYuv { ColorYuv new() }
	blend: func (factor: Float, other: This) -> This {
		This new((this y * (1 - factor) + (other y * factor)) as UInt8)
	}
	distance: func (other: This) -> Float {
		(this y - other y) as Float abs()
	}
}

ColorBgr: cover {
	blue, green, red: UInt8
	set: func (color: This) { 
		this blue = color blue
		this green = color green
		this red = color red
	}
	init: func@ (=blue, =green, =red)
	init: func@ ~default { this init(0, 0, 0) }
	init: func@ ~int (b, g, r: Int) { this init(b as UInt8, g as UInt8, r as UInt8) }
	init: func@ ~float (b, g, r: Float) { this init(b*255.0f clamp(0.0f, 255.0f) as UInt8, g*255.0f clamp(0.0f, 255.0f) as UInt8, r*255.0f clamp(0.0f, 255.0f) as UInt8) }
	init: func@ ~double (b, g, r: Double) { this init(b*255.0f clamp(0.0f, 255.0f) as UInt8, g*255.0f clamp(0.0f, 255.0f) as UInt8, r*255.0f clamp(0.0f, 255.0f) as UInt8) }
	copy: func -> This { This new(this blue, this green, this red) }
	asMonochrome: func -> ColorMonochrome { ColorMonochrome new() }
	asBgr: func -> This { this copy() }
	asBgra: func -> ColorBgra { ColorBgra new(this copy(), 255) }
	asYuv: func -> ColorYuv { ColorYuv new() }
	blend: func (factor: Float, other: This) -> This {
		This new((this blue * (1 - factor) + other blue * factor) as UInt8, (this green * (1 - factor) + other green * factor) as UInt8, (this red * (1 - factor) + other red * factor) as UInt8)
	}
	distance: func (other: This) -> Float {
		((this blue - other blue) as Float pow(2) + (this green - other green) as Float pow(2) + (this red - other red) as Float pow(2)) / 3.0f sqrt()
	}
}

ColorBgra: cover {
	bgr: ColorBgr
	alpha: UInt8
	set: func (color: This) { 
		this bgr = color bgr
		this alpha = color alpha
	}
	Blue: UInt8 { get { this bgr blue } set (value) { this bgr blue = value } }
	Green: UInt8 { get { this bgr green } set (value) { this bgr green = value } }
	Red: UInt8 { get { this bgr red } set (value) { this bgr red = value } }
	init: func@ (=bgr, =alpha)
	init: func@ ~default { this init(0, 0, 0, 0) }
	init: func@ ~uint8 (b, g, r, a: UInt8) { this init(ColorBgr new(b, g, r), a) }
	init: func@ ~int (b, g, r, a: Int) { this init(b as UInt8, g as UInt8, r as UInt8, a as UInt8) }
	init: func@ ~float (b, g, r, a: Float) { this init(ColorBgr new(b, g, r), a*255.0f clamp(0.0f, 255.0f) as UInt8) }
	init: func@ ~double (b, g, r, a: Double) { this init(ColorBgr new(b, g, r), a*255.0f clamp(0.0f, 255.0f) as UInt8) }
	copy: func -> This { This new(this bgr, this alpha) }
	asMonochrome: func -> ColorMonochrome { ColorMonochrome new() }
	asBgr: func -> ColorBgr { this bgr copy() }
	asBgra: func -> This { this copy() }
	asYuv: func -> ColorYuv { ColorYuv new() }
	blend: func (factor: Float, other: This) -> This {
		This new(this bgr blend(factor, other bgr), (this alpha * (1 - factor) + other alpha * factor) as UInt8)
	}
	distance: func (other: This) -> Float {
		(this bgr distance(other bgr) * 3.0f + (this alpha - other alpha) as Float pow(2)) / 4.0f sqrt()
	}
}

ColorYuv: cover {
	y, u, v: UInt8
	set: func (color: This) { 
		this y = color y
		this u = color u
		this v = color v
	}
	init: func@ (=y, =u, =v)
	init: func@ ~default { this init(0, 0, 0) }
	init: func@ ~int (y, u, v: Int) { this init(y as UInt8, u as UInt8, v as UInt8) }
	init: func@ ~float (y, u, v: Float) { this init(y*255.0f clamp(0.0f, 255.0f) as UInt8, u*255.0f clamp(0.0f, 255.0f) as UInt8, v*255.0f clamp(0.0f, 255.0f) as UInt8) }
	init: func@ ~double (y, u, v: Double) { this init(y*255.0f clamp(0.0f, 255.0f) as UInt8, u*255.0f clamp(0.0f, 255.0f) as UInt8, v*255.0f clamp(0.0f, 255.0f) as UInt8) }
	copy: func -> This { This new(this y, this u, this v) }
	asMonochrome: func -> ColorMonochrome { ColorMonochrome new() }
	asBgr: func -> ColorBgr { ColorBgr new() }
	asBgra: func -> ColorBgra { ColorBgra new() }
	asYuv: func -> This { this copy() }
	blend: func (factor: Float, other: This) -> This {
		This new((this y * (1 - factor) + other y * factor) as UInt8, (this u * (1 - factor) + other u * factor) as UInt8, (this v * (1 - factor) + other v * factor) as UInt8)
	}
	distance: func (other: This) -> Float {
		((this y - other y) as Float pow(2) + (this u - other u) as Float pow(2) + (this v - other v) as Float pow(2)) / 3.0f sqrt()
	}
}
