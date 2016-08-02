/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

List: abstract class <T> {
	_count := 0
	count ::= this _count
	empty ::= this _count == 0
	add: abstract func (item: T)
	append: abstract func (other: This<T>)
	insert: abstract func (index: Int, item: T)
	remove: abstract func ~last -> T
	remove: abstract func ~atIndex (index: Int) -> T
	removeAt: abstract func (index: Int)
	removeAt: func ~range (range: Range) { this removeAt(range min, range max) }
	removeAt: abstract func ~indices (start, end: Int)
	clear: abstract func
	reverse: abstract func -> This<T>
	search: abstract func (matches: Func (T) -> Bool) -> Int
	sort: abstract func (isLess: Func (T, T) -> Bool)
	copy: abstract func -> This<T>
	apply: abstract func (function: Func(T))
	modify: abstract func (function: Func(T) -> T)
	map: abstract func <S> (function: Func(T) -> S) -> This<S>
	fold: abstract func <S> (S: Class, function: Func(T, S) -> S, initial: S) -> S
	getFirstElements: abstract func (number: Int) -> This<T>
	getElements: abstract func (indices: This<Int>) -> This<T>
	getSlice: abstract func ~range (range: Range) -> This<T>
	getSlice: abstract func ~indices (start, end: Int) -> This<T>
	getSliceInto: abstract func ~range (range: Range, buffer: This<T>)
	getSliceInto: abstract func ~indices (start, end: Int, buffer: This<T>)
	iterator: abstract func -> Iterator<T>
	abstract operator [] (index: Int) -> T
	abstract operator []= (index: Int, item: T)
}
