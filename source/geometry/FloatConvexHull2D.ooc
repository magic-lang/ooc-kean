/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use math
import FloatPoint2D
import FloatBox2D
import FloatTransform2D

// Note: Points must be in counterclockwise order
FloatConvexHull2D: class {
	_points: VectorList<FloatPoint2D>

	points ::= this _points
	count ::= this _points count

	init: func ~fromPoints (=_points, computeHull := true) {
		if (computeHull)
			this computeHull()
	}
	init: func ~fromBox (box: FloatBox2D) {
		this _points = VectorList<FloatPoint2D> new(4)
		this _points add(box leftTop)
		this _points add(box leftBottom)
		this _points add(box rightBottom)
		this _points add(box rightTop)
	}
	free: override func {
		this _points free()
		super()
	}
	contains: func ~Point (point: FloatPoint2D) -> Bool {
		result := true
		for (i in 0 .. this count)
			if (This _isOnLeft(this _points[i], this _points[(i + 1) % this count], point)) {
				result = false
				break
			}
		result
	}
	contains: func ~ConvexHull (other: This) -> Bool {
		result := true
		for (i in 0 .. other count)
			if (!this contains(other _points[i])) {
				result = false
				break
			}
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
		if (this count > 2) {
			// Uses the Quickhull algorithm if more than two points, average complexity O(n log n)
			// https://en.wikipedia.org/wiki/Quickhull
			points := this _points
			this _points = VectorList<FloatPoint2D> new()
			leftMostIndex := 0
			rightMostIndex := 0
			leftEndpoint := points[0]
			rightEndpoint := leftEndpoint
			for (i in 1 .. points count) {
				point := points[i]
				if (point x < leftEndpoint x) {
					leftEndpoint = point
					leftMostIndex = i
				}
				else if (point x > rightEndpoint x) {
					rightEndpoint = point
					rightMostIndex = i
				}
			}
			points removeAt(leftMostIndex)
			points removeAt(rightMostIndex)
			leftSet := VectorList<FloatPoint2D> new()
			rightSet := VectorList<FloatPoint2D> new()
			for (i in 0 .. points count) {
				point := points[i]
				(This _isOnLeft(leftEndpoint, rightEndpoint, point) ? leftSet : rightSet) add(point)
			}
			this _points add(leftEndpoint)
			this _findHull(leftSet, leftEndpoint, rightEndpoint)
			this _points add(rightEndpoint)
			this _findHull(rightSet, rightEndpoint, leftEndpoint)
			(points, leftSet, rightSet) free()
		}
	}
	_findHull: func (currentSet: VectorList<FloatPoint2D>, leftPoint, rightPoint: FloatPoint2D) {
		if (currentSet count == 1)
			this _points add(currentSet[0])
		else if (currentSet count > 1) {
			maximumDistance := Float negativeInfinity
			maximumDistanceIndex := -1
			for (i in 0 .. currentSet count) {
				distance := This _pointsLinePseudoDistance(leftPoint, rightPoint, currentSet[i])
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
			this _points add(maximumDistancePoint)
			this _findHull(outsideRight, maximumDistancePoint, rightPoint)
			(outsideLeft, outsideRight) free()
		}
	}
	toString: func (decimals := 2) -> String {
		result := ""
		for (i in 0 .. this count)
			result = result >> "(" & this _points[i] toString(decimals) >> ") "
		result
	}
	_pointsLinePseudoDistance: static func (leftPoint, rightPoint, queryPoint: FloatPoint2D) -> Float {
		((rightPoint y - leftPoint y) * (leftPoint x - queryPoint x)) - ((rightPoint x - leftPoint x) * (leftPoint y - queryPoint y))
	}
	_isOnLeft: static func (leftPoint, rightPoint, queryPoint: FloatPoint2D) -> Bool {
		(rightPoint y - leftPoint y) * (queryPoint x - leftPoint x) < (rightPoint x - leftPoint x) * (queryPoint y - leftPoint y)
	}
}
