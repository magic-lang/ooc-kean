import structs/[ArrayList, HashMap]

HashBag: class {
	myMap: HashMap<String, Cell<Pointer>>

	init: func {
		init ~withCapacity(10)
	}
	init: func ~withCapacity (capacity: Int) {
		myMap = HashMap<String, Cell<Pointer>> new(capacity)
	}
	free: override func {
		iterator := this myMap backIterator()
		while (iterator hasNext?())
			iterator next() free()
		iterator free()
		this myMap free()
		super()
	}
	get: func <T> (key: String, T: Class) -> T {
		if (!contains?(key)) {
			Exception new(This, "Invalid value: %s" format(key)) throw() // TODO: more specific exception
		} else {
			storedType := getClass(key)
			if (T inheritsFrom?(storedType))
				getEntry(key, T) value as T
			else
				Exception new(This, "Invalid type: %s (stored: %s)" format(T name, storedType name)) throw() // TODO: more specific exception
		}
	}
	getClass: func (key: String) -> Class {
		myMap get(key) as Cell T
	}
	getEntry: func <V> (key: String, V: Class) -> HashEntry<String, Pointer> {
		entry: HashEntry
		if (myMap getEntry(key, entry&)) {
			cell := (entry value as Cell<V>*)@ as Cell<V>
			return HashEntry<String, V> new(key, cell val&)
		} else {
			none := None new()
			return HashEntry<String, V> new(key, none&)
		}
	}
	put: func <T> (key: String, value: T) -> Bool {
		tmp := Cell<T> new(value)
		this myMap put(key, tmp)
	}
	add: func <T> (key: String, value: T) -> Bool {
		put(key, value)
	}
	empty?: func -> Bool { myMap empty?() }
	remove: func (key: String) -> Bool {
		myMap remove(key)
	}
	size: func -> Int { myMap size }
	contains?: func (key: String) -> Bool {
		myMap contains?(key)
	}
	getKeys: func -> ArrayList<String> {
		myMap getKeys()
	}
}
