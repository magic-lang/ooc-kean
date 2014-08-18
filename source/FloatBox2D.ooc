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
import FloatSize2D
import FloatShell2D
import text/StringTokenizer
import structs/ArrayList

FloatBox2D: cover {
	leftTop: FloatPoint2D
	size: FloatSize2D
	width ::= this size width
	height ::= this size height
	left ::= this leftTop x
	top ::= this leftTop y
	right ::= this leftTop x + this size width
	bottom ::= this leftTop y + this size height
	rightTop ::= FloatPoint2D new(this right, this top)
	leftBottom ::= FloatPoint2D new(this left, this bottom)
	rightBottom ::= this leftTop + this size
	center ::= this leftTop + (this size / 2)
	empty ::= this size empty 
	init: func@ (=leftTop, =size)
	init: func@ ~fromFloats (left, top, width, height: Float) { this init(FloatPoint2D new(left, top), FloatSize2D new(width, height)) }
	init: func@ ~fromSize (size: FloatSize2D) { this init(FloatPoint2D new(), size) }
	init: func@ ~default { this init(FloatPoint2D new(), FloatSize2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Float) -> This {
		This new(FloatPoint2D new(this left - left, this top - top), FloatSize2D new(this width + left + right, this height + top + bottom))
	}
	pad: func ~fromFloat (pad: Float) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: FloatSize2D) -> This { this pad(pad width, pad width, pad height, pad height) }
	intersection: func (other: This) -> This {
		left := this left > other left ? this left : other left
		top := this top > other top ? this top : other top
		width := ((this right < other right ? this right : other right) - left) maximum(0.0f)
		height := ((this bottom < other bottom ? this bottom : other bottom) - top) maximum(0.0f)
		This new(left, top, width, height)
	}
	//FIXME: Union is a keyword in C and so cannot be used for methods, but the name should be box__union something, so there shouldn't be a problem. Compiler bug?
	union: func ~box (other: This) -> This {
		left := this left minimum(other left)
		top := this top minimum(other top)
		width := this right maximum(other right) - this left minimum(other left) 
		height := this bottom maximum(other bottom) - this top minimum(other top)
		This new(left, top, width, height)
	}
	contains: func (point: FloatPoint2D) -> Bool {
		this left <= point x && point x < this right && this top <= point y && point y < this bottom
	}
	contains: func ~box (box: FloatBox2D) -> Bool { this intersection(box) == box }
	round: func -> This { This new(this leftTop round(), this size round()) }
	ceiling: func -> This { This new(this leftTop ceiling(), this size ceiling()) }
	floor: func -> This { This new(this leftTop floor(), this size floor()) }
	
	operator + (other: This) -> This {
		if (this empty)
			other
		else if (other empty)
			this
		else
			This new(this left minimum(other left),
				this top minimum (other top),
				this right maximum(other right) - this left minimum(other left),
				this bottom maximum(other bottom) - this top minimum(other top)
			)
	}
	operator - (other: This) -> This {
		if (this empty || other empty)
			This new()
		else {
			left := this left maximum(other left)
			right := this right minimum(other right)
			top := this top maximum(other top)
			bottom := this bottom minimum(other bottom)
			if (left < right && top < bottom)
				This new(left, top, right-left, bottom-top)
			else
				This new()
		}
	}
	operator + (other: FloatPoint2D) -> This { This new(this leftTop + other, this size) }
	//FIXME: Unary minus bug
	operator - (other: FloatPoint2D) -> This { This new(this leftTop - other, this size) }
	operator + (other: FloatSize2D) -> This { This new(this leftTop, this size + other) }
	//FIXME: Unary minus bug again
	operator - (other: FloatSize2D) -> This { This new(this leftTop, this size - other) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toFloat(), array[1] toFloat(), array[2] toFloat(), array[3] toFloat())
	}
	create: func (leftTop: FloatPoint2D, size: FloatSize2D) -> This { This new(leftTop, size) }
	create: func ~fromFloats (left, top, width, height: Float) -> This { This new(left, top, width, height) }
	createAround: func (center: FloatPoint2D, size: FloatSize2D) -> This { This new(center + (-size) / 2, size) }
	bounds: static func (left, right, top, bottom: Float) -> This { This new(left, top, right - left, bottom - top) }
	bounds: static func ~fromArray (points: FloatPoint2D[]) -> FloatBox2D { This bounds(points as ArrayList<FloatPoint2D>) }
	bounds: static func ~fromList (points: ArrayList<FloatPoint2D>) -> FloatBox2D {
		xMinimum := 0.0f
		xMaximum := xMinimum
		yMinimum := xMinimum
		yMaximum := xMinimum
		initialized := false
		for (point in points) {
			if (!initialized) {
				initialized = true
				xMinimum = point x
				xMaximum = point x
				yMinimum = point y
				yMaximum = point y
			} else {
				if (point x < xMinimum)
					xMinimum = point x
				else if (point x > xMaximum)
					xMaximum = point x
				if (point y < yMinimum)
					yMinimum = point y
				else if (point y > yMaximum)
					yMaximum = point y
			}
		}
		This new(xMinimum, yMinimum, xMaximum - xMinimum, yMaximum - yMinimum)
	}
}
