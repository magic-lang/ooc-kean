/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Vector2D: class <T> {
	_backend: T*
	_rowCount: Int
	_columnCount: Int
	rowCount ::= this _rowCount
	columnCount ::= this _columnCount

	init: func ~preallocated (=_backend, =_rowCount, =_columnCount)
	init: func (=_rowCount, =_columnCount) {
		this _allocate(this rowCount, this columnCount)
		memset(this _backend, 0, this rowCount * this columnCount * T size)
	}
	free: override func {
		memfree(this _backend)
		super()
	}
	_allocate: func (rows, columns: Int) {
		this _backend = realloc(this _backend, rows * columns * T size)
	}
	_elementPosition: func (row, column: Int, columnCount := this columnCount) -> Int {
		columnCount * row + column
	}
	resize: func (newRowCount, newColumnCount: Int) {
		if (newColumnCount == this columnCount) {
			if (newRowCount != this rowCount) {
				this _allocate(newRowCount, newColumnCount)
				this _rowCount = newRowCount
				this _columnCount = newColumnCount
			}
		} else {
			minimumRowCount := this rowCount minimum(newRowCount)
			minimumColumnCount := this columnCount minimum(newColumnCount)
			temporaryResult: T* = calloc(newRowCount * newColumnCount, T size)

			for (row in 0 .. minimumRowCount)
				memcpy(temporaryResult[T size * this _elementPosition(row, 0, newColumnCount)]&,
					this _backend[T size * this _elementPosition(row, 0)]&, minimumColumnCount * T size)

			memfree(this _backend)
			this init(temporaryResult, newRowCount, newColumnCount)
		}
	}
	move: func (sourceRowStart, sourceColumnStart, targetRowStart, targetColumnStart: Int, columnCount := 0, rowCount := 0) {
		sourceRowIndex, targetRowIndex: Int

		if (rowCount < 1)
			rowCount = this rowCount - sourceRowStart
		if (columnCount < 1)
			columnCount = this columnCount - sourceColumnStart
		if (targetRowStart + rowCount > this rowCount)
			rowCount = this rowCount - targetRowStart
		if (targetColumnStart + columnCount > this columnCount)
			columnCount = this columnCount - targetColumnStart

		for (row in 0 .. rowCount) {
			if (sourceRowStart > targetRowStart) {
				// Move row-wise from top to bottom.
				sourceRowIndex = sourceRowStart + row
				targetRowIndex = sourceRowIndex - sourceRowStart + targetRowStart
			} else {
				//Move row-wise from bottom to top
				targetRowIndex = rowCount + targetRowStart - row - 1
				sourceRowIndex = targetRowIndex - targetRowStart + sourceRowStart
			}

			memmove(_backend[T size * this _elementPosition(targetRowIndex, targetColumnStart)]&,
				this _backend[T size * this _elementPosition(sourceRowIndex, sourceColumnStart)]&, columnCount * T size)
		}
	}

	operator [] (row, column: Int) -> T {
		version (safe)
			raise(row >= this rowCount || row < 0 || column >= this columnCount || column < 0, "Accessing Vector2D index out of range in get operator")
		this _backend[this _elementPosition(row, column)]
	}
	operator []= (row, column: Int, item: T) {
		version (safe)
			raise(row >= this rowCount || row < 0 || column >= this columnCount || column < 0, "Accessing Vector2D index out of range in set operator")
		this _backend[this _elementPosition(row, column)] = item
	}
}
