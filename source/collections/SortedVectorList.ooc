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
/*
import VectorList
import Vector

SortedVectorList: class <T> extends  VectorList<T>{
	_compareValuesFunctionPointer : Func (Cell<T>, Cell<T>) -> Bool

	//init: func (f: Func (Cell<T>, Cell<T>) -> Bool) {
	init: func () {
		super()
	}

	readCompareValuesFunctionPointer: func (f: Func (Cell<T>, Cell<T>) -> Bool) {
		this  _compareValuesFunctionPointer = f
	}

	add: func (item: T) {
		super()
		this _sortVectorList()
	}

	remove: func ~last -> T {
		super()
	}

	insert: func (index: Int, item: T) {
		add(item)
	}

	remove: func (index: Int) -> T {
		super()
	}

	_sortVectorList: func () {
		compareValuesFunction := this _compareValuesFunctionPointer
		firstValue := Cell new(this _vector[0])
		secondValue := Cell new(this _vector[1])
		temporary: T
		for (i in 0..this count-1) {
			for(j in 0..this count-1) {
				firstValue = Cell new(this _vector[j])
				secondValue = Cell new(this _vector[j+1])
				if(compareValuesFunction(firstValue,secondValue)) {
					temporary = this _vector[j]
					this _vector[j] = this _vector[j + 1]
					this _vector[j + 1] = temporary
				}
			}
		}
	}

	operator [] (index: Int) -> T {
		this _vector[index]
	}

	operator []= (index: Int, item: T) {
		this _vector[index] = item
	}
}
*/
