import List

ArrayList: class <T> extends List<T> {
	data : T*
	capacity : SizeT
	_size = 0 : SizeT

	size ::= _size

	init: func {
		init(10)
	}

	init: func ~withCapacity (=capacity) {
		data = gc_malloc(capacity * T size)
	}

	init: func ~withData (.data, =_size) {
		this data = gc_malloc(_size * T size)
		memcpy(this data, data, _size * T size)
		capacity = _size
	}

	free: override func {
		gc_free(this data)
		super()
	}

	add: override func (element: T) {
		ensureCapacity(_size + 1)
		data[_size] = element
		_size += 1
	}

	add: override func ~withIndex (index: SSizeT, element: T) {
		if (index < 0) index = _size + index
		if (index < 0 || index > _size) OutOfBoundsException new(This, index, _size) throw()

		// inserting at 0 can be optimized
		if (index == 0) {
			ensureCapacity(_size + 1)
			dst, src: Octet*
			dst = data + (T size)
			src = data
			memmove(dst, src, T size * _size)
			data[0] = element
			_size += 1
			return
		}

		if (index == _size) {
			add(element)
			return
		}

		checkIndex(index)
		ensureCapacity(_size + 1)
		dst, src: Octet*
		dst = data + (T size * (index + 1))
		src = data + (T size * index)
		bsize := (_size - index) * T size
		memmove(dst, src, bsize)
		data[index] = element
		_size += 1
	}

	clear: override func {
		_size = 0
	}

	get: override func (index: SSizeT) -> T {
		if (index < 0) index = _size + index
		if (index < 0 || index >= _size) OutOfBoundsException new(This, index, _size) throw()
		checkIndex(index)
		return data[index]
	}

	indexOf: override func (element: T) -> SSizeT {
		index := 0
		while (index < _size) {
			//if (memcmp(data + index * T size, element, T size) == 0) return index
			if (this as List equals(this[index], element)) return index
			index += 1
		}
		return -1
	}

	lastIndexOf: override func (element: T) -> SSizeT {
		index := _size
		while (index > -1) {
			if (memcmp(data + index * T size, element, T size) == 0) return index
			index -= 1
		}
		return -1
	}

	removeAt: override func (index: SSizeT) -> T {
		if (index < 0) index = _size + index
		if (index < 0 || index >= _size) OutOfBoundsException new(This, index, _size) throw()

		element := data[index]
		memmove(data + (index * T size), data + ((index + 1) * T size), (_size - index) * T size)
		_size -= 1
		return element
	}

	sort: func (greaterThan: Func (T, T) -> Bool) {
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0 .. size - 1) {
				if (greaterThan(this[i], this[i + 1])) {
					inOrder = false
					tmp := this[i]
					this[i] = this[i + 1]
					this[i + 1] = tmp
				}
			}
		}
	}

	remove: override func (element: T) -> Bool {
		index := indexOf(element)
		if (index == -1) return false
		else {
			removeAt(index)
		}
		return true
	}

	set: override func (index: Int, element: T) -> T {
		checkIndex(index)
		old := data[index]
		data[index] = element
		old
	}

	replaceAt: func (index: Int, element: T) {
		checkIndex(index)
		data[index] = element
	}

	getSize: override func -> SizeT { _size }

	ensureCapacity: func (newSize: SizeT) {
		if (newSize > capacity) {
			capacity = newSize * (newSize > 50000 ? 2 : 4)
			tmpData := gc_realloc(data, capacity * T size)
			if (tmpData) {
				data = tmpData
			} else {
				OutOfMemoryException new(This) throw()
			}
		}
	}

	/** private */
	checkIndex: func (index: SSizeT) {
		if (index >= _size) {
			OutOfBoundsException new(This, index, _size) throw()
		}
	}

	iterator: override func -> BackIterator<T> { return ArrayListIterator<T> new(this) }

	backIterator: func -> BackIterator<T> {
		iter := ArrayListIterator<T> new(this)
		iter index = _size
		return iter
	}

	clone: override func -> This<T> {
		copy := This<T> new(size)
		copy addAll(this)
		return copy
	}

	emptyClone: override func <K> -> This<K> {
		This<K> new()
	}

	/** */
	toArray: func -> Pointer {
		data
	}

	slice: func (min, max: SSizeT) -> This<T> {
		if (min < 0) min = _size + min
		if (min < 0 || min >= _size) OutOfBoundsException new(This, min, _size) throw()

		if (max < 0) max = _size + max
		if (max < 0 || max >= _size) OutOfBoundsException new(This, max, _size) throw()

		// We use +1 since it's zero based, and we want the *size* instead of the last index
		retSize := max - min + 1

		ret := This<T> new(retSize)
		/*for (i in min..(max + 1)) { // Used (max + 1) to compensate for Ranges being exclusive
			ret add(this[i])
		}*/
		memcpy(ret data, data + (min * T size), (retSize) * T size)
		ret _size = retSize
		ret capacity = retSize

		ret
	}

	slice: func ~withRange (r: Range) -> This<T> {
		slice(r min, r max)
	}
}

ArrayListIterator: class <T> extends BackIterator<T> {
	list: ArrayList<T>
	index : SSizeT = 0

	_canRemove := false

	init: func ~iter (=list)

	hasNext?: override func -> Bool { index < list size }

	next: override func -> T {
		_canRemove = true
		index += 1
		list get(index - 1)
	}

	hasPrev?: override func -> Bool { index > 0 }

	prev: override func -> T {
		index -= 1
		list get(index)
	}

	remove: override func -> Bool {
		if (!_canRemove) {
			IllegalIteratorOpException new(class, \
				"ArrayListIterator remove() called twice in a single iteration - that's illegal.") throw()
		}
		_canRemove = false

		list removeAt(index - 1)

		if (index <= list size) {
			index -= 1
		}

		true
	}
}

IllegalIteratorOpException: class extends Exception {
	init: func (.origin, .message) {
		super(origin, message)
	}
}

operator [] <T> (list: ArrayList<T>, r: Range) -> ArrayList<T> { list slice(r) }
operator [] <T> (list: ArrayList<T>, i: Int) -> T { list get(i) }
operator []= <T> (list: ArrayList<T>, i: Int, element: T) { list replaceAt(i, element) }
operator += <T> (list: ArrayList<T>, element: T) { list add(element) }
operator -= <T> (list: ArrayList<T>, element: T) -> Bool { list remove(element) }
operator as <T> (array: T[]) -> ArrayList<T> { ArrayList<T> new(array data, array length) }
