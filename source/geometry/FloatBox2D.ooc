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
use ooc-math
import FloatPoint2D
import FloatVector2D
import IntBox2D
import FloatPoint2DVectorList
use ooc-base
use ooc-collections

FloatBox2D: cover {
	leftTop: FloatPoint2D
	size: FloatVector2D
	width ::= this size x
	height ::= this size y
	left ::= this leftTop x
	top ::= this leftTop y
	right ::= this leftTop x + this size x
	bottom ::= this leftTop y + this size y
	rightTop ::= FloatPoint2D new(this right, this top)
	leftBottom ::= FloatPoint2D new(this left, this bottom)
	rightBottom ::= this leftTop + this size
	center ::= this leftTop + this size / 2.0f
	leftCenter ::= FloatPoint2D new(this left, this center y)
	rightCenter ::= FloatPoint2D new(this right, this center y)
	topCenter ::= FloatPoint2D new(this center x, this top)
	bottomCenter ::= FloatPoint2D new(this center x, this bottom)
	empty ::= this size x <= 0.0f || this size y <= 0.0f
	area ::= this size x * this size y
	init: func@ (=leftTop, =size)
	init: func@ ~fromIntBox2D (box: IntBox2D) { this init(box left, box top, box width, box height) }
	init: func@ ~fromPoints (first, second: FloatPoint2D) {
		left := Float minimum(first x, second x)
		top := Float minimum(first y, second y)
		width := (first x - second x) abs()
		height := (first y - second y) abs()
		this init(left, top, width, height)
	}
	init: func@ ~fromFloats (left, top, width, height: Float) { this init(FloatPoint2D new(left, top), FloatVector2D new(width, height)) }
	init: func@ ~fromSize (size: FloatVector2D) { this init(FloatPoint2D new(), size) }
	init: func@ ~default { this init(FloatPoint2D new(), FloatVector2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Float) -> This {
		This new(FloatPoint2D new(this left - left, this top - top), FloatVector2D new(this width + left + right, this height + top + bottom))
	}
	pad: func ~fromFloat (pad: Float) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: FloatVector2D) -> This { this pad(pad x, pad x, pad y, pad y) }
	enlargeEvenly: func (fraction: Float) -> This {
		this pad(fraction * (this size x + this size y) / 2.0f)
	}
	enlarge: func (fraction: Float) -> This {
		this scale(1.0f + fraction)
	}
	shrink: func (fraction: Float) -> This {
		this scale(1.0f - fraction)
	}
	resizeTo: func (size: FloatVector2D) -> This {
		This createAround(this center, size)
	}
	scale: func (value: Float) -> This {
		This createAround(this center, value * this size)
	}
	enlargeTo: func (size: FloatVector2D) -> This {
		This createAround(this center, FloatVector2D maximum(this size, size))
	}
	shrinkTo: func (size: FloatVector2D) -> This {
		This createAround(this center, FloatVector2D minimum(this size, size))
	}
	intersection: func (other: This) -> This {
		left := Float maximum(this left, other left)
		top := Float maximum(this top, other top)
		width := Float maximum(0, (Float minimum(this right, other right) - left))
		height := Float maximum(0, (Float minimum(this bottom, other bottom) - top))
		This new(left, top, width, height)
	}
	union: func ~box (other: This) -> This { // Rock bug: Union without suffix cannot be used because the C name conflicts with keyword "union"
		This new(this leftTop minimum(other leftTop), this rightBottom maximum(other rightBottom))
	}
	union: func ~point (point: FloatPoint2D) -> This {
		This new(this leftTop minimum(point), this rightBottom maximum(point))
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
	distance: func (point: FloatPoint2D) -> FloatVector2D {
		((point - this center) toFloatVector2D() absolute - this size / 2.f) maximum(FloatVector2D new())
	}
	maximumDistance: func (points: VectorList<FloatPoint2D>) -> FloatVector2D {
		result := FloatVector2D new()
		for (index in 0 .. points count)
			result = FloatVector2D maximum(this distance(points[index]), result)
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
	operator + (other: FloatVector2D) -> This { This new(this leftTop, this size + other) }
	operator * (other: FloatVector2D) -> This { This new(this leftTop * other, this size * other) }
	operator / (other: FloatVector2D) -> This { This new(this leftTop / other, this size / other) }
	operator - (other: FloatVector2D) -> This { This new(this leftTop, this size - other) }
	operator == (other: This) -> Bool { this leftTop == other leftTop && this size == other size }
	operator != (other: This) -> Bool { !(this == other) }
	toIntBox2D: func -> IntBox2D { IntBox2D new(this left, this top, this width, this height) }
	operator as -> String { this toString() }
	adaptTo: func (other: This, weight: Float) -> This {
		newCenter := FloatPoint2D linearInterpolation(this center, other center, weight)
		newSize := FloatVector2D linearInterpolation(this size, other size, weight)
		This createAround(newCenter, newSize)
	}
	toString: func -> String { "#{this leftTop toString()}, #{this size toString()}" }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toFloat(), parts[1] toFloat(), parts[2] toFloat(), parts[3] toFloat())
		parts free()
		result
	}
	createAround: static func (center: FloatPoint2D, size: FloatVector2D) -> This { This new(center - size / 2.0f, size) }
	bounds: static func (left, right, top, bottom: Float) -> This { This new(left, top, right - left, bottom - top) }
	bounds: static func ~fromArray (points: FloatPoint2D[]) -> This { This bounds(points data, points length) }
	bounds: static func ~fromList (points: VectorList<FloatPoint2D>) -> This { This bounds(points pointer as FloatPoint2D*, points count) }
	bounds: static func ~fromPointer (data: FloatPoint2D*, count: Int) -> This {
		xMinimum := 0.0f
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
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(FloatPoint2D linearInterpolation(a leftTop, b leftTop, ratio), FloatVector2D linearInterpolation(a size, b size, ratio))
	}
}
