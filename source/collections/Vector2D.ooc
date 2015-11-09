/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
import math

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
	_allocate: func (rows, columns: Int) {
		this _backend = gc_realloc(this _backend, rows * columns * T size)
	}
	free: override func {
		gc_free(this _backend)
		super()
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
			temporaryResult: T*
			minimumRowCount := Int minimum(this rowCount, newRowCount)
			minimumColumnCount := Int minimum(this columnCount, newColumnCount)

			if (newRowCount > this rowCount && newColumnCount > this columnCount)
				temporaryResult = gc_calloc(newRowCount * newColumnCount, T size)
			else
				temporaryResult = gc_malloc(newRowCount * newColumnCount * T size)

			for (row in 0 .. minimumRowCount)
				memcpy(temporaryResult[T size * this _elementPosition(row, 0, newColumnCount)]&,
					this _backend[T size * this _elementPosition(row, 0)]&, minimumColumnCount * T size)

			gc_free(this _backend)
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
		version (safe) {
			if (row >= this rowCount || row < 0 || column >= this columnCount || column < 0)
				raise("Accessing Vector2D index out of range in get operator")
		}
		this _backend[this _elementPosition(row, column)]
	}
	operator []= (row, column: Int, item: T) {
		version (safe) {
			if (row >= this rowCount || row < 0 || column >= this columnCount || column < 0)
				raise("Accessing Vector2D index out of range in set operator")
		}
		this _backend[this _elementPosition(row, column)] = item
	}
}
