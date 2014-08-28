import structs/[HashBag, HashMap, ArrayList]

Dictionary: class {
  _myHashBag: HashBag
  _capacity: Int
  init: func {
    init ~withCapacity(10)
  }
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
  get: func <T> (key: String, defaultValue: T) -> T {
    result := defaultValue
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
    return _myHashBag put(key, value)
  }
  add: func <T> (key: String, value: T) -> Bool {
    return _myHashBag add(key, value)
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
}
