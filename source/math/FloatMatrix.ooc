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

FloatMatrix : cover {
	// x = column
	// y = row
	_dimensions: IntSize2D
	dimensions ::= this _dimensions
	elements: Float[]

	init: func@ ~IntSize2D (=_dimensions) {
		this elements = Float[_dimensions area] new()
	}
	init: func@ (width, height: Int) {
		this init(IntSize2D new(width, height))
	}

	// <summary>
	// Creates an identity matrix of given order.
	// </summary>
	// <param name="order">Order of matrix to be created.</param>
	// <returns>Identity matrix of given order.</returns>
	identity: static func@ (order: Int) -> This {
		result := This new(order, order)
		for (i in 0 .. order)
			result elements[i + result dimensions width * i] = 1.0f
		result
	}

	// <summary>
	// Get an element in a matrix at position(x,y).
	// </summary>
	// <param name="x">Column number of a matrix.</param>
	// <param name="y">Row number of a matrix.</param>
	// <returns></returns>
	get: func@ (x, y: Int) -> Float { this elements[x + this dimensions width * y] }

	// <summary>
	// Set an element in a matrix at position(x,y).
	// </summary>
	// <param name="x">Column number of a matrix.</param>
	// <param name="y">Row number of a matrix.</param>
	// <param name="value">The value set at (x,y).</param>
	// <returns></returns>
	set: func@ (x, y: Int, value: Float) { this elements[x + this dimensions width * y] = value }

	// <summary>
	// True if the matrix is a square matrix.
	// </summary>
	isSquare ::= this dimensions width == this dimensions height

	// <summary>
	// Minimum of matrix dimensions.
	// </summary>
	order ::= Int minimum~two(this dimensions height, this dimensions width)

	// <summary>
	// Creates a copy of the current matrix.
	// </summary>
	// <returns>Return a copy of the current matrix.</returns>
	copy: func@ -> This {
		result := This new(this dimensions)
		memcpy(result elements data, this elements data, this dimensions area * Float size)
		result
	}

	// <summary>
	// Tranpose matrix. Creates a new matrix being the transpose of the current matrix.
	// </summary>
	// <returns>Return current matrix tranposed.</returns>
	transpose: func@ -> This {
		result := This new(this dimensions swap())
		for (y in 0 .. this dimensions height)
			for (x in 0 .. this dimensions width)
				result elements[y + x * this dimensions height] = this elements[x + y * this dimensions width]
		result
	}

	// <summary>
	// Calculates the trace of a square matrix.
	// </summary>
	// <returns>The trace of the matrix.</returns>
	trace: func -> Float {
		if (!this isSquare)
			InvalidDimensionsException new() throw()
		result := 0.0f
		for (i in 0 .. this dimensions height)
			result += this get(i, i)
		result
	}

	// <summary>
	// Swaps the position of two rows
	// </summary>
	// <param name="row1">First row</param>
	// <param name="row2">Second row</param>
	swaprows: func@ (row1, row2: Int) {
		order := this order
		buffer: Float
		if (row1 != row2) {
			for (i in 0 .. order) {
				buffer = this elements[i + row1 * this dimensions width]
				this elements[i + row1 * this dimensions width] = this elements[i + row2 * this dimensions width]
				this elements[i + row2 * this dimensions width] = buffer
			}
		}
	}

	toString: func@ -> String {
		result: String = ""
		for (y in 0 .. this dimensions height) {
			for (x in 0 .. this dimensions width)
				result = result & this get(x, y) toString() >> ", "
			result = result >> "; "
		}
		result
	}

	// <summary>
	// See http://en.wikipedia.org/wiki/LUP_decomposition.
	// Lup decomposition of the current matrix. Recall that Lup decomposition is A = LUP,
	// where L is lower triangular, U is upper triangular, and P is a permutation matrix.
	// </summary>
	// <returns>Returns the Lup decomposition. L = [0], U = [1], P = [2].</returns>
	lupDecomposition: func@ -> This[] {
		if (!this isSquare)
			InvalidDimensionsException new() throw()
		order := this order
		l := This identity(order)
		u := this copy()
		p := This identity(order)

		for (position in 0 .. order - 1) {
			pivotRow := position
			for (y in position + 1 .. u dimensions height)
				if (abs(u elements[position + position * u dimensions width]) < abs(u elements[position + y * u dimensions width]))
					pivotRow = y
			p swaprows(position, pivotRow)
			u swaprows(position, pivotRow)

			if (u elements[position + u dimensions width * position] != 0) {
				for (y in position + 1 .. order) {
					pivot := u elements[position + y * u dimensions width] / u elements[position + position * u dimensions width]
					for (x in position .. order)
						u elements[x + y * u dimensions width] = u elements[x + y * u dimensions width] - pivot * u elements[x + position * u dimensions width]
					u elements[position + y * u dimensions width] = pivot
				}
			}
		}
		for (y in 0 .. order)
			for (x in 0 .. y) {
				l elements[x + y * l dimensions width] = u elements[x + y * u dimensions width]
				u elements[x + y * u dimensions width] = 0
			}
		result := [l, u, p]
		result
	}

	// <summary>
	// Lup least square solver A * x = y.
	// The current matrix determines the matrix A above.
	// </summary>
	// <param name="y">The right hand column y vector of the equation system.</param>
	// <returns>Return the least square solution to the system.</returns>
	solve: func@ (y: This) -> This {
		result: This
		if (this dimensions width > this dimensions height)
			InvalidDimensionsException new() throw()
		// TODO: This can probably be cleaned up...
		else {
			if (this isSquare) {
				lup := this lupDecomposition()
				temp := lup[2] * y
				temp2 := temp forwardSubstitution(lup[0])
				result = temp2 backwardSubstitution(lup[1])
				temp free()
				temp2 free()
				lup[0] free()
				lup[1] free()
				lup[2] free()
				lup free()
			} else {
				temp1 := this transpose()
				temp2 := temp1 * this
				lup := temp2 lupDecomposition()
				temp2 free()
				temp2 = lup[2] * temp1
				temp1 free()
				temp1 = temp2 * y
				temp2 free()
				temp2 = temp1 forwardSubstitution(lup[0])
				result = temp2 backwardSubstitution(lup[1])
				temp1 free()
				temp2 free()
				lup[0] free()
				lup[1] free()
				lup[2] free()
				lup free()
			}
		}
		result
	}

	//TODO: Shouldn't this be a property?
	isNull: func -> Bool {
		this dimensions empty
	}

	// <summary>
	// Forward solver lower * x = y. Current object is y.
	// </summary>
	// <param name="lower">Lower triangual matrix.</param>
	// <returns>Solution x.</returns>
	forwardSubstitution: func@ (lower: This) -> This {
		result := This new(this dimensions)
		for (x in 0 .. this dimensions width)
			for (y in 0 .. this dimensions height) {
				accumulator := this elements[x + y * this dimensions width]
				for (x2 in 0 .. y)
					accumulator -= lower elements[x2 + y * lower dimensions width] * result elements[x + x2 * result dimensions width]
				value := lower elements[y + y * lower dimensions width]
				if (value != 0)
					result elements[x + y * result dimensions width] = accumulator / value
				else {
					// TODO: What do we do about this?
					/*DivisionByZeroException new() throw()*/
				}
			}
		result
	}

	// <summary>
	// Backward solver upper * x = y. Current object is y.
	// </summary>
	// <param name="lower">Upper triangual matrix.</param>
	// <returns>Solution x.</returns>
	backwardSubstitution: func@ (upper: This) -> This {
		result := This new(this dimensions)
		for (x in 0 .. this dimensions width) {
			for (antiY in 0 .. this dimensions height) {
				y := this dimensions height - 1 - antiY
				accumulator := this elements[x + y * this dimensions width]
				for (x2 in y + 1 .. upper dimensions width)
					accumulator -= upper elements[x2 + y * upper dimensions width] * result elements[x + x2 * result dimensions width]
				value := upper elements[y + y * upper dimensions width]
				if (value != 0)
					result elements[x + y * result dimensions width] = accumulator / value
				else {
					// TODO: What do we do about this?
					/*DivisionByZeroException new() throw()*/
				}
			}
		}
		result
	}

	free: func { this elements free() }

	//TODO: Remove this function once all callers have been updated to call free instead.
	dispose: func {
		this free()
	}

	operator * (other: This) -> This {
		if (this dimensions width != other dimensions height)
			raise("Invalid dimensions in FloatMatrix * operator: left width must match right height!")
		result := This new(other dimensions width, this dimensions height)
		for (x in 0 .. other dimensions width) {
			for (y in 0 .. this dimensions height) {
				temp := result elements[x + y * result dimensions width]
				for (z in 0 .. this dimensions width)
					temp += this elements[z + y * this dimensions width] * other elements[x + z * other dimensions width]
				result elements[x + y * result dimensions width] = temp
			}
		}
		result
	}

	operator + (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix + operator: dimensions must match!")
		result := This new(this dimensions)
		for (x in 0 .. this dimensions width)
			for (y in 0 .. this dimensions height)
				result elements[x + y * result dimensions width] = this elements[x + y * this dimensions width] + other elements[x + y * other dimensions width]
		result
	}

	operator - (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix - operator: dimensions must match!")
		result := This new(this dimensions)
		for (x in 0 .. this dimensions width)
			for (y in 0 .. this dimensions height)
				result elements[x + y * result dimensions width] = this elements[x + y * this dimensions width] - other elements[x + y * other dimensions width]
		result
	}
}

operator * (left: Float, right: FloatMatrix) -> FloatMatrix {
	result := FloatMatrix new(right dimensions)
	for (x in 0 .. right dimensions width)
		for (y in 0 .. right dimensions height)
			result elements[x + y * right dimensions width] = left * right elements[x + y * right dimensions width]
	result
}

DivisionByZeroException: class extends Exception {
	init: func@
}

InvalidDimensionsException: class extends Exception {
	init: func@
}
