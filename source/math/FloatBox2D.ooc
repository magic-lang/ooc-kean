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
import FloatPoint2D
import FloatSize2D
import IntBox2D
import FloatPoint2DVectorList
import structs/ArrayList
use ooc-collections

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
	leftCenter ::= FloatPoint2D new(this left, this center y)
	rightCenter ::= FloatPoint2D new(this right, this center y)
	topCenter ::= FloatPoint2D new(this center x, this top)
	bottomCenter ::= FloatPoint2D new(this center x, this bottom)
	empty ::= this size empty
	init: func@ (=leftTop, =size)
	init: func@ ~fromIntBox2D (box: IntBox2D) { this init(box left, box top, box width, box height) }
	init: func@ ~fromPoints (first, second: FloatPoint2D) {
		left := Float minimum(first x, second x)
		top := Float minimum(first y, second y)
		width := (first x - second x) abs()
		height := (first y - second y) abs()
		this init(left, top, width, height)
	}
	init: func@ ~fromFloats (left, top, width, height: Float) { this init(FloatPoint2D new(left, top), FloatSize2D new(width, height)) }
	init: func@ ~fromSize (size: FloatSize2D) { this init(FloatPoint2D new(), size) }
	init: func@ ~default { this init(FloatPoint2D new(), FloatSize2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Float) -> This {
		This new(FloatPoint2D new(this left - left, this top - top), FloatSize2D new(this width + left + right, this height + top + bottom))
	}
	pad: func ~fromFloat (pad: Float) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: FloatSize2D) -> This { this pad(pad width, pad width, pad height, pad height) }
	pad: func ~fraction (pad: Float) -> This {
		this pad(pad * this size / 2.0f)
	}
	padFractionAverage: func (pad: Float) -> This {
		this pad(pad * (this size width + this size height) / 2.0f)
	}
	shrink: func ~fraction (margin: Float) -> This {
		this pad(-margin * this height / 2.0f)
	}
	resizeTo: func (size: FloatSize2D) -> This {
		This createAround(this center, size)
	}
	scale: func (value: Float) -> This {
		This createAround(this center, value * this size)
	}
	enlargeTo: func (size: FloatSize2D) -> This {
		This createAround(this center, FloatSize2D maximum(this size, size))
	}
	shrinkTo: func (size: FloatSize2D) -> This {
		This createAround(this center, FloatSize2D minimum(this size, size))
	}
	intersection: func (other: This) -> This {
		left := Float maximum(this left, other left)
		top := Float maximum(this top, other top)
		width := Float maximum(0, (Float minimum(this right, other right) - left))
		height := Float maximum(0, (Float minimum(this bottom, other bottom) - top))
		This new(left, top, width, height)
	}
	union: func ~box (other: This) -> This { // Rock bug: Union without suffix cannot be used because the C name conflicts with keyword "union"
		left := Float minimum(this left, other left)
		top := Float minimum(this top, other top)
		width := Float maximum(0, (Float maximum(this right, other right) - left))
		height := Float maximum(0, (Float maximum(this bottom, other bottom) - top))
		This new(left, top, width, height)
	}
	union: func ~point (point: FloatPoint2D) -> This {
		left := Float minimum(this left, point x)
		top := Float minimum(this top, point y)
		width := Float maximum(0, Float maximum(this right, point x) - left)
		height := Float maximum(0, Float maximum(this bottom, point y) - top)
		This new(left, top, width, height)
	}
	contains: func (point: FloatPoint2D) -> Bool {
		this left <= point x && point x <= this right && this top <= point y && point y <= this bottom
	}
	contains: func ~box (box: This) -> Bool { this intersection(box) == box }
	contains: func ~FloatPoint2DVectorList (list: FloatPoint2DVectorList) -> VectorList<Int> {
		result := VectorList<Int> new()
		for (i in 0 .. list count)
			if (this contains(list[i]))
				result add(i)
		result
	}
	round: func -> This { This new(this leftTop round(), this size round()) }
	ceiling: func -> This { This new(this leftTop ceiling(), this size ceiling()) }
	floor: func -> This { This new(this leftTop floor(), this size floor()) }
	operator + (other: This) -> This {
		if (this empty)
			other
		else if (other empty)
			this
		else
			this union(other)
	}
	operator - (other: This) -> This {
		if (this empty || other empty)
			This new()
		else
			this intersection(other)
	}
	operator + (other: FloatPoint2D) -> This { This new(this leftTop + other, this size) }
	operator - (other: FloatPoint2D) -> This { This new(this leftTop - other, this size) }
	operator + (other: FloatSize2D) -> This { This new(this leftTop, this size + other) }
	operator * (other: FloatSize2D) -> This { This new(this leftTop * other, this size * other) }
	operator / (other: FloatSize2D) -> This { This new(this leftTop / other, this size / other) }
	operator - (other: FloatSize2D) -> This { This new(this leftTop, this size - other) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	toIntBox2D: func -> IntBox2D { IntBox2D new(this left, this top, this width, this height) }
	operator as -> String { this toString() }
	adaptTo: func (other: This, weight: Float) -> This {
		newCenter := FloatPoint2D linearInterpolation(this center, other center, weight)
		newSize := FloatSize2D linearInterpolation(this size, other size, weight)
		this createAround(newCenter, newSize)
	}
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toFloat(), array[1] toFloat(), array[2] toFloat(), array[3] toFloat())
	}
	create: static func (leftTop: FloatPoint2D, size: FloatSize2D) -> This { This new(leftTop, size) }
	create: static func ~fromFloats (left, top, width, height: Float) -> This { This new(left, top, width, height) }
	createAround: static func (center: FloatPoint2D, size: FloatSize2D) -> This { This new(center + (-size) / 2, size) }
	bounds: static func (left, right, top, bottom: Float) -> This { This new(left, top, right - left, bottom - top) }
	bounds: static func ~fromArray (points: FloatPoint2D[]) -> This { This bounds(points as ArrayList<FloatPoint2D>) }
	bounds: static func ~fromList (points: ArrayList<FloatPoint2D>) -> This {
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
