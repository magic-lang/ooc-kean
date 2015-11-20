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
import math
import IntSize2D
import FloatPoint3D

FloatMatrix : cover {
	// x = column
	// y = row
	_dimensions: IntSize2D
	dimensions: IntSize2D { get {
		result := this _dimensions
		this free(Owner Receiver)
		result
	}}
	width: Int { get {
		result := this _dimensions width
		this free(Owner Receiver)
		result
	}}
	height: Int { get {
		result := this _dimensions height
		this free(Owner Receiver)
		result
	}}
	isNull: Bool { get { // TODO: Better name?
		result := this _dimensions empty
		this free(Owner Receiver)
		result
	}}
	isSquare: Bool { get {
		result := this _dimensions width == this _dimensions height
		this free(Owner Receiver)
		result
	}}
	isVector: Bool { get {
		result := this _dimensions width == 1 || this _dimensions height == 1
		this free(Owner Receiver)
		result
	}}
	order: Int { get {
		result := Int minimum(this _dimensions height, this _dimensions width)
		this free(Owner Receiver)
		result
	}}
	_elements: OwnedBuffer
	elements ::= this _elements pointer as Float*

	init: func@ ~buffer (=_elements, =_dimensions)
	init: func@ ~IntSize2D (._dimensions) {
		this init(OwnedBuffer new(_dimensions area * Float size), _dimensions)
	}
	init: func@ (width, height: Int) { this init(IntSize2D new(width, height)) }
	free: func@ -> Bool { this _elements free() }
	free: func@ ~withCriteria (criteria: Owner) -> Bool { this _elements free(criteria) }
	identity: static func (order: Int) -> This {
		result := This new(order, order)
		resultWidth := result take() width
		resultElements := result elements
		for (i in 0 .. order)
			resultElements[i + resultWidth * i] = 1.0f
		result
	}
	setVertical: func (xOffset, yOffset: Int, vector: FloatPoint3D) {
		t := this take()
		version(safe) {
			if (xOffset < 0 || xOffset >= t width)
				raise("Column index out of range in FloatMatrix setVertical")
			if (t height - yOffset < 3)
				raise("Element positions exceed matrix dimensions in FloatMatrix setVertical")
		}
		this[xOffset, yOffset] = vector x
		this[xOffset, yOffset + 1] = vector y
		this[xOffset, yOffset + 2] = vector z
	}
	getColumn: func (x: Int) -> This {
		t := this take()
		version (safe) {
			if (x < 0 || x >= t width)
				raise("Column index out of range in FloatMatrix getColumn")
		}
		result := This new(1, t height)
		for (y in 0 .. t height)
			result[0, y] = t[x, y]
		this free(Owner Receiver)
		result
	}
	// NOTE: Because rock doesn't understand the concept of inline functions,
	// this function has been inlined manually in many places in this file for performance reasons.
	operator [] (x, y: Int) -> Float {
		t := this take()
		version (safe) {
			if (x < 0 || y < 0 || x >= t width || y >= t height)
				raise("Accessing matrix element out of range in get operator")
		}
		result := t elements[x + y * t width]
		this free(Owner Receiver)
		result
	}
	// NOTE: Because rock doesn't understand the concept of inline functions,
	// this function has been inlined manually in many places in this file for performance reasons.
	operator []= (x, y: Int, value: Float) {
		t := this take()
		version (safe) {
			if (x < 0 || y < 0 || x >= t width || y >= t height)
				raise("Accessing matrix element out of range in set operator")
		}
		this elements[x + y * t width] = value
	}
	copy: func -> This {
		result := This new(this _elements copy(), this take() dimensions)
		this free(Owner Receiver)
		result
	}
	transpose: func -> This {
		t := this take()
		result: This
		if (t isVector && this _elements owner == Owner Receiver) {
			result = this
			result _dimensions = result _dimensions swap()
		} else {
			result = This new(t dimensions swap())
			resultElements := result elements
			thisElements := this elements
			thisHeight := t height
			thisWidth := t width
			for (y in 0 .. thisHeight)
				for (x in 0 .. thisWidth)
					resultElements[y + x * thisHeight] = thisElements[x + y * thisWidth]
			this free(Owner Receiver)
		}
		result
	}
	trace: func -> Float {
		t := this take()
		if (!t isSquare)
			raise("Invalid dimensions in FloatMatrix trace")
		result := 0.0f
		for (i in 0 .. t height)
			result += t[i, i]
		this free(Owner Receiver)
		result
	}
	swapRows: func@ (first, second: Int) {
		t := this take()
		buffer: Float
		thisElements := this elements
		if (first != second)
			for (i in 0 .. t order) {
				buffer = thisElements[i + first * t width]
				thisElements[i + first * t width] = thisElements[i + second * t width]
				thisElements[i + second * t width] = buffer
			}
	}
	toString: func -> String {
		t := this take()
		result: String = ""
		for (y in 0 .. t height) {
			for (x in 0 .. t width - 1)
				result = result & t[x, y] toString() >> ", "
			result = result & t[t width - 1, y] toString()
			result = result >> "; "
		}
		this free(Owner Receiver)
		result
	}
	// Lup decomposition of the current matrix. Recall that Lup decomposition is A = LUP,
	// where L is lower triangular, U is upper triangular, and P is a permutation matrix.
	// See http://en.wikipedia.org/wiki/LUP_decomposition.
	_lupDecomposition: func -> (This, This, This) {
		t := this take()
		if (!t isSquare)
			raise("Invalid dimensions in FloatMatrix lupDecomposition")
		order := t order
		l := This identity(order)
		u := t copy()
		p := This identity(order)
		lElements := l elements
		uElements := u elements
		uWidth := u take() width
		for (position in 0 .. order - 1) {
			pivotRow := position
			for (y in position + 1 .. u take() height)
				if (abs(uElements[position + position * uWidth]) < abs(uElements[position + y * uWidth]))
					pivotRow = y
			p swapRows(position, pivotRow)
			u swapRows(position, pivotRow)
			if (uElements[position + uWidth * position] != 0)
				for (y in position + 1 .. order) {
					pivot := uElements[position + y * uWidth] / uElements[position + position * uWidth]
					for (x in position .. order)
						uElements[x + y * uWidth] = uElements[x + y * uWidth] - pivot * uElements[x + position * uWidth]
					uElements[position + y * uWidth] = pivot
				}
		}
		for (y in 0 .. order)
			for (x in 0 .. y) {
				lElements[x + y * l take() width] = uElements[x + y * uWidth]
				uElements[x + y * uWidth] = 0
			}
		this free(Owner Receiver)
		(l, u, p)
	}
	// Lup least square solver A * x = y.
	// If overdetermined, returns the least square solution to the system.
	solve: func (y: This) -> This {
		t := this take()
		version (safe) {
			if (t width > t height)
				raise("Invalid dimensions in FloatMatrix solve")
		}
		result: This
		if (t isSquare) {
			(l, u, p) := t _lupDecomposition()
			result = (p * y take()) _forwardSubstitution(l) _backwardSubstitution(u)
		} else {
			(l, u, p) := (t transpose() * t) _lupDecomposition()
			result = (p * t transpose() * y take()) _forwardSubstitution(l) _backwardSubstitution(u)
		}
		y free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	// Forward solver lower * x = y for a lower triangular matrix. Current object is y.
	_forwardSubstitution: func (lower: This) -> This {
		t := this take()
		result := This new(t dimensions)
		resultElements := result elements
		thisElements := this elements
		lowerElements := lower elements
		for (x in 0 .. t width)
			for (y in 0 .. t height) {
				accumulator := thisElements[x + y * t width]
				for (x2 in 0 .. y)
					accumulator -= lowerElements[x2 + y * lower take() width] * resultElements[x + x2 * result take() width]
				value := lowerElements[y + y * lower take() width]
				if (value != 0)
					resultElements[x + y * result take()width] = accumulator / value
				else
					raise("Division by zero in FloatMatrix forwardSubstitution")
			}
		if (thisElements != lowerElements)
			lower free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	// Backward solver upper * x = y for an upper triangular matrix. Current object is y.
	_backwardSubstitution: func (upper: This) -> This {
		t := this take()
		result := This new(t dimensions)
		resultElements := result elements
		thisElements := this elements
		upperElements := upper elements
		for (x in 0 .. t width) {
			for (antiY in 0 .. t height) {
				y := t height - 1 - antiY
				accumulator := thisElements[x + y * t width]
				for (x2 in y + 1 .. upper take() width)
					accumulator -= upperElements[x2 + y * upper take() width] * resultElements[x + x2 * result take() width]
				value := upperElements[y + y * upper take() width]
				if (value != 0)
					resultElements[x + y * result take() width] = accumulator / value
				else
					raise("Division by zero in FloatMatrix backwardSubstitution")
			}
		}
		if (thisElements != upperElements)
			upper free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	cofactors: func -> This {
		// TODO: At some point, when needed, implement for the general case.
		t := this take()
		version(safe) {
			if (!t isSquare)
				raise("Matrix must be square in FloatMatrix cofactors")
			if (t width != 3)
				raise("Cofactors implemented only for 3x3 matrices in FloatMatrix")
		}
		result := This new(t dimensions)
		result[0, 0] = t[1, 1] * t[2, 2] - t[2, 1] * t[1, 2]
		result[1, 0] = - (t[0, 1] * t[2, 2] - t[2, 1] * t[0, 2])
		result[2, 0] = t[0, 1] * t[1, 2] - t[1, 1] * t[0, 2]
		result[0, 1] = - (t[1, 0] * t[2, 2] - t[2, 0] * t[1, 2])
		result[1, 1] = t[0, 0] * t[2, 2] - t[2, 0] * t[0, 2]
		result[2, 1] = - (t[0, 0] * t[1, 2] - t[1, 0] * t[0, 2])
		result[0, 2] = t[1, 0] * t[2, 1] - t[2, 0] * t[1, 1]
		result[1, 2] = - (t[0, 0] * t[2, 1] - t[2, 0] * t[0, 1])
		result[2, 2] = t[0, 0] * t[1, 1] - t[1, 0] * t[0, 1]
		this free(Owner Receiver)
		result
	}
	adjugate: func -> This {
		// TODO: At some point, when needed, implement for the general case.
		version(safe) {
			if (!this take() isSquare)
				raise("Matrix must be square in FloatMatrix adjugate")
			if (this take() width != 3)
				raise("Adjugate implemented only for 3x3 matrices in FloatMatrix")
		}
		result := this take() cofactors() transpose()
		this free(Owner Receiver)
		result
	}
	determinant: func -> Float {
		// TODO: At some point, when needed, implement for the general case.
		t := this take()
		version(safe) {
			if (!t isSquare)
				raise("Matrix must be square in FloatMatrix determinant")
			if (t width != 3)
				raise("Determinant implemented only for 3x3 matrices in FloatMatrix")
		}
		result := t[0, 0] * (t[1, 1] * t[2, 2] - t[2, 1] * t[1, 2]) -
			t[1, 0] * (t[0, 1] * t[2, 2] - t[2, 1] * t[0, 2]) +
			t[2, 0] * (t[0, 1] * t[1, 2] - t[1, 1] * t[0, 2])
		this free(Owner Receiver)
		result
	}
	take: func -> This { // call by value -> modifies copy of cover
		this _elements = this _elements take()
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		this _elements = this _elements give()
		this
	}
	operator * (other: This) -> This {
		t := this take()
		version(safe) {
			if (t width != other take() height)
				raise("Invalid dimensions in FloatMatrix * operator: left width must match right height!")
		}
		otherWidth := other take() width
		result := This new(otherWidth, t height)
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (x in 0 .. otherWidth) {
			for (y in 0 .. t height) {
				temp := resultElements[x + y * otherWidth]
				for (z in 0 .. t width)
					temp += thisElements[z + y * t width] * otherElements[x + z * otherWidth]
				resultElements[x + y * otherWidth] = temp
			}
		}
		if (thisElements != otherElements)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator + (other: This) -> This {
		t := this take()
		version(safe) {
			if (t dimensions != other take() dimensions)
				raise("Invalid dimensions in FloatMatrix + operator: dimensions must match!")
		}
		result := This new(t dimensions)
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. t dimensions area)
			resultElements[i] = thisElements[i] + otherElements[i]
		if (thisElements != otherElements)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator - (other: This) -> This {
		t := this take()
		version(safe) {
			if (t dimensions != other take() dimensions)
				raise("Invalid dimensions in FloatMatrix - operator: dimensions must match!")
		}
		result := This new(t dimensions)
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. t dimensions area)
			resultElements[i] = thisElements[i] - otherElements[i]
		if (thisElements != otherElements)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator += (other: This) {
		version(safe) {
			if (this dimensions != other dimensions)
				raise("Invalid dimensions in FloatMatrix += operator: dimensions must match!")
		}
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. this take() dimensions area)
			thisElements[i] += otherElements[i]
		other free(Owner Receiver)
	}
	operator -= (other: This) {
		version(safe) {
			if (this take() dimensions != other take() dimensions)
				raise("Invalid dimensions in FloatMatrix -= operator: dimensions must match!")
		}
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. this take() dimensions area)
			thisElements[i] -= otherElements[i]
		other free(Owner Receiver)
	}
	operator * (other: Float) -> This {
		result := This new(this take() dimensions)
		resultElements := result elements
		thisElements := this elements
		for (i in 0 .. this take() dimensions area)
			resultElements[i] = other * thisElements[i]
		this free(Owner Receiver)
		result
	}
}
operator * (left: Float, right: FloatMatrix) -> FloatMatrix { right * left }
