import structs/[HashBag, HashMap, ArrayList]

HashDictionary: class {
	_myHashBag: HashBag
	_capacity: Int
	count ::= this _myHashBag size()
	empty ::= this _myHashBag empty?()
	
	init: func { init ~withCapacity(10) }
	init: func ~withCapacity (=_capacity) {
		this _myHashBag = HashBag new(this _capacity)
	}
	init: func ~copy (other: This) {
		hashMapClone := other _myHashBag myMap clone()
		this _myHashBag = HashBag new(other _capacity)
		this _myHashBag myMap = hashMapClone
	}
	free: override func {
		free(this _myHashBag myMap keys data)
		free(this _myHashBag myMap keys)
		for (i in 0 .. (this _myHashBag myMap capacity)) {
			next := (this _myHashBag myMap buckets[i])
			next dispose()
		}
		free(this _myHashBag myMap buckets data)
		free(this _myHashBag myMap)
		free(this _myHashBag)
		super()
	}
	clone: func -> This {
		result := This new()
		hashMapClone := this _myHashBag myMap clone()
		result _myHashBag myMap = hashMapClone
		result
	}
	merge: func (other: This) -> This {
		result := this clone()
		result _myHashBag myMap merge!(other _myHashBag myMap)
		result
	}
	get: func <T> (key: String, defaultValue: T) -> T {
		result := defaultValue
		if (_myHashBag contains?(key)) {
			storedType := this _myHashBag getClass(key)
			entryValue := this _myHashBag getEntry(key, storedType) value
			if (storedType inheritsFrom?(Cell)) {
				entryValueCell := (entryValue as Cell<T>*)@
				if (T inheritsFrom?(entryValueCell type))
					result = entryValueCell get()
			}
			else if (T inheritsFrom?(storedType))
				result = this _myHashBag getEntry(key, T) value as T
		}
		result
	}
	getAsType: func <T>(key: String, T: Class, defaultValue: T) -> T {
		result := defaultValue
		if (this _myHashBag contains?(key)) {
			storedType := this _myHashBag getClass(key)
			entryValue := this _myHashBag getEntry(key, storedType) value
			if (storedType inheritsFrom?(Cell)) {
				entryValueCell := (entryValue as Cell<T>*)@
				if (T inheritsFrom?(entryValueCell type))
					result = entryValueCell get()
			}
			else if (T inheritsFrom?(storedType))
				result = entryValue as T
		}
		result
	}
	getClass: func (key: String) -> Class {
		this _myHashBag getClass(key)
	}
	getEntry: func <V> (key: String, V: Class) -> HashEntry<String, Pointer> {
		this _myHashBag getEntry(key, V)
	}
	add: func <T> (key: String, value: T) -> Bool {
		if (_myHashBag contains?(key))
			this remove(key)
		if (T inheritsFrom?(Object))
			this _myHashBag put(key, value)
		else {
			cellValue := Cell<T> new(value, T)
			this _myHashBag put(key, cellValue)
		}
	}
	remove: func (key: String) -> Bool {
		this _myHashBag remove(key)
	}
	contains: func (key: String) -> Bool {
		this _myHashBag contains?(key)
	}
	getKeys: func -> ArrayList<String> {
		this _myHashBag getKeys()
	}
	getPath: func <T> (path: String, T: Class) -> T {
		this _myHashBag getPath(path, T)
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
