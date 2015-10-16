import structs/[HashBag, HashMap, ArrayList]

HashDictionary: class {
	_hashBag: HashBag
	_capacity: Int
	count ::= this _hashBag size()
	empty ::= this _hashBag empty?()
	
	init: func { init ~withCapacity(10) }
	init: func ~withCapacity (=_capacity) {
		this _hashBag = HashBag new(this _capacity)
	}
	init: func ~copy (other: This) {
		hashMapClone := other _hashBag myMap clone()
		this _hashBag = HashBag new(other _capacity)
		this _hashBag myMap = hashMapClone
	}
	free: override func {
		free(this _hashBag myMap keys data)
		free(this _hashBag myMap keys)
		for (i in 0 .. (this _hashBag myMap capacity)) {
			next := (this _hashBag myMap buckets[i])
			next dispose()
		}
		free(this _hashBag myMap buckets data)
		free(this _hashBag myMap)
		free(this _hashBag)
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
	getAsType: func <T>(key: String, T: Class, defaultValue: T) -> T {
		result := defaultValue
		if (this _hashBag contains?(key)) {
			storedType := this _hashBag getClass(key)
			entryValue := this _hashBag getEntry(key, storedType) value
			if (storedType inheritsFrom?(Cell)) {
				entryValueCell := (entryValue as Cell<T>*)@
				if (T inheritsFrom?(entryValueCell T))
					result = entryValueCell get()
			}
			else if (T inheritsFrom?(storedType))
				result = entryValue as T
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

extend HashEntry {
	dispose: func {
//		free(this key as String _buffer)
		free(this key)
		free(this value)
		if (this next != null) {
			temp := this next@
			temp dispose()
			free(this next)
		}
	}
}
