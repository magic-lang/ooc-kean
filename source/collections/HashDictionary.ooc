/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import structs/HashMap

HashDictionary: class {
	_hashMap: HashMap<String, Cell<Pointer>>
	count ::= this _hashMap size
	isEmpty ::= this _hashMap isEmpty
	init: func { init ~withCapacity(10) }
	init: func ~withCapacity (capacity: SizeT) {
		this _hashMap = HashMap<String, Cell<Pointer>> new(capacity)
	}
	init: func ~copy (other: This) {
		hashMapClone := other _hashMap clone()
		this _hashMap = HashMap<String, Cell<Pointer>> new(other _hashMap capacity)
		this _hashMap = hashMapClone
	}
	free: override func {
		iterator := this _hashMap backIterator()
		while (iterator hasNext?())
			iterator next() free()
		iterator free()
		this _hashMap free()
		super()
	}
	clone: func -> This {
		result := This new()
		hashMapClone := this _hashMap clone()
		result _hashMap = hashMapClone
		result
	}
	merge: func (other: This) -> This {
		result := this clone()
		result _hashMap merge~inplace(other _hashMap)
		result
	}
	get: func <T> (key: String, defaultValue: T) -> T {
		result := defaultValue
		if (_hashMap contains(key)) {
			storedType := this getClass(key)
			entryValue := this getEntry(key, storedType) value
			if (storedType inheritsFrom?(Cell)) {
				entryValueCell := (entryValue as Cell<T>*)@
				if (T inheritsFrom?(entryValueCell T))
					result = entryValueCell get()
			}
			else if (T inheritsFrom?(storedType))
				result = this getEntry(key, T) value as T
		}
		result
	}
	getClass: func (key: String) -> Class {
		this _hashMap get(key) as Cell T
	}
	getEntry: func <V> (key: String, V: Class) -> HashEntry<String, Pointer> {
		entry: HashEntry
		result: HashEntry
		if (this _hashMap getEntry(key, entry&)) {
			cell := (entry value as Cell<V>*)@ as Cell<V>
			result = HashEntry<String, V> new(key, cell val&)
		} else {
			none := None new()
			result = HashEntry<String, V> new(key, none&)
		}
		result
	}
	put: func <T> (key: String, value: T) -> Bool {
		tmp := Cell<T> new(value)
		this _hashMap put(key, tmp)
	}
	add: func <T> (key: String, value: T) -> Bool {
		if (_hashMap contains(key))
			this remove(key)
		if (T inheritsFrom?(Object))
			this put(key, value)
		else {
			cellValue := Cell<T> new(value)
			this put(key, cellValue)
		}
	}
	remove: func (key: String) -> Bool {
		this _hashMap remove(key)
	}
	contains: func (key: String) -> Bool {
		this _hashMap contains(key)
	}
}
