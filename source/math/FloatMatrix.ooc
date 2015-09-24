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
	dimensions: IntSize2D
	Dimensions: IntSize2D { get { this dimensions } }
	elements: Float[]

	init: func@ ~IntSize2D (= dimensions)
	init: func@ ~nullConstructor { this init(0, 0) }
	init: func@ (width, height: Int) {
		this init(IntSize2D new(width, height))
		this elements = Float[width * height] new()
	}

	// <summary>
	// Creates an identity matrix of given order.
	// </summary>
	// <param name="order">Order of matrix to be created.</param>
	// <returns>Identity matrix of given order.</returns>
	identity: static func@ (order: Int) -> This {
		result := This new (order, order)
		for (i in 0 .. order) {
			result elements[i + result dimensions width * i] = 1.0f
		}
		result
	}

	// <summary>
	// Get an element in a matrix at position(x,y).
	// </summary>
	// <param name="x">Column number of a matrix.</param>
	// <param name="y">Row number of a matrix.</param>
	// <returns></returns>
	get: func@ (x, y: Int) -> Float { this elements[x + dimensions width * y] }

	// <summary>
	// Set an element in a matrix at position(x,y).
	// </summary>
	// <param name="x">Column number of a matrix.</param>
	// <param name="y">Row number of a matrix.</param>
	// <param name="value">The value set at (x,y).</param>
	// <returns></returns>
	set: func@ (x: Int, y: Int, value: Float) { this elements[x + dimensions width * y] = value }

	// <summary>
	// True if the matrix is a square matrix.
	// </summary>
	isSquare: Bool { get { this Dimensions width == this Dimensions height } }

	// <summary>
	// Minimum of maxtrix dimensions.
	// </summary>
	order: Int { get { Int minimum~two(this dimensions height, this dimensions width) } }

	// <summary>
	// Creates a copy of the current matrix.
	// </summary>
	// <returns>Return a copy of the current matrix.</returns>
	copy: func@ -> This {
		result := This new(this dimensions width, this dimensions height)
		memcpy(result elements data, this elements data, this dimensions area * Float size)
		result
	}

	// <summary>
	// Tranpose matrix. Creates a new matrix being the transpose of the current matrix.
	// </summary>
	// <returns>Return current matrix tranposed.</returns>
	transpose: func@ -> This {
		result := This new (this dimensions height, this dimensions width)
		for (y in 0 .. this dimensions height)
			for (x in 0 .. this dimensions width)
				result elements[y + this dimensions height * x] = this elements[x + this dimensions width * y]
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
				buffer = this elements[i + this dimensions width * row1]
				this elements[i + this dimensions width * row1] = this elements[i + this dimensions width * row2]
				this elements[i + this dimensions width * row2] = buffer
			}
		}
	}

	toString: func@ -> String {
		result: String = ""
		for (y in 0 .. this dimensions height) {
			for (x in 0 .. this dimensions width) {
				result += this get(x, y) toString() + ", "
			}
			result += "; "
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
			pivotRow: Int = position
			for (y in position + 1 .. u dimensions height)
				if (abs(u elements[position + u dimensions width * position]) < abs(u elements[position + u dimensions width * y]))
					pivotRow = y
			p swaprows(position, pivotRow)
			u swaprows(position, pivotRow)

			if (u elements[position + u dimensions width * position] != 0) {
				for (y in position + 1 .. order) {
					pivot := u elements[position + u dimensions width * y] / u elements[position + u dimensions width * position]
					for (x in position .. order)
						u elements[x + u dimensions width * y] = u elements[x + u dimensions width * y] - pivot * u elements[x + u dimensions width * position]
					u elements[position + u dimensions width * y] = pivot
				}
			}
		}
		for (y in 0 .. order)
			for (x in 0 .. y) {
				l elements[x + l dimensions width * y] = u elements[x + u dimensions width * y]
				u elements[x + u dimensions width * y] = 0
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
		if (this dimensions width > this dimensions height) {
			InvalidDimensionsException new() throw()
		} else {
			if (this isSquare) {
				lup := this lupDecomposition()
				temp := lup[2] * y
				temp2 := temp forwardSubstitution(lup[0])
				result = temp2 backwardSubstitution(lup[1])
				temp dispose()
				temp2 dispose()
				lup[0] dispose()
				lup[1] dispose()
				lup[2] dispose()
				gc_free(lup data)
			} else {
				temp1 := this transpose()
				temp2 := temp1 * this
				lup := temp2 lupDecomposition()
				temp2 dispose()
				temp2 = lup[2] * temp1
				temp1 dispose()
				temp1 = temp2 * y
				temp2 dispose()
				temp2 = temp1 forwardSubstitution(lup[0])
				result = temp2 backwardSubstitution(lup[1])
				temp1 dispose()
				temp2 dispose()
				lup[0] dispose()
				lup[1] dispose()
				lup[2] dispose()
				gc_free(lup data)
			}
		}
		result
	}

	isNull: func -> Bool{
		return this dimensions width == 0 && this dimensions height == 0
	}

	// <summary>
	// Forward solver lower * x = y. Current object is y.
	// </summary>
	// <param name="lower">Lower triangual matrix.</param>
	// <returns>Solution x.</returns>
	forwardSubstitution: func@ (lower: This) -> This {
		result := This new(this dimensions width, this dimensions height)
		for (x in 0 .. this dimensions width) {
			for (y in 0 .. this dimensions height) {
				accumulator := this elements[x + this dimensions width * y]
				for (x2 in 0 .. y) {
					accumulator -= lower elements[x2 + lower dimensions width * y] * result elements[x + result dimensions width * x2]
				}
				value := lower elements[y + lower dimensions width * y]
				if (value != 0) {
					result elements[x + result dimensions width * y] = accumulator / value
				} else {
					/*DivisionByZeroException new() throw()*/
				}
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
		result := This new(this dimensions width, this dimensions height)
		for (x in 0 .. this dimensions width) {
			y: Int = 0
			for (antiY in 0 .. this dimensions height) {
				y = this dimensions height - 1 - antiY
				accumulator := this elements[x + this dimensions width * y]
				for (x2 in y + 1 .. upper dimensions width) {
					accumulator -= upper elements[x2 + upper dimensions width * y] * result elements[x + result dimensions width * x2]
				}
				value := upper elements[y + upper dimensions width * y]
				if (value != 0)
					result elements[x + result dimensions width * y] = accumulator / value
				else {
					/*DivisionByZeroException new() throw()*/
				}
			}
		}
		result
	}

	dispose: func {
		version(!gc) {
			gc_free(this elements data)
		}
	}

	operator * (other: This) -> This {
		if (this dimensions width != other dimensions height)
			raise("Invalid dimensions in FloatMatrix * operator: left width must match right height!")
		result := This new (other dimensions width, this dimensions height)
		for (x in 0 .. other dimensions width) {
			for (y in 0 .. this dimensions height) {
				temp := result elements[x + result dimensions width * y]
				for (z in 0 .. this dimensions width)
					temp += this elements[z + this dimensions width * y] * other elements[x + other dimensions width * z]
				result elements[x + result dimensions width * y] = temp
			}
		}
	result
	}

	operator + (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix + operator: dimensions must match!")
		result := This new (this dimensions width, this dimensions height)
		for (x in 0 .. this dimensions width)
			for (y in 0 .. this dimensions height)
				result elements[x + result dimensions width * y] = this elements[x + this dimensions width * y] + other elements[x + other dimensions width * y]
	result
	}

	operator - (other: This) -> This {
		if (this dimensions != other dimensions)
			raise("Invalid dimensions in FloatMatrix - operator: dimensions must match!")
		result := This new (this dimensions width, this dimensions height)
		for (x in 0 .. this dimensions width)
			for (y in 0 .. this dimensions height)
				result elements[x + result dimensions width * y] = this elements[x + this dimensions width * y] - other elements[x + other dimensions width * y]
	result
	}
}

operator * (left: Float, right: FloatMatrix) -> FloatMatrix {
	result := FloatMatrix new (right dimensions width, right dimensions height)
	for (x in 0 .. right dimensions width)
		for (y in 0 .. right dimensions height)
			result elements[x + right dimensions width * y] = left * right elements[x + right dimensions width * y]
	result
}

DivisionByZeroException: class extends Exception {
	init: func@
}

InvalidDimensionsException: class extends Exception {
	init: func@
}
