import structs/[HashBag, HashMap, ArrayList]

HashDictionary: class {
	_hashBag: HashBag
	count ::= this _hashBag size()
	empty ::= this _hashBag empty?()
	init: func { init ~withCapacity(10) }
	init: func ~withCapacity (capacity: Int) {
		this _hashBag = HashBag new(capacity)
	}
	init: func ~copy (other: This) {
		hashMapClone := other _hashBag myMap clone()
		this _hashBag = HashBag new(other _hashBag myMap capacity)
		this _hashBag myMap = hashMapClone
	}
	free: override func {
		this _hashBag free()
		super()
	}
	clone: func -> This {
		result := This new()
		hashMapClone := this _hashBag myMap clone()
		result _hashBag myMap = hashMapClone
		result
	}
	merge: func (other: This) -> This {
		result := this clone()
		result _hashBag myMap merge!(other _hashBag myMap)
		result
	}
	get: func <T> (key: String, defaultValue: T) -> T {
		result := defaultValue
		if (_hashBag contains?(key)) {
			storedType := this _hashBag getClass(key)
			entryValue := this _hashBag getEntry(key, storedType) value
			if (storedType inheritsFrom?(Cell)) {
				entryValueCell := (entryValue as Cell<T>*)@
				if (T inheritsFrom?(entryValueCell T))
					result = entryValueCell get()
			}
			else if (T inheritsFrom?(storedType))
				result = this _hashBag getEntry(key, T) value as T
		}
		result
	}
	getClass: func (key: String) -> Class {
		this _hashBag getClass(key)
	}
	getEntry: func <V> (key: String, V: Class) -> HashEntry<String, Pointer> {
		this _hashBag getEntry(key, V)
	}
	add: func <T> (key: String, value: T) -> Bool {
		if (_hashBag contains?(key))
			this remove(key)
		if (T inheritsFrom?(Object))
			this _hashBag put(key, value)
		else {
			cellValue := Cell<T> new(value)
			this _hashBag put(key, cellValue)
		}
	}
	remove: func (key: String) -> Bool {
		this _hashBag remove(key)
	}
	contains: func (key: String) -> Bool {
		this _hashBag contains?(key)
	}
	getKeys: func -> ArrayList<String> {
		this _hashBag getKeys()
	}
	getPath: func <T> (path: String, T: Class) -> T {
		this _hashBag getPath(path, T)
	}
}
