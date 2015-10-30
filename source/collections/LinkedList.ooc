import structs/List

LinkedList: class <T> {
	_size = 0 : SizeT
	size ::= _size as Int
	head: Node<T>
	init: func {
		this head = Node<T> new()
		this head prev = this head
		this head next = this head
	}
	free: override func {
		this clear()
		super()
	}
	add: func (data: T) {
		node := Node<T> new(this head prev, head, data)
		this head prev next = node
		this head prev = node
		this _size += 1
	}
	add: func ~withIndex (index: SSizeT, data: T) {
		if (index > 0 && index < this size) {
			prevNode := getNode(index - 1)
			nextNode := prevNode next
			node := Node<T> new(prevNode, nextNode, data)
			prevNode next = node
			nextNode prev = node
			this _size += 1
		} else if (index > 0 && index == _size) {
			this add(data)
		} else if (index == 0) {
			node := Node<T> new(this head, head next, data)
			this head next prev = node
			this head next = node
			_size += 1
		} else
			raise("Index out of bounds in LinkedList add~withIndex")
	}
	get: func (index: SSizeT) -> T {
		this getNode(index) data
	}
	getNode: func (index: SSizeT) -> Node<T> {
		if (index < 0 || index >= _size)
			raise("Index out of bounds in LinkedList getNode")
		i := 0
		current := this head next
		while (current next != this head && i < index) {
			current = current next
			i += 1
		}
		current
	}
	clear: func {
		while (this size > 0)
			this removeAt(0)
		this head next = this head
		this head prev = this head
	}
	indexOf: func (data: T) -> SSizeT {
		current := head next
		i := 0
		index := -1
		while (current != this head) {
			if (memcmp(current data, data, T size) == 0) {
				index = i
				break
			}
			i += 1
			current = current next
		}
		index
	}
	lastIndexOf: func (data: T) -> SSizeT {
		current := this head prev
		i := _size - 1
		index := -1
		while (current != this head) {
			if (memcmp(current data, data, T size) == 0) {
				index = i
				break
			}
			i -= 1
			current = current prev
		}
		index
	}
	first: func -> T {
		data := null
		if (head next != this head)
			data = this head next data
		data
	}
	last: func -> T {
		data := null
		if (this head prev != this head)
			data = this head prev data
		data
	}
	removeAt: func (index: SSizeT) -> T {
		item := null
		if (head next != head && 0 <= index && index < _size) {
			toRemove := getNode(index)
			removeNode(toRemove)
			item = toRemove data
		} else
			raise("Index out of bounds in LinkedList removeAt")
		item
	}
	remove: func (data: T) -> Bool {
		result := false
		i := indexOf(data)
		if (i != -1) {
			removeAt(i)
			result = true
		}
		result
	}
	removeNode: func (toRemove: Node<T>) {
		toRemove prev next = toRemove next
		toRemove next prev = toRemove prev
		toRemove prev = null
		toRemove next = null
		toRemove free()
		_size -= 1
	}
	removeLast: func -> Bool {
		result := false
		if (head prev != head) {
			removeNode(head prev)
			result = true
		}
		result
	}
	set: func (index: SSizeT, data: T) -> T {
		node := this getNode(index)
		previousData := node data
		node data = data
		previousData
	}
	copy: func -> This<T> {
		other := This<T> new()
		for (i in 0 .. this size)
			other add(this get(i))
		other
	}
}

operator [] <T>(list: LinkedList<T>, index: Int) -> T { list get(index) }
operator []= <T>(list: LinkedList<T>, index: Int, value: T) { list set(index, value) }

Node: class <T> {
	prev: This<T>
	next: This<T>
	data: T //TODO: Auto-wrap covers in Cell<T>
	init: func
	init: func ~withParams (=prev, =next, =data)
	free: override func {
		//gc_malloc(data)
		super()
	}
}
