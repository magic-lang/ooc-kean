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
import ../../FloatExtension
import FloatPoint2D
import FloatSize2D
import FloatShell2D
import text/StringTokenizer
import structs/ArrayList

FloatBox2D: cover {
	leftTop: FloatPoint2D
	size: FloatSize2D
	Width: Float { get { (this size width) } }
	Height: Float { get { this size height } }
	Left: Float { get { this leftTop x } }
	Top: Float { get { this leftTop y } }
	Right: Float { get { this leftTop x + this size width } }
	Bottom: Float { get { this leftTop y + this size height } }
	RightTop: FloatPoint2D { get { FloatPoint2D new(this Right, this Top) } }
	LeftBottom: FloatPoint2D { get { FloatPoint2D new(this Left, this Bottom) } }
	RightBottom: FloatPoint2D { get { this leftTop + this size } }
	Center: FloatPoint2D { get { this leftTop + (this size / 2) } }
	Empty: Bool { get { this size Empty } }
	init: func@ (=leftTop, =size)
	init: func@ ~fromFloats (left, top, width, height: Float) { this init(FloatPoint2D new(left, top), FloatSize2D new(width, height)) }
	init: func@ ~fromSize (size: FloatSize2D) { this init(FloatPoint2D new(), size) }
	init: func@ ~default { this init(FloatPoint2D new(), FloatSize2D new()) }
	swap: func -> This { This new(this leftTop swap(), this size swap()) }
	pad: func (left, right, top, bottom: Float) -> This {
		This new(FloatPoint2D new(this Left - left, this Top - top), FloatSize2D new(this Width + left + right, this Height + top + bottom))
	}
	pad: func ~fromFloat (pad: Float) -> This { this pad(pad, pad, pad, pad) }
	pad: func ~fromSize (pad: FloatSize2D) -> This { this pad(pad width, pad width, pad height, pad height) }
	intersection: func (other: This) -> This {
		left := this Left > other Left ? this Left : other Left
		top := this Top > other Top ? this Top : other Top
		width := ((this Right < other Right ? this Right : other Right) - left) maximum(0.0f)
		height := ((this Bottom < other Bottom ? this Bottom : other Bottom) - top) maximum(0.0f)
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
	contains: func (point: FloatPoint2D) -> Bool {
		this Left <= point x && point x < this Right && this Top <= point y && point y < this Bottom
	}
	contains: func ~box (box: FloatBox2D) -> Bool { this intersection(box) == box }
	round: func -> This { This new(this leftTop round(), this size round()) }
	ceiling: func -> This { This new(this leftTop ceiling(), this size ceiling()) }
	floor: func -> This { This new(this leftTop floor(), this size floor()) }
	
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
	operator + (other: FloatPoint2D) -> This { This new(this leftTop + other, this size) }
	//FIXME: Unary minus bug
	operator - (other: FloatPoint2D) -> This { This new(this leftTop + (-other), this size) }
	operator + (other: FloatSize2D) -> This { This new(this leftTop, this size + other) }
	//FIXME: Unary minus bug again
	operator - (other: FloatSize2D) -> This { This new(this leftTop, this size + (-other)) }
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
	bounds: func (left, right, top, bottom: Float) -> This { This new(left, top, right - left, bottom - top) }
	bounds: func ~fromArray (points: FloatPoint2D[]) -> FloatBox2D { this bounds(points as ArrayList<FloatPoint2D>) }
	bounds: func ~fromList (points: ArrayList<FloatPoint2D>) -> FloatBox2D {
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
