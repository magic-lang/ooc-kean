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

use ooc-base
use ooc-collections
use ooc-math
import IntPoint2D
import IntVector2D
import FloatPoint2D
import FloatBox2D

IntBox2D: cover {
	leftTop: IntPoint2D
	size: IntVector2D

	width ::= this size x
	height ::= this size y
	left ::= this leftTop x
	top ::= this leftTop y
	right ::= this leftTop x + this size x
	bottom ::= this leftTop y + this size y
	rightTop ::= IntPoint2D new(this right, this top)
	leftBottom ::= IntPoint2D new(this left, this bottom)
	rightBottom ::= this leftTop + this size
	center ::= this leftTop + (this size / 2)
	leftCenter ::= IntPoint2D new(this left, this center y)
	rightCenter ::= IntPoint2D new(this right, this center y)
	topCenter ::= IntPoint2D new(this center x, this top)
	bottomCenter ::= IntPoint2D new(this center x, this bottom)
	hasZeroArea ::= this size hasZeroArea
	area ::= this size area

	init: func@ (newLeftTop: IntPoint2D, newSize: IntVector2D) {
		if (newSize x < 0)
			newLeftTop x += newSize x
		if (newSize y < 0)
			newLeftTop y += newSize y
		this leftTop = newLeftTop
		this size = newSize absolute
	}
	init: func@ ~fromSizes (newLeftTop, newSize: IntVector2D) { this init(newLeftTop toIntPoint2D(), newSize) }
	init: func@ ~fromSize (newSize: IntVector2D) { this init(IntPoint2D new(), newSize) }
	init: func@ ~fromInts (left, top, width, height: Int) { this init(IntPoint2D new(left, top), IntVector2D new(width, height)) }
	init: func@ ~fromPoints (first, second: IntPoint2D) {
		left := first x minimum(second x)
		top := first y minimum(second y)
		width := (first x - second x) abs()
		height := (first y - second y) abs()
		this init(left, top, width, height)
	}
	init: func@ ~default { this init(IntPoint2D new(), IntVector2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Int) -> This {
		This new(IntPoint2D new(this left - left, this top - top), IntVector2D new(this width + left + right, this height + top + bottom))
	}
	pad: func ~fromFloat (pad: Int) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: IntVector2D) -> This { this pad(pad x, pad x, pad y, pad y) }
	resizeTo: func (size: IntVector2D) -> This {
		This createAround(this center, size)
	}
	scale: func (value: Float) -> This {
		This createAround(this center, value * this size)
	}
	enlargeTo: func (size: IntVector2D) -> This {
		This createAround(this center, this size maximum(size))
	}
	shrinkTo: func (size: IntVector2D) -> This {
		This createAround(this center, this size minimum(size))
	}
	intersection: func (other: This) -> This {
		left := this left maximum(other left)
		top := this top maximum(other top)
		width := 0 maximum(this right minimum(other right) - left)
		height := 0 maximum(this bottom minimum(other bottom) - top)
		This new(left, top, width, height)
	}
	union: func ~box (other: This) -> This { // Rock bug: Union without suffix cannot be used because the C name conflicts with keyword "union"
		left := this left minimum(other left)
		top := this top minimum(other top)
		width := 0 maximum(this right maximum(other right) - left)
		height := 0 maximum(this bottom maximum(other bottom) - top)
		This new(left, top, width, height)
	}
	union: func ~point (point: IntPoint2D) -> This {
		This new(this leftTop minimum(point), this rightBottom maximum(point))
	}
	contains: func (point: IntPoint2D) -> Bool {
		this left <= point x && point x < this right && this top <= point y && point y < this bottom
	}
	contains: func ~float (point: FloatPoint2D) -> Bool {
		this left <= point x && point x < this right && this top <= point y && point y < this bottom
	}
	contains: func ~box (box: This) -> Bool { this intersection(box) == box }
	toFloatBox2D: func -> FloatBox2D { FloatBox2D new(this left, this top, this width, this height) }
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	toText: func -> Text { this leftTop toText() + t", " + this size toText() }

	operator + (other: This) -> This {
		if (this hasZeroArea)
			other
		else if (other hasZeroArea)
			this
		else
			union(other)
	}
	operator - (other: This) -> This { this hasZeroArea || other hasZeroArea ? This new() : this intersection(other) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: IntPoint2D) -> This { This new(this leftTop + other, this size) }
	operator - (other: IntPoint2D) -> This { This new(this leftTop - other, this size) }
	operator + (other: IntVector2D) -> This { This new(this leftTop, this size + other) }
	operator - (other: IntVector2D) -> This { This new(this leftTop, this size - other) }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toInt(), parts[1] toInt(), parts[2] toInt(), parts[3] toInt())
		parts free()
		result
	}
	createAround: static func (center: IntPoint2D, size: IntVector2D) -> This { This new(center - size / 2, size) }
	bounds: static func (left, right, top, bottom: Int) -> This { This new(left, top, right - left, bottom - top) }
	bounds: static func ~fromArray (points: IntPoint2D[]) -> This { This bounds(points data, points length) }
	bounds: static func ~fromList (points: VectorList<IntPoint2D>) -> This { This bounds(points pointer as IntPoint2D*, points count) }
	bounds: static func ~fromPointer (data: IntPoint2D*, count: Int) -> This {
		xMinimum := 0
		xMaximum := xMinimum
		yMinimum := xMinimum
		yMaximum := xMinimum
		initialized := false
		for (i in 0 .. count) {
			point := data[i]
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
