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
	_rowCapacity: Int
	_columnCapacity: Int
	rowCapacity ::= this _rowCapacity
	columnCapacity ::= this _columnCapacity
	_freeContent: Bool

	init: func ~preallocated (=_backend, =_rowCapacity, =_columnCapacity, freeContent := true)
	init: func (=_rowCapacity, =_columnCapacity, freeContent := true) {
		this _freeContent = freeContent
		this _allocate(this rowCapacity, this columnCapacity)
		memset(this _backend, 0, this rowCapacity * this columnCapacity * T size)
	}
	_allocate: func (rows, columns: Int) {
		this _backend = gc_realloc(this _backend, rows * columns * T size)
	}
	free: override func {
		gc_free(this _backend)
	}
	_elementPosition: func (row, column: Int, columnCount := this columnCapacity) -> Int {
		columnCount * row + column
	}
	resize: func (newRowCapacity, newColumnCapacity: Int) {
		if (newColumnCapacity == this columnCapacity)
			if (newRowCapacity == this rowCapacity)
				return
			else
				_allocate(newRowCapacity, newColumnCapacity)
		else {
			temporaryResult: T*
			minimumRowCapacity := Int minimum(this rowCapacity, newRowCapacity)
			minimumColumnCapacity := Int minimum(this columnCapacity, newColumnCapacity)

			if (newColumnCapacity > this columnCapacity && newRowCapacity > this rowCapacity)
				temporaryResult = gc_calloc(newRowCapacity * newColumnCapacity, T size)
			else
				temporaryResult = gc_malloc(newRowCapacity * newColumnCapacity * T size)

			for (row in 0 .. minimumRowCapacity)
				memcpy(temporaryResult[T size * this _elementPosition(row, 0, newRowCapacity)]&,
					this _backend[T size * this _elementPosition(row, 0)]&, minimumColumnCapacity * T size)

			this free()
			this init(temporaryResult, newRowCapacity, newColumnCapacity)
		}
	}
	move: func (sourceRowStart, sourceColumnStart, targetRowStart, targetColumnStart: Int, rowCapacity := 0, columnCapacity := 0) {
		sourceRowIndex, targetRowIndex: Int

		if (rowCapacity < 1)
			rowCapacity = this rowCapacity - sourceRowStart
		if (columnCapacity < 1)
			columnCapacity = this columnCapacity - sourceColumnStart
		if (targetRowStart + rowCapacity > this rowCapacity)
			rowCapacity = this rowCapacity - targetRowStart
		if (targetColumnStart + columnCapacity > this columnCapacity)
			columnCapacity = this columnCapacity - targetColumnStart

		for (row in 0 .. rowCapacity) {
			if (sourceRowStart > targetRowStart) {
				// Move row-wise from top to bottom.
				sourceRowIndex = sourceRowStart + row
				targetRowIndex = sourceRowIndex - sourceRowStart + targetRowStart
			}
			else {
				//Move row-wise from bottom to top
				targetRowIndex = rowCapacity + targetRowStart - row - 1
				sourceRowIndex = targetRowIndex - targetRowStart + sourceRowStart
			}

			memmove(_backend[T size * this _elementPosition(targetRowIndex, targetColumnStart)]&,
				this _backend[T size * this _elementPosition(sourceRowIndex, sourceColumnStart)]&, columnCapacity * T size)
		}
	}
	operator [] (row, column: Int) -> T {
		version (safe) {
			if (row >= this rowCapacity || row < 0 || column >= this columnCapacity || column < 0)
				raise("Accessing Vector2D index out of range in get operator")
		}
		this _backend[this _elementPosition(row, column)]
	}
	operator []= (row, column: Int, item: T) {
		version (safe) {
			if (row >= this rowCapacity || row < 0 || column >= this columnCapacity || column < 0)
				raise("Accessing Vector2D index out of range in set operator")
		}
		this _backend[this _elementPosition(row, column)] = item
	}
}
