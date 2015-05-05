import structs/[HashBag, HashMap, ArrayList]

HashDictionary: class {
	_myHashBag: HashBag
	_capacity: Int
	init: func { init ~withCapacity(10) }
	init: func ~withCapacity (=_capacity) {
		_myHashBag = HashBag new(this _capacity)
	}
	init: func ~copy (other: This) {
		hashMapClone := other _myHashBag myMap clone()
		_myHashBag = HashBag new(other _capacity)
		this _myHashBag myMap = hashMapClone
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
	/* WARNING: The defaultValue parameter for Covers must be new Cell(cover) */
	get: func <T> (key: String, defaultValue: T) -> T {
		result := defaultValue
		if (_myHashBag contains?(key)) {
			storedType := _myHashBag getClass(key)
			// is `T` a derived type or the same type as the stored type?
			if (T inheritsFrom?(storedType)) {
				result = _myHashBag getEntry(key, T) value as T
			}
		}
		result
	}
	/* WARNING: The Class parameter for Covers must be Cell<Cover> */
	getAsType: func <T>(key: String, T: Class) -> T {
		result := null
		if (_myHashBag contains?(key)) {
			storedType := _myHashBag getClass(key)
			// is `T` a derived type or the same type as the stored type?
			if (T inheritsFrom?(storedType))
				result = _myHashBag getEntry(key, T) value as T
		}
		result
	}
	getClass: func (key: String) -> Class {
		return _myHashBag getClass(key)
	}
	getEntry: func <V> (key: String, V: Class) -> HashEntry<String, Pointer> {
		return _myHashBag getEntry(key, V)
	}
	put: func <T> (key: String, value: T) -> Bool {
	if (_myHashBag contains?(key))
		this remove(key)
		return _myHashBag put(key, value)
	}
	/* WARNING: Covers must be wrapped into a Cell before adding to the dictionary */
	add: func <T> (key: String, value: T) -> Bool {
		return this put(key, value)
	}
	empty?: func -> Bool { return _myHashBag empty?() }
	remove: func (key: String) -> Bool {
		return _myHashBag remove(key)
	}
	size: func -> Int { _myHashBag size() }
	contains?: func(key: String) -> Bool {
		return _myHashBag contains?(key)
	}
	getKeys: func -> ArrayList<String> {
		return _myHashBag getKeys()
	}
	getPath: func <T> (path: String, T: Class) -> T {
		return _myHashBag getPath(path, T)
	}
	dispose: func {
		free(this _myHashBag myMap keys data)
		free(this _myHashBag myMap keys)
		for (i in 0..(this _myHashBag myMap capacity)) {
			next := (this _myHashBag myMap buckets[i])
			next dispose()
		}
		free(this _myHashBag myMap buckets data)
		free(this _myHashBag myMap)
		free(this _myHashBag)
		free(this)
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
