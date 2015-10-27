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
use ooc-base
use ooc-math

FloatMatrix : cover {
	// x = column
	// y = row
	_dimensions: IntSize2D
	dimensions ::= this _dimensions
	width ::= this _dimensions width
	height ::= this _dimensions height
	isNull ::= this dimensions empty // TODO: Better name?
	isSquare ::= this width == this height
	order ::= Int minimum~two(this height, this width)
	_elements: OwnedBuffer
	elements ::= this _elements pointer as Float*

	init: func@ ~buffer (=_elements, =_dimensions)
	init: func@ ~IntSize2D (=_dimensions) {
		this init(OwnedBuffer new(_dimensions area * Float size), dimensions)
	}
	init: func@ (width, height: Int) {
		this init(IntSize2D new(width, height))
	}
	free: func@ -> Bool {
		this _elements free()
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _elements free(criteria)
	}
	identity: static func (order: Int) -> This {
		result := This new(order, order)
		for (i in 0 .. order)
			result elements[i + result width * i] = 1.0f
		result
	}
	setVertical: func (xOffset, yOffset: Int, vector: FloatPoint3D) {
		if (xOffset < 0 || xOffset >= this width)
			raise("Column index out of range in FloatMatrix setVertical")
		if (this height - yOffset < 3)
			raise("Element positions exceed matrix dimensions in FloatMatrix setVertical")
		this[xOffset, yOffset] = vector x
		this[xOffset, yOffset + 1] = vector y
		this[xOffset, yOffset + 2] = vector z
	}
	getColumn: func (x: Int) -> This {
		version (safe) {
			if (x < 0 || x >= this width)
				raise("Column index out of range in FloatMatrix getColumn")
		}
		result := This new(1, this height)
		for (y in 0 .. this height)
			result[0, y] = this[x, y]
		this free(Owner Receiver)
		result
	}
	// NOTE: Because rock doesn't understand the concept of inline functions,
	// this function has been inlined manually in many places in this file for performance reasons.
	operator [] (x, y: Int) -> Float {
		version (safe) {
			if (x < 0 || y < 0 || x >= this width || y >= this height)
				raise("Accessing matrix element out of range in get operator")
		}
		this elements[x + y * this width]
	}
	// NOTE: Because rock doesn't understand the concept of inline functions,
	// this function has been inlined manually in many places in this file for performance reasons.
	operator []= (x, y: Int, value: Float) {
		version (safe) {
			if (x < 0 || y < 0 || x >= this width || y >= this height)
				raise("Accessing matrix element out of range in set operator")
		}
		this elements[x + y * this width] = value
	}
	copy: func -> This {
		result := This new(this _elements copy(), this dimensions)
		this free(Owner Receiver)
		result
	}
	transpose: func -> This {
		result := This new(this dimensions swap())
		for (y in 0 .. this height)
			for (x in 0 .. this width)
				result elements[y + x * this height] = this elements[x + y * this width]
		this free(Owner Receiver)
		result
	}
	trace: func -> Float {
		if (!this isSquare)
			raise("Invalid dimensions in FloatMatrix trace")
		result := 0.0f
		for (i in 0 .. this height)
			result += this[i, i]
		this free(Owner Receiver)
		result
	}
	swapRows: func@ (first, second: Int) {
		order := this order
		buffer: Float
		if (first != second)
			for (i in 0 .. order) {
				buffer = this elements[i + first * this width]
				this elements[i + first * this width] = this elements[i + second * this width]
				this elements[i + second * this width] = buffer
			}
	}

	toString: func -> String {
		result: String = ""
		for (y in 0 .. this height) {
			for (x in 0 .. this width - 1)
				result = result & this[x, y] toString() >> ", "
			result = result & this[this width - 1, y] toString()
			result = result >> "; "
		}
		result
	}
	// Lup decomposition of the current matrix. Recall that Lup decomposition is A = LUP,
	// where L is lower triangular, U is upper triangular, and P is a permutation matrix.
	// See http://en.wikipedia.org/wiki/LUP_decomposition.
	lupDecomposition: func -> (This, This, This) {
		if (!this isSquare)
			raise("Invalid dimensions in FloatMatrix lupDecomposition")
		order := this order
		l := This identity(order)
		u := this take() copy()
		p := This identity(order)

		for (position in 0 .. order - 1) {
			pivotRow := position
			for (y in position + 1 .. u height)
				if (abs(u elements[position + position * u width]) < abs(u elements[position + y * u width]))
					pivotRow = y
			p swapRows(position, pivotRow)
			u swapRows(position, pivotRow)

			if (u elements[position + u width * position] != 0)
				for (y in position + 1 .. order) {
					pivot := u elements[position + y * u width] / u elements[position + position * u width]
					for (x in position .. order)
						u elements[x + y * u width] = u elements[x + y * u width] - pivot * u elements[x + position * u width]
					u elements[position + y * u width] = pivot
				}
		}
		for (y in 0 .. order)
			for (x in 0 .. y) {
				l elements[x + y * l width] = u elements[x + y * u width]
				u elements[x + y * u width] = 0
			}
		this free(Owner Receiver)
		(l, u, p)
	}
	// Lup least square solver A * x = y.
	// If overdetermined, returns the least square solution to the system.
	solve: func (y: This) -> This {
		version (safe) {
			if (this width > this height)
				raise("Invalid dimensions in FloatMatrix solve")
		}
		result: This
		t := this take()
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
		result := This new(this dimensions)
		for (x in 0 .. this width)
			for (y in 0 .. this height) {
				accumulator := this elements[x + y * this width]
				for (x2 in 0 .. y)
					accumulator -= lower elements[x2 + y * lower width] * result elements[x + x2 * result width]
				value := lower elements[y + y * lower width]
				if (value != 0)
					result elements[x + y * result width] = accumulator / value
				else
					raise("Division by zero in FloatMatrix forwardSubstitution")
			}
		this free(Owner Receiver)
		lower free(Owner Receiver)
		result
	}
	// Backward solver upper * x = y for an upper triangular matrix. Current object is y.
	_backwardSubstitution: func (upper: This) -> This {
		result := This new(this dimensions)
		for (x in 0 .. this width) {
			for (antiY in 0 .. this height) {
				y := this height - 1 - antiY
				accumulator := this elements[x + y * this width]
				for (x2 in y + 1 .. upper width)
					accumulator -= upper elements[x2 + y * upper width] * result elements[x + x2 * result width]
				value := upper elements[y + y * upper width]
				if (value != 0)
					result elements[x + y * result width] = accumulator / value
				else
					raise("Division by zero in FloatMatrix backwardSubstitution")
			}
		}
		this free(Owner Receiver)
		upper free(Owner Receiver)
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
		if (this width != other height)
			raise("Invalid dimensions in FloatMatrix * operator: left width must match right height!")
		result := This new(other width, this height)
		for (x in 0 .. other width) {
			for (y in 0 .. this height) {
				temp := result elements[x + y * result width]
				for (z in 0 .. this width)
					temp += this elements[z + y * this width] * other elements[x + z * other width]
				result elements[x + y * result width] = temp
			}
		}
		this free(Owner Receiver)
		other free(Owner Receiver)
		result
	}
	operator + (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix + operator: dimensions must match!")
		result := This new(this dimensions)
		for (i in 0 .. this dimensions area)
			result elements[i] = this elements[i] + other elements[i]
		this free(Owner Receiver)
		other free(Owner Receiver)
		result
	}
	operator - (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix - operator: dimensions must match!")
		result := This new(this dimensions)
		for (i in 0 .. this dimensions area)
			result elements[i] = this elements[i] - other elements[i]
		this free(Owner Receiver)
		other free(Owner Receiver)
		result
	}
	operator += (other: This) {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix += operator: dimensions must match!")
		for (i in 0 .. this dimensions area)
			this elements[i] += other elements[i]
		other free(Owner Receiver)
	}
	operator -= (other: This) {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix -= operator: dimensions must match!")
		for (i in 0 .. this dimensions area)
			this elements[i] -= other elements[i]
		other free(Owner Receiver)
	}
}

operator * (left: Float, right: FloatMatrix) -> FloatMatrix {
	result := FloatMatrix new(right dimensions)
	for (i in 0 .. right dimensions area)
		result elements[i] = left * right elements[i]
	right free(Owner Receiver)
	result
}
