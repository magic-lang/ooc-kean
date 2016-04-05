/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

LinkedList: class <T> {
	_head: Node<T>
	_size := 0
	head ::= this _head
	size ::= this _size
	init: func {
		this _head = Node<T> new()
		this _head prev = this _head
		this _head next = this _head
	}
	free: override func {
		this clear()
		this _head free()
		super()
	}
	add: func (data: T) {
		node := Node<T> new(this _head prev, this _head, data)
		this _head prev next = node
		this _head prev = node
		this _size += 1
	}
	add: func ~withIndex (index: Int, data: T) {
		if (index > 0 && index < this size) {
			prevNode := this getNode(index - 1)
			nextNode := prevNode next
			node := Node<T> new(prevNode, nextNode, data)
			prevNode next = node
			nextNode prev = node
			this _size += 1
		} else if (index > 0 && index == this _size)
			this add(data)
		else if (index == 0) {
			node := Node<T> new(this _head, this _head next, data)
			this _head next prev = node
			this _head next = node
			this _size += 1
		} else
			raise("Index out of bounds in LinkedList add~withIndex")
	}
	get: func (index: Int) -> T {
		this getNode(index) data
	}
	getNode: func (index: Int) -> Node<T> {
		if (index < 0 || index >= this _size)
			raise("Index out of bounds in LinkedList getNode")
		i := 0
		current := this _head next
		while (current next != this _head && i < index) {
			current = current next
			i += 1
		}
		current
	}
	clear: func {
		while (this size > 0)
			this removeAt(0)
		this _head next = this _head
		this _head prev = this _head
	}
	indexOf: func (data: T) -> Int {
		current := this _head next
		i := 0
		index := -1
		while (current != this _head) {
			if (memcmp(current data, data, T size) == 0) {
				index = i
				break
			}
			i += 1
			current = current next
		}
		index
	}
	lastIndexOf: func (data: T) -> Int {
		current := this _head prev
		i := this _size - 1
		index := -1
		while (current != this _head) {
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
		data: T = null
		if (this _head next != this _head)
			data = this _head next data
		data
	}
	last: func -> T {
		data: T = null
		if (this _head prev != this _head)
			data = this _head prev data
		data
	}
	removeAt: func (index: Int) -> T {
		item: T = null
		if (this _head next != this _head && 0 <= index && index < this _size) {
			toRemove := this getNode(index)
			item = this removeNode(toRemove)
		} else
			raise("Index out of bounds in LinkedList removeAt")
		item
	}
	remove: func (data: T) -> Bool {
		result := false
		i := this indexOf(data)
		if (i != -1) {
			this removeAt(i)
			result = true
		}
		result
	}
	removeNode: func (toRemove: Node<T>) -> T {
		toRemove prev next = toRemove next
		toRemove next prev = toRemove prev
		toRemove prev = null
		toRemove next = null
		data := toRemove data
		toRemove free()
		this _size -= 1
		data
	}
	removeLast: func -> Bool {
		result := false
		if (this _head prev != this _head) {
			this removeNode(this _head prev)
			result = true
		}
		result
	}
	set: func (index: Int, data: T) -> T {
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
	data: __onheap__ T
	init: func
	init: func ~withParams (=prev, =next, =data)
	free: override func {
		if (T inheritsFrom(Object))
			memfree(this data)
		super()
	}
}
