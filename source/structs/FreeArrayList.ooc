import ArrayList

/**
 * ArrayList that assumes ownership of its contents.
 * Unlike ArrayList, frees all content upon destruction,
 * as well as when replacing elements.
 */
FreeArrayList: class <T> extends ArrayList<T> {

	init: func {
		super()
	}

	init: func ~withCapacity (.capacity) {
		super(capacity)
	}

	init: func ~withData (.data, ._size) {
		super(data, _size)
	}
	
	__destroy__: func {
		this clear()
		gc_free(data)
	}
	
	clear: func {
		if (T inheritsFrom?(Object)) {
			for (i in 0..this _size) {
				old := this[i] as Object
				old free()
			}
		}
		_size = 0
	}
	
	/**
	* Replaces the element at the specified position in this list with
	* the specified element WITHOUT RETURNING the current element.
	*/
	replaceAt: func (index: Int, element: T) {
		checkIndex(index)
		if (T inheritsFrom?(Object)) {
			old := this[index] as Object
			old free()
		}
		data[index] = element
	}
	
//	/**
//	* Removes the element at the specified position in this list
//	* WITHOUT RETURNING the current element.
//	*/
//	removeAt: func (index: SSizeT) {
//			"freeing object" println()
//		if (index < 0) index = _size + index
//		if (index < 0 || index >= _size) OutOfBoundsException new(This, index, _size) throw()
//		if (T inheritsFrom?(Object)) {
//			old := data[index] as Object
//			old free()
//		}
//	memmove(data + (index * T size), data + ((index + 1) * T size), (_size - index) * T size)
//	_size -= 1
//    }
}

/* Operators */
operator [] <T> (list: FreeArrayList<T>, r: Range) -> ArrayList<T> { list slice(r) }
operator [] <T> (list: FreeArrayList<T>, i: Int) -> T { list get(i) }
operator []= <T> (list: FreeArrayList<T>, i: Int, element: T) { list replaceAt(i, element) }
operator += <T> (list: FreeArrayList<T>, element: T) { list add(element) }
