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
import math
import FloatExtension
import FloatPoint2D
import text/StringTokenizer
import structs/ArrayList

FloatPoint3D: cover {
	x, y, z: Float
	//Norm ::= (this x pow(2.0f) + this y pow(2.0f)) sqrt() // FIXME: Why does this syntax not work on a cover?
	Norm: Float { get { (this x pow(2.0f) + this y pow(2.0f) + this z pow(2.0f)) sqrt() } }
	//Azimuth ::= this y atan2(this x) // FIXME: Why does this syntax not work on a cover?
	Azimuth: Float { get { this y atan2(this x) } }
	Elevation: Float { 
		get { 
			r := this Norm
			if (r != 0.0f)
				r = (this z / r) clamp(-1.0f, 1.0f) acos()	
			r
		}
	}
	init: func@ (=x, =y, =z)
	init: func ~default { this init(0.0f, 0.0f, 0.0f) }
	init: func ~fromPoint2D (point: FloatPoint2D, z: Float) { this init(point x, point y, z) }
	
	pNorm: func (p: Float) -> Float {
		p == 1 ?
		this x abs() + this y abs() :
		(this x abs() pow(p) + this y abs() pow(p)) pow(1 / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y + this z * other z }
	vectorProduct: func (other: This) -> This { This new(this y * other z - other y * this z, -(this x * other z - other x * this z), this x * other y - other x * this y) }
	spherical: func (radius, azimuth, elevation: Float) -> This { 
		This new(radius * (azimuth cos()) * (elevation sin()), radius * (azimuth sin()) * (elevation sin()), radius * (elevation cos()))
	}
	angles: func (rx, ry, n: Float) -> This {
		z := n*n sqrt() / (1 + ry tan() pow(2.0f) + rx tan() pow(2.0f))
		This new(z * (ry tan()), z * (rx tan()), z)
	}
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this Norm * other Norm)) clamp(-1, 1) acos() * (this x * other y - this y * other x < 0 ? -1 : 1)
	}
	//FIXME: Oddly enough, "this - other" instead of "this + (-other)" causes a compile error in the unary '-' operator below.
	distance: func (other: This) -> Float { (this + (-other)) Norm }
	round: func -> This { This new(this x round(), this y round(), this z round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil(), this z ceil()) }
	floor: func -> This { This new(this x floor(), this y floor(), this z floor()) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y), this z minimum(ceiling z)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y), this z maximum(floor z)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z + other z) }
	operator - -> This { This new(-this x, -this y, -this z) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator == (other: This) -> Bool { this x == other x && this y == other y && this z == other z }
	operator != (other: This) -> Bool { this x != other x || this y != other y || this z != other z }
	operator < (other: This) -> Bool { this x < other x && this y < other y && this z < other z }
	operator > (other: This) -> Bool { this x > other x && this y > other y && this z > other z}
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y && this z <= other z }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y && this z >= other z }
	operator as -> String { this toString() }
	toString: func -> String { "#{this x toString()}, #{this y toString()}, #{this z toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toFloat(), array[1] toFloat(), array[2] toFloat())
	}
}
operator * (left: Float, right: FloatPoint3D) -> FloatPoint3D { FloatPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: FloatPoint3D) -> FloatPoint3D { FloatPoint3D new(left / right x, left / right y, left / right z) }
operator * (left: Int, right: FloatPoint3D) -> FloatPoint3D { FloatPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: FloatPoint3D) -> FloatPoint3D { FloatPoint3D new(left / right x, left / right y, left / right z) }
