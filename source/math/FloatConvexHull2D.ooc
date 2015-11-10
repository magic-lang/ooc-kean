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
use ooc-collections
import math
import FloatPoint2D
import FloatBox2D
import FloatTransform2D

FloatConvexHull2D: class {
	// Points must be in clockwise order
	// TODO: Implement computation of convex hull from a set of points
	_points: VectorList<FloatPoint2D>
	points ::= this _points
	count ::= this _points count
	init: func ~fromPoints (=_points) // Note: Does not compute the convex hull, only assigns it
	init: func ~fromBox (box: FloatBox2D) {
		this _points = VectorList<FloatPoint2D> new(4)
		this _points add(box leftTop)
		this _points add(box leftBottom)
		this _points add(box rightBottom)
		this _points add(box rightTop)
	}
	contains: func ~Point (point: FloatPoint2D) -> Bool {
		result := true
		for (i in 0 .. this count - 1)
			if (This _isOnLeft(this _points[i], this _points[i + 1], point)) {
				result = false
				break
			}
		if (This _isOnLeft(this _points[this count - 1], this _points[0], point))
			result = false
		result
	}
	contains: func ~ConvexHull (other: This) -> Bool {
		result := true
		for (i in 0 .. other count)
			if (!this contains(other points[i])) {
				result = false
				break
			}
		result
	}
	contains: func ~FloatBox2D (box: FloatBox2D) -> Bool {
		this contains(box leftBottom) && this contains(box rightBottom) && this contains(box leftTop) && this contains(box rightTop)
	}
	transform: func (transform: FloatTransform2D) -> This {
		// TODO: Re-compute convex hull from new points if necessary, i.e. if transform changes order of points
		newPoints := VectorList<FloatPoint2D> new(this count)
		for (i in 0 .. this count)
			newPoints add(transform * this _points[i])
		This new(newPoints)
	}
	_isOnLeft: static func (leftPoint, rightPoint, queryPoint: FloatPoint2D) -> Bool {
		(rightPoint x - leftPoint x) * (queryPoint y - leftPoint y) > (rightPoint y - leftPoint y) * (queryPoint x - leftPoint x)
	}
	free: override func {
		this _points free()
		super()
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this count)
			result = result >> "(" & this _points[i] toString() >> ") "
		result
	}
}
