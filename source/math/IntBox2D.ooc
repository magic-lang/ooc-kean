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
import IntPoint2D
import IntSize2D
import FloatPoint2D
import FloatBox2D
import text/StringTokenizer
import structs/ArrayList
use ooc-math

IntBox2D: cover {
	leftTop: IntPoint2D
	size: IntSize2D
	width ::= this size width
	height ::= this size height
	left ::= this leftTop x
	top ::= this leftTop y
	right ::= this leftTop x + this size width
	bottom ::= this leftTop y + this size height
	rightTop ::= IntPoint2D new(this right, this top)
	leftBottom ::= IntPoint2D new(this left, this bottom)
	rightBottom ::= this leftTop + this size
	center ::= this leftTop + (this size / 2)
	leftCenter ::= IntPoint2D new(this left, this center y)
	rightCenter ::= IntPoint2D new(this right, this center y)
	topCenter ::= IntPoint2D new(this center x, this top)
	bottomCenter ::= IntPoint2D new(this center x, this bottom)
	empty ::= this size empty
	init: func@ (=leftTop, =size)
	init: func@ ~fromSizes (leftTop: IntSize2D, =size) { this leftTop = IntPoint2D new(leftTop width, leftTop height) }
	init: func@ ~fromSize (=size) { this leftTop = IntPoint2D new() }
	init: func@ ~fromInts (left, top, width, height: Int) { this init(IntPoint2D new(left, top), IntSize2D new(width, height)) }
	//init: func@ ~fromSize (size: IntSize2D) { this init(IntPoint2D new(), size) }
	init: func@ ~fromPoints (first, second: IntPoint2D) {
		left := Int minimum~two(first x, second x)
		top := Int minimum~two(first y, second y)
		width := (first x - second x) abs()
		height := (first y - second y) abs()
		this init(left, top, width, height)
	}
	init: func@ ~default { this init(IntPoint2D new(), IntSize2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Int) -> This {
		This new(IntPoint2D new(this left - left, this top - top), IntSize2D new(this width + left + right, this height + top + bottom))
	}
	pad: func ~fromFloat (pad: Int) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: IntSize2D) -> This { this pad(pad width, pad width, pad height, pad height) }
	intersection: func (other: This) -> This {
		left := Int maximum~two(this left, other left)
		top := Int maximum~two(this top, other top)
		width := Int maximum~two(0, Int minimum~two(this right, other right) - left)
		height := Int maximum~two(0, Int minimum~two(this bottom, other bottom) - top)
		This new(left, top, width, height)
	}
	//FIXME: Union is a keyword in C and so cannot be used for methods, but the name should be box__union something, so there shouldn't be a problem. Compiler bug?
	union: func ~box (other: This) -> This {
		left := Int minimum~two(this left, other left)
		top := Int minimum~two(this top, other top)
		width := Int maximum~two(0, Int maximum(this right, other right) - left)
		height := Int maximum~two(0, Int maximum(this bottom, other bottom) - top)
		This new(left, top, width, height)
	}
	contains: func (point: IntPoint2D) -> Bool {
		this left <= point x && point x < this right && this top <= point y && point y < this bottom
	}
	contains: func ~float (point: FloatPoint2D) -> Bool {
		this left <= point x && point x < this right && this top <= point y && point y < this bottom
	}
	contains: func ~box (box: This) -> Bool { this intersection(box) == box }
	operator + (other: This) -> This {
		if (this empty)
			other
		else if (other empty)
			this
		else
			union(other)
	}
	operator - (other: This) -> This {
		if (this empty || other empty)
			This new()
		else
			intersection(other)
	}
	operator + (other: IntPoint2D) -> This { This new(this leftTop + other, this size) }
	//FIXME: Unary minus bug
	operator - (other: IntPoint2D) -> This { This new(this leftTop + (-other), this size) }
	operator + (other: IntSize2D) -> This { This new(this leftTop, this size + other) }
	//FIXME: Unary minus bug again
	operator - (other: IntSize2D) -> This { This new(this leftTop, this size + (-other)) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	toFloatBox2D: func -> FloatBox2D { FloatBox2D new(this left, this top, this width, this height) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toInt(), array[1] toInt(), array[2] toInt(), array[3] toInt())
	}
	create: static func (leftTop: IntPoint2D, size: IntSize2D) -> This { This new(leftTop, size) }
	create: static func ~fromFloats (left, top, width, height: Int) -> This { This new(left, top, width, height) }
	createAround: static func (center: IntPoint2D, size: IntSize2D) -> This { This new(center + (-size) / 2, size) }
	bounds: func (left, right, top, bottom: Int) -> This { This new(left, top, right - left, bottom - top) }
	bounds: func ~fromArray (points: IntPoint2D[]) -> This { this bounds(points as ArrayList<IntPoint2D>) }
	bounds: func ~fromList (points: ArrayList<IntPoint2D>) -> This {
		xMinimum := 0
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
