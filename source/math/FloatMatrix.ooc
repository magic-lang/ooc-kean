/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

FloatMatrix: cover {
	// x = column
	// y = row
	_width: Int
	_height: Int
	_elements: OwnedBuffer

	elements ::= this _elements pointer as Float*
	width: Int { get {
		result := this _width
		this free(Owner Receiver)
		result
	}}
	height: Int { get {
		result := this _height
		this free(Owner Receiver)
		result
	}}
	isNull: Bool { get {
		result := this _width == 0 || this _height == 0
		this free(Owner Receiver)
		result
	}}
	isSquare: Bool { get {
		result := this _width == this _height
		this free(Owner Receiver)
		result
	}}
	isVector: Bool { get {
		result := this _width == 1 || this _height == 1
		this free(Owner Receiver)
		result
	}}
	order: Int { get {
		result := this _width minimum(this _height)
		this free(Owner Receiver)
		result
	}}

	init: func@ ~buffer (=_elements, =_width, =_height)
	init: func@ (._width, ._height) {
		this init(OwnedBuffer new(_width * _height * Float size), _width, _height)
	}
	free: func@ -> Bool { this _elements free() }
	free: func@ ~withCriteria (criteria: Owner) -> Bool { this _elements free(criteria) }
	create: func -> This {
		result := This new(this _width, this _height)
		this free(Owner Receiver)
		result
	}
	setVertical: func (xOffset, yOffset: Int, x, y, z: Float) {
		version(safe) {
			t := this take()
			Debug error(xOffset < 0 || xOffset >= t width, "Column index out of range in FloatMatrix setVertical")
			Debug error(t height - yOffset < 3, "Element positions exceed matrix dimensions in FloatMatrix setVertical")
		}
		this[xOffset, yOffset] = x
		this[xOffset, yOffset + 1] = y
		this[xOffset, yOffset + 2] = z
	}
	getColumn: func (x: Int) -> This {
		t := this take()
		version (safe)
			Debug error(x < 0 || x >= t width, "Column index out of range in FloatMatrix getColumn")
		result := This new(1, t height)
		for (y in 0 .. t height)
			result[0, y] = t[x, y]
		this free(Owner Receiver)
		result
	}
	copy: func -> This {
		result := This new(this _elements copy(), this _width, this _height)
		this free(Owner Receiver)
		result
	}
	transpose: func -> This {
		t := this take()
		result: This
		if (t isVector && this _elements owner == Owner Receiver) {
			result = this
			width := result _width
			result _width = result _height
			result _height = width
		} else {
			result = This new(t height, t width)
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
			Debug error("Invalid dimensions in FloatMatrix trace")
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
	toString: func (decimals := 2) -> String {
		t := this take()
		result: String = ""
		for (y in 0 .. t height) {
			for (x in 0 .. t width - 1)
				result = result & t[x, y] toString(decimals) >> ", "
			result = result & t[t width - 1, y] toString(decimals)
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
			Debug error("Invalid dimensions in FloatMatrix lupDecomposition")
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
				if (uElements[position + position * uWidth] abs() < uElements[position + y * uWidth] abs())
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
		version (safe)
			Debug error(t width > t height, "Invalid dimensions in FloatMatrix solve")
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
	// Thomas algorithm for tridiagonal systems
	// https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
	solveTridiagonal: func (y: This) -> This {
		diagonalVector := this take() getDiagonal() take()
		upperDiagonalVector := this take() getDiagonal(1, 0) take()
		lowerDiagonalVector := this take() getDiagonal(0, 1) take()
		rightHandSide := y take() copy() take()
		diagonal := diagonalVector elements
		upper := upperDiagonalVector elements
		lower := lowerDiagonalVector elements
		rhs := rightHandSide elements
		result := diagonalVector create()
		length := result take() height
		upper[0] /= diagonal[0]
		rhs[0] /= diagonal[0]
		for (index in 1 .. length) {
			if (index < length - 1)
				upper[index] /= diagonal[index] - lower[index - 1] * upper[index - 1]
			rhs[index] = (rhs[index] - lower[index - 1] * rhs[index - 1]) / (diagonal[index] - lower[index - 1] * upper[index - 1])
		}
		result[0, length - 1] = rhs[length - 1]
		for (iteration in 0 .. length - 1) {
			index := length - 2 - iteration
			result[0, index] = rhs[index] - upper[index] * result take()[0, index + 1]
		}
		(diagonalVector, upperDiagonalVector, lowerDiagonalVector, rightHandSide) free()
		this free(Owner Receiver)
		y free(Owner Receiver)
		result
	}
	getDiagonal: func (startX := 0, startY := 0) -> This {
		t := this take()
		length := (t width - startX) minimum(t height - startY)
		result := This new(1, length)
		for (index in 0 .. length)
			result[0, index] = t[startX + index, startY + index]
		this free(Owner Receiver)
		result
	}
	// Forward solver lower * x = y for a lower triangular matrix. Current object is y.
	_forwardSubstitution: func (lower: This) -> This {
		t := this take()
		result := t create()
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
					resultElements[x + y * result take() width] = accumulator / value
				else
					Debug error("Division by zero in FloatMatrix forwardSubstitution")
			}
		if (thisElements != lowerElements)
			lower free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	// Backward solver upper * x = y for an upper triangular matrix. Current object is y.
	_backwardSubstitution: func (upper: This) -> This {
		t := this take()
		result := t create()
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
					Debug error("Division by zero in FloatMatrix backwardSubstitution")
			}
		}
		if (thisElements != upperElements)
			upper free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	cofactors: func -> This {
		t := this take()
		version(safe)
			Debug error(!t isSquare, "Matrix must be square in FloatMatrix cofactors")
		result := t create()
		matrixOrder := t order
		if (matrixOrder == 1)
			result[0, 0] = 1.f
		else if (matrixOrder == 2) {
			result[0, 0] = t[1, 1]
			result[0, 1] = -t[1, 0]
			result[1, 0] = -t[0, 1]
			result[1, 1] = t[0, 0]
		} else if (matrixOrder == 3) {
			result[0, 0] = t[1, 1] * t[2, 2] - t[2, 1] * t[1, 2]
			result[1, 0] = - (t[0, 1] * t[2, 2] - t[2, 1] * t[0, 2])
			result[2, 0] = t[0, 1] * t[1, 2] - t[1, 1] * t[0, 2]
			result[0, 1] = - (t[1, 0] * t[2, 2] - t[2, 0] * t[1, 2])
			result[1, 1] = t[0, 0] * t[2, 2] - t[2, 0] * t[0, 2]
			result[2, 1] = - (t[0, 0] * t[1, 2] - t[1, 0] * t[0, 2])
			result[0, 2] = t[1, 0] * t[2, 1] - t[2, 0] * t[1, 1]
			result[1, 2] = - (t[0, 0] * t[2, 1] - t[2, 0] * t[0, 1])
			result[2, 2] = t[0, 0] * t[1, 1] - t[1, 0] * t[0, 1]
		} else
			for (row in 0 .. t height) {
				sign := (row % 2 == 0) ? 1.f : -1.f
				for (col in 0 .. t width) {
					result[row, col] = t _assembleWithoutRowCol(row, col) determinant() * sign
					sign = -sign
				}
			}
		this free(Owner Receiver)
		result
	}
	adjugate: func -> This {
		version(safe)
			Debug error(!this take() isSquare, "Matrix must be square in FloatMatrix adjugate")
		result := this take() cofactors() transpose()
		this free(Owner Receiver)
		result
	}
	determinant: func -> Float {
		t := this take()
		version(safe)
			Debug error(!t isSquare, "Matrix must be square in FloatMatrix determinant")
		result := 0.f
		matrixOrder := t order
		if (matrixOrder == 1)
			result = t[0, 0]
		else if (matrixOrder == 2)
			result = t[0, 0] * t[1, 1] - t[0, 1] * t[1, 0]
		else if (matrixOrder == 3)
			result = t[0, 0] * (t[1, 1] * t[2, 2] - t[2, 1] * t[1, 2]) - t[1, 0] * (t[0, 1] * t[2, 2] - t[2, 1] * t[0, 2]) + t[2, 0] * (t[0, 1] * t[1, 2] - t[1, 1] * t[0, 2])
		else {
			sign := 1.f
			for (column in 0 .. matrixOrder) {
				value := t[0, column]
				if (!value equals(0.f)) {
					submatrix := t _assembleWithoutRowCol(0, column) take()
					result += t[0, column] * sign * submatrix determinant()
					submatrix free(Owner Sender)
				}
				sign = -sign
			}
		}
		this free(Owner Receiver)
		result
	}
	_assembleWithoutRowCol: func (row, column: Int) -> This {
		t := this take()
		submatrix := This new(t width - 1, t height - 1) take()
		submatrixRow := 0
		for (_row in 0 .. t height) {
			if (_row == row)
				continue
			submatrixCol := 0
			for (_col in 0 .. t width) {
				if (_col == column)
					continue
				submatrix[submatrixRow, submatrixCol] = t[_row, _col]
				submatrixCol += 1
			}
			submatrixRow += 1
		}
		this free(Owner Receiver)
		submatrix give()
	}
	inverse: func -> This {
		t := this take()
		determinant := t determinant()
		version(safe) {
			Debug error(!t isSquare, "Matrix must be square in FloatMatrix inverse")
			Debug error(determinant equals(0.f), "Matrix is singular in FloatMatrix inverse")
		}
		result := t cofactors() transpose() / determinant
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
		version(safe)
			Debug error(t width != other take() height, "Invalid dimensions in FloatMatrix * operator: left width must match right height!")
		otherWidth := other take() width
		(thisWidth, thisHeight) := (t width, t height)
		result := This new(otherWidth, thisHeight)
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (x in 0 .. otherWidth) {
			for (y in 0 .. thisHeight) {
				temp := resultElements[x + y * otherWidth]
				for (z in 0 .. thisWidth)
					temp += thisElements[z + y * thisWidth] * otherElements[x + z * otherWidth]
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
		version(safe)
			Debug error(t width != other take() width || t height != other take() height, "Invalid dimensions in FloatMatrix + operator: dimensions must match!")
		result := t create()
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. t width * t height)
			resultElements[i] = thisElements[i] + otherElements[i]
		if (thisElements != otherElements)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator - (other: This) -> This {
		t := this take()
		version(safe)
			Debug error(t width != other take() width || t height != other take() height, "Invalid dimensions in FloatMatrix - operator: dimensions must match!")
		result := t create()
		resultElements := result elements
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. t width * t height)
			resultElements[i] = thisElements[i] - otherElements[i]
		if (thisElements != otherElements)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator += (other: This) {
		version(safe)
			Debug error(this _width != other _width || this _height != other _height, "Invalid dimensions in FloatMatrix += operator: dimensions must match!")
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. this _width * this _height)
			thisElements[i] += otherElements[i]
		other free(Owner Receiver)
	}
	operator -= (other: This) {
		version(safe)
			Debug error(this _width != other _width || this _height != other _height, "Invalid dimensions in FloatMatrix -= operator: dimensions must match!")
		thisElements := this elements
		otherElements := other elements
		for (i in 0 .. this _width * this _height)
			thisElements[i] -= otherElements[i]
		other free(Owner Receiver)
	}
	operator * (other: Float) -> This {
		result := this take() create()
		resultElements := result elements
		thisElements := this elements
		for (i in 0 .. this _width * this _height)
			resultElements[i] = other * thisElements[i]
		this free(Owner Receiver)
		result
	}
	operator / (other: Float) -> This { this * (1.f / other) }
	operator == (other: This) -> Bool {
		result := true
		for (x in 0 .. this width)
			for (y in 0 .. this height)
				if (!(this[x, y] equals(other[x, y]))) {
					result = false
					break
				}
		this free(Owner Receiver)
		result
	}
	operator != (other: This) -> Bool {
		!(this == other)
	}
	operator [] (x, y: Int) -> Float {
		t := this take()
		version (safe)
			Debug error(x < 0 || y < 0 || x >= t width || y >= t height, "Accessing matrix element out of range in get operator")
		result := t elements[x + y * t width]
		this free(Owner Receiver)
		result
	}
	operator []= (x, y: Int, value: Float) {
		t := this take()
		version (safe)
			Debug error(x < 0 || y < 0 || x >= t width || y >= t height, "Accessing matrix element out of range in set operator")
		this elements[x + y * t width] = value
	}

	identity: static func (order: Int) -> This {
		result := This new(order, order)
		resultWidth := result take() width
		resultElements := result elements
		for (i in 0 .. order)
			resultElements[i + resultWidth * i] = 1.0f
		result
	}
}
operator * (left: Float, right: FloatMatrix) -> FloatMatrix { right * left }

extend Cell<FloatMatrix> {
	toString: func ~floatmatrix -> String { (this val as FloatMatrix) toString() }
}
