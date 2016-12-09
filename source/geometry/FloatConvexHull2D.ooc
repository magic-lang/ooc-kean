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
	contains: func ~Point (queryPoint: FloatPoint2D) -> Bool {
		result := true
		pointPtr := this _points _vector _backend as FloatPoint2D*
		thisCount := this _points _count
		firstPoint := pointPtr@
		leftPoint: FloatPoint2D
		rightPoint := firstPoint
		for (_ in 0 .. thisCount - 1) {
			pointPtr += 1
			leftPoint = rightPoint
			rightPoint = pointPtr@
			if ((rightPoint y - leftPoint y) * (queryPoint x - leftPoint x) < (rightPoint x - leftPoint x) * (queryPoint y - leftPoint y)) {
				result = false
				break
			}
		}
		result && !((firstPoint y - rightPoint y) * (queryPoint x - rightPoint x) < (firstPoint x - rightPoint x) * (queryPoint y - rightPoint y))
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
			(leftMostIndex, rightMostIndex, pointCount) := (0, 0, points _count)
			leftEndpoint := points[0]
			rightEndpoint := leftEndpoint
			pointPtr := points _vector _backend as FloatPoint2D*
			this _points = VectorList<FloatPoint2D> new(pointCount)
			for (i in 1 .. pointCount) {
				pointPtr += 1
				point := pointPtr@
				if (point x < leftEndpoint x)
					(leftEndpoint, leftMostIndex) = (point, i)
				else if (point x > rightEndpoint x)
					(rightEndpoint, rightMostIndex) = (point, i)
			}
			points removeAt(leftMostIndex)
			points removeAt(rightMostIndex)
			pointCount -= 2
			leftSet := VectorList<FloatPoint2D> new(pointCount)
			rightSet := VectorList<FloatPoint2D> new(pointCount)
			pointPtr = points _vector _backend as FloatPoint2D*
			for (i in 0 .. pointCount) {
				point := pointPtr@
				pointPtr += 1
				if ((rightEndpoint y - leftEndpoint y) * (point x - leftEndpoint x) < (rightEndpoint x - leftEndpoint x) * (point y - leftEndpoint y))
					leftSet add(point)
				else
					rightSet add(point)
			}
			this _points add(leftEndpoint)
			this _findHull(leftSet, leftEndpoint, rightEndpoint)
			this _points add(rightEndpoint)
			this _findHull(rightSet, rightEndpoint, leftEndpoint)
			(points, leftSet, rightSet) free()
		}
	}
	_findHull: func (currentSet: VectorList<FloatPoint2D>, leftPoint, rightPoint: FloatPoint2D) {
		currentSetCount := currentSet _count
		if (currentSetCount == 1)
			this _points add(currentSet[0])
		else {
			(maximumDistance, maximumDistanceIndex) := (Float negativeInfinity, -1)
			pointPtr := currentSet _vector _backend as FloatPoint2D*
			for (i in 0 .. currentSetCount) {
				queryPoint := pointPtr@
				pointPtr += 1
				pseudoDistance := ((rightPoint y - leftPoint y) * (leftPoint x - queryPoint x)) - ((rightPoint x - leftPoint x) * (leftPoint y - queryPoint y))
				if (pseudoDistance > maximumDistance)
					(maximumDistance, maximumDistanceIndex) = (pseudoDistance, i)
			}
			maximumDistancePoint := currentSet[maximumDistanceIndex]
			outsideLeft := VectorList<FloatPoint2D> new(currentSet _count)
			outsideRight := VectorList<FloatPoint2D> new(currentSet _count)
			pointPtr = currentSet _vector _backend as FloatPoint2D*
			for (i in 0 .. maximumDistanceIndex) {
				queryPoint := pointPtr@
				pointPtr += 1
				if ((maximumDistancePoint y - leftPoint y) * (queryPoint x - leftPoint x) < (maximumDistancePoint x - leftPoint x) * (queryPoint y - leftPoint y))
					outsideLeft add(queryPoint)
				else if ((rightPoint y - maximumDistancePoint y) * (queryPoint x - maximumDistancePoint x) < (rightPoint x - maximumDistancePoint x) * (queryPoint y - maximumDistancePoint y))
					outsideRight add(queryPoint)
			}
			pointPtr += 1
			for (i in maximumDistanceIndex + 1 .. currentSetCount) {
				queryPoint := pointPtr@
				pointPtr += 1
				if ((maximumDistancePoint y - leftPoint y) * (queryPoint x - leftPoint x) < (maximumDistancePoint x - leftPoint x) * (queryPoint y - leftPoint y))
					outsideLeft add(queryPoint)
				else if ((rightPoint y - maximumDistancePoint y) * (queryPoint x - maximumDistancePoint x) < (rightPoint x - maximumDistancePoint x) * (queryPoint y - maximumDistancePoint y))
					outsideRight add(queryPoint)
			}
			if (outsideLeft _count > 0)
				this _findHull(outsideLeft, leftPoint, maximumDistancePoint)
			this _points add(maximumDistancePoint)
			if (outsideRight _count > 0)
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
}
