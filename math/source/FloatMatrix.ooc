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
	Dimensions: IntSize2D {get {this dimensions}}
	elements: Float[]

	init: func@ ~IntSize2D (= dimensions)
	init: func@ ~nullConstructor { this init(0, 0) }
	init: func@ (width: Int, height: Int) {
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
		for (i in 0..order) {
			result set(i, i, 1.0f)
		}
		result
	}

	// <summary>
	// Get an element in a matrix at position(x,y).
	// </summary>
	// <param name="x">Column number of a matrix.</param>
	// <param name="y">Row number of a matrix.</param>
	// <returns></returns>
	get: func@ (x: Int, y: Int) -> Float { this elements[x + dimensions width * y] }

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
	isSquare: Bool { get {this Dimensions width  == this Dimensions height} }

	// <summary>
	// Minimum of maxtrix dimensions.
	// </summary>
	order: Int { get {Int minimum(this dimensions height, this dimensions width)}}

	// <summary>
	// Creates a copy of the current matrix.
	// </summary>
	// <returns>Return a copy of the current matrix.</returns>
	copy: func@ () -> This {
		result := This new (this dimensions width, this dimensions height)
		for (y in 0..this dimensions height) {
			for (x in 0..this dimensions width) {
				result set(x, y, this get(x, y))
			}
		}
		result
	}

	// <summary>
	// Tranpose matrix. Creates a new matrix being the transpose of the current matrix.
	// </summary>
	// <returns>Return current matrix tranposed.</returns>
	transpose: func@ () -> This {
		result := This new (this dimensions height, this dimensions width)
		for (y in 0..this dimensions height) {
			for (x in 0..this dimensions width) {
				result set(y, x, this get(x, y))
			}
		}
		result
	}

	// <summary>
	// Swaps the position of two rows
	// </summary>
	// <param name="row1">First row</param>
	// <param name="row2">Second row</param>
	swaprows: func@ (row1: Int, row2: Int) -> Void {
		order := this order
		buffer: Float
		if (row1 != row2) {
			for (i in 0..order) {
					buffer = this get(i, row1)
					this set(i, row1, this get(i, row2))
					this set(i, row2, buffer)
			}
		}
	}

	toString: func@ -> String {
		result: String = ""
		for (y in 0..this dimensions height) {
			for (x in 0..this dimensions width) {
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

		for (position in 0..order - 1) {
			pivotRow: Int = position
			for (y in position + 1..u dimensions height)
					if (abs(u get (position, position)) < abs(u get (position, y)))
						pivotRow = y
			p swaprows(position, pivotRow)
			u swaprows(position, pivotRow)

			if (u get(position, position) != 0) {
				for (y in position + 1..order) {
					pivot := u get(position, y) / u get(position, position)
					for (x in position..order)
						u set(x, y, u get(x, y) - pivot * u get(x, position))
					u set(position, y, pivot)
				}
			}
		}
		for (y in 0..order)
			for (x in 0..y) {
				l set(x, y, u get(x, y))
				u set(x, y, 0)
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
		result := This new()
		lup: This[]
		if (this dimensions width > this dimensions height) {
			InvalidDimensionsException new() throw()
		} else {
				if (this isSquare) {
					lup = this lupDecomposition()
					temp := lup[2] * y
					temp2:= temp forwardSubstitution(lup[0])
					result = temp2 backwardSubstitution(lup[1])
					temp dispose()
					temp2 dispose()
				} else {
					temp1 := this transpose()
					temp2 := temp1 * this
					lup = temp2 lupDecomposition()
					temp2 dispose()
					temp2 = lup[2] * temp1
					temp1 dispose()
					temp1 = temp2 * y
					temp2 dispose()
					temp2 = temp1 forwardSubstitution(lup[0])
					result = temp2 backwardSubstitution(lup[1])
					temp1 dispose()
					temp2 dispose()
				}
				lup[0] dispose()
				lup[1] dispose()
				lup[2] dispose()
				free(lup data)
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
		for (x in 0..this dimensions width) {
			for (y in 0..this dimensions height) {
				accumulator := this get(x, y)
				for (x2 in 0..y) {
					accumulator -= lower get(x2, y) * result get(x, x2)
				}
				value := lower get(y, y)
				if (value != 0) {
					result set(x, y, accumulator / value)
				} else {
					DivisionByZeroException new() throw()
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
		for (x in 0..this dimensions width) {
			y: Int = 0
			for (antiY in 0..this dimensions height) {
				y = this dimensions height - 1 - antiY
				accumulator := this get(x, y)
				for (x2 in y + 1..upper dimensions width) {
					accumulator -= upper get(x2, y) * result get(x, x2)
				}
				value := upper get(y, y)
				if (value != 0) {
					result set(x, y, accumulator / value)
				} else {
					DivisionByZeroException new() throw()
				}
			}
		}
		result
	}

	dispose: func {
		free(this elements data)
	}

}

// <summary>
// Multiplication of matrices.
// </summary>
// <param name="left">Left matrix in the multiplication.</param>
// <param name="right">Right matrix in the multiplication.</param>
// <returns>Product of left and right matrices.</returns>
operator * (left: FloatMatrix, right: FloatMatrix) -> FloatMatrix {
	if (left dimensions width != right dimensions height)
		InvalidDimensionsException new() throw()
	result := FloatMatrix new (right dimensions width, left dimensions height)
	for (x in 0..right dimensions width) {
		for (y in 0..left dimensions height) {
			for (z in 0..left dimensions width) {
				result set(x, y, result get(x, y) + left get(z, y) * right get(x, z))
			}
		}
	}
result
}

DivisionByZeroException: class extends Exception {
	init: func@ ()
}

InvalidDimensionsException: class extends Exception {
	init: func@ ()
}
