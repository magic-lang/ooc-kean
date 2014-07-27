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
import ../../IntExtension
import IntPoint2D
import IntSize2D
import IntShell2D
import text/StringTokenizer
import structs/ArrayList

IntBox2D: cover {
	leftTop: IntPoint2D
	size: IntSize2D
	Width: Int { get { (this size width) } }
	Height: Int { get { this size height } }
	Left: Int { get { this leftTop x } }
	Top: Int { get { this leftTop y } }
	Right: Int { get { this leftTop x + this size width } }
	Bottom: Int { get { this leftTop y + this size height } }
	RightTop: IntPoint2D { get { IntPoint2D new(this Right, this Top) } }
	LeftBottom: IntPoint2D { get { IntPoint2D new(this Left, this Bottom) } }
	RightBottom: IntPoint2D { get { this leftTop + this size } }
	Center: IntPoint2D { get { this leftTop + (this size / 2) } }
	Empty: Bool { get { this size Empty } }
	init: func@ (=leftTop, =size)
	init: func@ ~fromFloats (left, top, width, height: Int) { this init(IntPoint2D new(left, top), IntSize2D new(width, height)) }
	init: func@ ~fromSize (size: IntSize2D) { this init(IntPoint2D new(), size) }
	init: func@ ~default { this init(IntPoint2D new(), IntSize2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Int) -> This {
		This new(IntPoint2D new(this Left - left, this Top - top), IntSize2D new(this Width + left + right, this Height + top + bottom))
	}
	pad: func ~fromFloat (pad: Int) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: IntSize2D) -> This { this pad(pad width, pad width, pad height, pad height) }
	intersection: func (other: This) -> This {
		left := this Left > other Left ? this Left : other Left
		top := this Top > other Top ? this Top : other Top
		width := ((this Right < other Right ? this Right : other Right) - left) maximum(0)
		height := ((this Bottom < other Bottom ? this Bottom : other Bottom) - top) maximum(0)
		This new(left, top, width, height)
	}
	//FIXME: Union is a keyword in C and so cannot be used for methods, but the name should be box__union something, so there shouldn't be a problem. Compiler bug?
	union: func ~box (other: This) -> This {
		left := this Left minimum(other Left)
		top := this Top minimum(other Top)
		width := this Right maximum(other Right) - this Left minimum(other Left) 
		height := this Bottom maximum(other Bottom) - this Top minimum(other Top)
		This new(left, top, width, height)
	}
	contains: func (point: IntPoint2D) -> Bool {
		this Left <= point x && point x < this Right && this Top <= point y && point y < this Bottom
	}
	contains: func ~box (box: IntBox2D) -> Bool { this intersection(box) == box }
	operator + (other: This) -> This {
		if (this Empty)
			other
		else if (other Empty)
			this
		else
			This new(this Left minimum(other Left),
				this Top minimum (other Top),
				this Right maximum(other Right) - this Left minimum(other Left),
				this Bottom maximum(other Bottom) - this Top minimum(other Top)
			)
	}
	operator - (other: This) -> This {
		if (this Empty || other Empty)
			This new()
		else {
			left := this Left maximum(other Left)
			right := this Right minimum(other Right)
			top := this Top maximum(other Top)
			bottom := this Bottom minimum(other Bottom)
			if (left < right && top < bottom)
				This new(left, top, right-left, bottom-top)
			else
				This new()
		}
	}
	operator + (other: IntPoint2D) -> This { This new(this leftTop + other, this size) }
	//FIXME: Unary minus bug
	operator - (other: IntPoint2D) -> This { This new(this leftTop + (-other), this size) }
	operator + (other: IntSize2D) -> This { This new(this leftTop, this size + other) }
	//FIXME: Unary minus bug again
	operator - (other: IntSize2D) -> This { This new(this leftTop, this size + (-other)) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toInt(), array[1] toInt(), array[2] toInt(), array[3] toInt())
	}
	create: func (leftTop: IntPoint2D, size: IntSize2D) -> This { This new(leftTop, size) }
	create: func ~fromFloats (left, top, width, height: Int) -> This { This new(left, top, width, height) }
	createAround: func (center: IntPoint2D, size: IntSize2D) -> This { This new(center + (-size) / 2, size) }
	bounds: func (left, right, top, bottom: Int) -> This { This new(left, top, right - left, bottom - top) }
	bounds: func ~fromArray (points: IntPoint2D[]) -> IntBox2D { this bounds(points as ArrayList<IntPoint2D>) }
	bounds: func ~fromList (points: ArrayList<IntPoint2D>) -> IntBox2D {
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
