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
		if (T inheritsFrom?(Object)) {
			for (i in 0..this _size) {
				old := this[i] as Object
				old free()
			}
		}
		gc_free(data)
	}
	
	/**
	* Replaces the element at the specified position in this list with
	* the specified element WITHOUT RETURNING the current element.
	*/
	replaceAt: func(index: Int, element: T) {
		checkIndex(index)
		if (T inheritsFrom?(Object)) {
			old := this[index] as Object
			old free()
		}
		data[index] = element
	}
}
