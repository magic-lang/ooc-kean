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
import text/StringTokenizer

FloatConvexHull2D: class {
	_points: VectorList<FloatPoint2D>
	_hull: VectorList<FloatPoint2D>
	points ::= this _points
	hull ::= this _hull
	count ::= this _points count
	init: func ~fromPoints (=_points, computeHull := false) { //TODO: Compute the convex hull per default
		// Note, if hull is not computed, points must be in clockwise order
		if (computeHull)
			this computeHull()
		else
			this _hull = this _points copy()
	}
	init: func ~fromBox (box: FloatBox2D) {
		this _points = VectorList<FloatPoint2D> new(4)
		this _points add(box leftTop)
		this _points add(box leftBottom)
		this _points add(box rightBottom)
		this _points add(box rightTop)
		this _hull = this _points copy()
	}
	free: override func {
		this _points free()
		this _hull free()
		super()
	}
	contains: func ~Point (point: FloatPoint2D) -> Bool {
		result := true
		for (i in 0 .. this _hull count)
			if (result && This _isOnLeft(this _hull[i], this _hull[(i + 1) % this _hull count], point))
				result = false
		result
	}
	contains: func ~ConvexHull (other: This) -> Bool {
		result := true
		for (i in 0 .. other count)
			if (result && !this contains(other points[i]))
				result = false
		result
	}
	contains: func ~FloatBox2D (box: FloatBox2D) -> Bool {
		this contains(box leftBottom) && this contains(box rightBottom) && this contains(box leftTop) && this contains(box rightTop)
	}
	transform: func (transform: FloatTransform2D) -> This {
		newPoints := VectorList<FloatPoint2D> new(this count)
		for (i in 0 .. this count)
			newPoints add(transform * this _points[i])
		This new(newPoints)
	}
	computeHull: func {
		if (this _hull)
			this _hull free()
		if (this _points count <= 2)
			this _hull = this _points copy()
		else {
			// Uses the Quickhull algorithm if more than two points, average complexity O(n log n)
			// http://www.cse.yorku.ca/~aaw/Hang/quick_hull/Algorithm.html
			this _hull = VectorList<FloatPoint2D> new()
			leftMostIndex := 0
			rightMostIndex := 0
			for (i in 0 .. this _points count)
				if (this _points[i] x < this _points[leftMostIndex] x)
					leftMostIndex = i
				else if (this _points[i] x > this _points[rightMostIndex] x)
					rightMostIndex = i
			leftEndpoint := this _points[leftMostIndex]
			rightEndpoint := this _points[rightMostIndex]
			leftSet := VectorList<FloatPoint2D> new()
			rightSet := VectorList<FloatPoint2D> new()
			for (i in 0 .. this _points count)
				if (i != leftMostIndex && i != rightMostIndex)
					if (This _isOnLeft(this _points[leftMostIndex], this _points[rightMostIndex], this _points[i]))
						leftSet add(this _points[i])
					else
						rightSet add(this _points[i])
			this _hull add(leftEndpoint)
			this _findHull(leftSet, leftEndpoint, rightEndpoint)
			this _hull add(rightEndpoint)
			this _findHull(rightSet, rightEndpoint, leftEndpoint)
			leftSet free()
			rightSet free()
		}
	}
	_findHull: func (currentSet: VectorList<FloatPoint2D>, leftPoint, rightPoint: FloatPoint2D) {
		if (currentSet count == 1)
			this _hull add(currentSet[0])
		else if (currentSet count > 1) {
			maximumDistance := Float negativeInfinity
			maximumDistanceIndex := -1
			for (i in 0 .. currentSet count) {
				distance := This _hullLinePseudoDistance(leftPoint, rightPoint, currentSet[i])
				if (distance > maximumDistance) {
					maximumDistance = distance
					maximumDistanceIndex = i
				}
			}
			maximumDistancePoint := currentSet[maximumDistanceIndex]
			outsideLeft := VectorList<FloatPoint2D> new()
			outsideRight := VectorList<FloatPoint2D> new()
			for (i in 0 .. currentSet count)
				if (i != maximumDistanceIndex)
					if (This _isOnLeft(leftPoint, maximumDistancePoint, currentSet[i]))
						outsideLeft add(currentSet[i])
					else if (This _isOnLeft(maximumDistancePoint, rightPoint, currentSet[i]))
						outsideRight add(currentSet[i])
			this _findHull(outsideLeft, leftPoint, maximumDistancePoint)
			this _hull add(maximumDistancePoint)
			this _findHull(outsideRight, maximumDistancePoint, rightPoint)
			outsideLeft free()
			outsideRight free()
		}
	}
	_hullLinePseudoDistance: static func (leftPoint, rightPoint, queryPoint: FloatPoint2D) -> Float {
		((rightPoint y - leftPoint y) * (leftPoint x - queryPoint x)) - ((rightPoint x - leftPoint x) * (leftPoint y - queryPoint y))
	}
	_isOnLeft: static func (leftPoint, rightPoint, queryPoint: FloatPoint2D) -> Bool {
		(rightPoint y - leftPoint y) * (queryPoint x - leftPoint x) < (rightPoint x - leftPoint x) * (queryPoint y - leftPoint y)
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this count)
			result = result >> "(" & this _points[i] toString() >> ") "
		result
	}
}
