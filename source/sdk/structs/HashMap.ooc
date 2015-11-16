import lang/equalities
import ArrayList

/**
 * Container for key/value entries in the hash table
 */
HashEntry: cover {

    key, value: Pointer
    next: HashEntry* = null

    init: func@ ~keyVal (=key, =value)
    free: func {
      free(this key)
      free(this value)
      if (this next != null) {
        temp := this next@
        temp free()
        free(this next)
      }
    }

}

nullHashEntry: HashEntry
memset(nullHashEntry&, 0, HashEntry size)

intHash: func <K> (key: K) -> SizeT {
    result: SizeT = key as Int
    return result
}

pointerHash: func <K> (key: K) -> SizeT {
    return (key as Pointer) as SizeT
}

charHash: func <K> (key: K) -> SizeT {
    // both casts are necessary
    // Casting 'key' directly to UInt would deref a pointer to UInt
    // which would read random memory just after the char, which is not a good idea..
    return (key as Char) as SizeT
}

/**
   Port of Austin Appleby's Murmur Hash implementation
   http://code.google.com/p/smhasher/

   :param: key The key to hash
   :param: seed The seed value
 */
murmurHash: func <K> (keyTagazok: K) -> SizeT {

    seed: SizeT = 1 // TODO: figure out what makes a good seed value?

    len := K size
    m = 0x5bd1e995 : const SizeT
    r = 24 : const SSizeT
    l := len

    h : SizeT = seed ^ len
    data := (keyTagazok&) as Octet*

    while (true) {
        k := (data as SizeT*)@

        k *= m
        k ^= k >> r
        k *= m

        h *= m
        h ^= k

        data += 4
        if(len < 4) break
        len -= 4
    }

    t := 0

    if(len == 3) h ^= data[2] << 16
    if(len == 2) h ^= data[1] << 8
    if(len == 1) h ^= data[0]

    t *= m; t ^= t >> r; t *= m; h *= m; h ^= t;
    l *= m; l ^= l >> r; l *= m; h *= m; h ^= l;

    h ^= h >> 13
    h *= m
    h ^= h >> 15

    return h
}

/**
 * khash's ac_X31_hash_string
 * http://attractivechaos.awardspace.com/khash.h.html
 * @access private
 * @param s The string to hash
 * @return UInt
 */
ac_X31_hash: func <K> (key: K) -> SizeT {
    assert(key != null)
    s : Char* = (K == String) ? (key as String) toCString() as Char* : key as Char*
    h = s@ : SizeT
    if (h) {
        s += 1
        while (s@) {
            h = (h << 5) - h + s@
            s += 1
        }
    }
    return h
}

getStandardHashFunc: func <T> (T: Class) -> Func <T> (T) -> SizeT {
    if(T == String || T == CString) {
        ac_X31_hash
    } else if(T size == Pointer size) {
        pointerHash
    } else if(T size == UInt size) {
        intHash
    } else if(T size == Char size) {
        charHash
    } else {
        murmurHash
    }
}

/**
 * Simple hash table implementation
 */

HashMap: class <K, V> extends BackIterable<V> {

    _size, capacity: SizeT
    keyEquals: Func <K> (K, K) -> Bool
    hashKey: Func <K> (K) -> SizeT

    buckets: HashEntry[]
    keys: ArrayList<K>

    size: SizeT {
    	get {
            _size
 	}
    }

    /**
     * Returns a new hash map
     */

    init: func {
        init(3)
    }

    /**
     * Returns a hash table of a specified bucket capacity.
     * @param UInt capacity The number of buckets to use
     */
    init: func ~withCapacity (=capacity) {
        _size = 0

        buckets = HashEntry[capacity] new()
        keys = ArrayList<K> new()

        keyEquals = getStandardEquals(K)
        hashKey = getStandardHashFunc(K)

        T = V // workarounds ftw
    }

    free: override func {
      for (i in 0 .. this buckets length)
        this buckets[i] free()
      this buckets free()
      this keys free()
      super()
    }

    /**
     * Retrieve the HashEntry associated with a key.
     * @param key The key associated with the HashEntry
     */
    getEntry: func (key: K, result: HashEntry*) -> Bool {
        hash : SizeT = hashKey(key) % capacity
        entry := buckets[hash]

        if(entry key == null) { return false }

        while (true) {
            if (keyEquals(entry key as K, key)) {
                if(result) {
                    result@ = entry
                }
                return true
            }

            if (entry next) {
                entry = entry next@
            } else {
                return false
            }
        }
        return false
    }

    /**
     * Returns the HashEntry associated with a key.
     * @access private
     * @param key The key associated with the HashEntry
     * @return HashEntry
     */
    getEntryForHash: func (key: K, hash: SizeT, result: HashEntry*) -> Bool {
        entry := buckets[hash]

        if(entry key == null) {
            return false
        }

        while (true) {
            if (keyEquals(entry key as K, key)) {
                if(result) {
                    result@ = entry
                }
                return true
            }

            if (entry next) {
                entry = entry next@
            } else {
                return false
            }
        }
        return false
    }

    clone: func -> HashMap<K, V> {
        copy := This<K, V> new()
        each(|k, v| copy put(k, v))
        copy
    }

    merge: func (other: HashMap<K, V>) -> HashMap<K, V> {
        c := clone()
        c merge!(other)
        c
    }

    merge!: func (other: HashMap<K, V>) -> HashMap<K, V> {
        other each(|k, v| put(k, v))
        this
    }

    /**
     * Puts a key/value pair in the hash table. If the pair already exists,
     * it is overwritten.
     * @param key The key to be hashed
     * @param value The value associated with the key
     * @return Bool
     */
    put: func (key: K, value: V) -> Bool {

        hash : SizeT = hashKey(key) % capacity

        entry : HashEntry

        if (getEntryForHash(key, hash, entry&)) {
            // replace value if the key is already existing
            memcpy(entry value, value, V size)
        } else {
            keys add(key)

            current := buckets[hash]
            if (current key != null) {
                //" - Appending!" println()
                currentPointer := (buckets data as HashEntry*)[hash]&

                while (currentPointer@ next) {
                    //" - Skipping!" println()
                    currentPointer = currentPointer@ next
                }
                newEntry := gc_malloc(HashEntry size) as HashEntry*

                newEntry@ key   = gc_malloc(K size)
                memcpy(newEntry@ key,   key, K size)

                newEntry@ value = gc_malloc(V size)
                memcpy(newEntry@ value, value, V size)

                currentPointer@ next = newEntry
            } else {
                entry key   = gc_malloc(K size)
                memcpy(entry key,   key, K size)

                entry value = gc_malloc(V size)
                memcpy(entry value, value, V size)

                entry next = null

                buckets[hash] = entry
            }
            _size += 1

            if ((_size as Float / capacity as Float) > 0.75) {
                resize(_size * (_size > 50000 ? 2 : 4))
            }
        }
        return true
    }

    /**
     * Alias of put
     */
    add: inline func (key: K, value: V) -> Bool {
        return put(key, value)
    }

    /**
     * Returns the value associated with the key. Returns null if the key
     * does not exist.
     * @param key The key associated with the value
     * @return Object
     */
    get: func (key: K) -> V {
        entry: HashEntry

        if (getEntry(key, entry&)) {
            return entry value as V
        }
        return null
    }

    /**
     * @return true if this map is empty, false if not
     */
    empty?: func -> Bool { keys empty?() }

    /**
     * Returns whether or not the key exists in the hash table.
     * @param key The key to check
     * @return Bool
     */
    contains?: func (key: K) -> Bool {
        getEntry(key, null)
    }

    /**
     * Removes the entry associated with the key
     * @param key The key to remove
     * @return Bool
     */
    remove: func (key: K) -> Bool {
        hash : SizeT = hashKey(key) % capacity

        prev = null : HashEntry*
        entry: HashEntry* = (buckets data as HashEntry*)[hash]&
        if (entry@ key == null) return false

        while (true) {
            if (keyEquals(entry@ key as K, key)) {
              free(entry@ key)
              free(entry@ value)

                if(prev) {
                    // re-connect the previous to the next one
                    prev@ next = entry@ next
                } else {
                    // just put the next one instead of us
                    if(entry@ next) {
                        buckets[hash] = entry@ next@
                    } else {
                        buckets[hash] = nullHashEntry
                    }
                }
                for (i in 0..keys size) {
                    cKey := keys get(i)
                    if(keyEquals(key, cKey)) {
                        keys removeAt(i)
                        break
                    }
                }
                _size -= 1
                return true
            }

            // do we have a next element?
            if(entry@ next) {
                // save the previous just to know where to reconnect
                prev = entry
                entry = entry@ next
            } else {
                return false
            }
        }
        return false
    }

    /**
     * Resizes the hash table to a new capacity
     * :param: _capacity The new table capacity
     * :return:
     */
    resize: func (_capacity: SizeT) -> Bool {

        /* Keep track of old settings */
        oldCapacity := capacity
        oldBuckets := buckets

        /* Clear key list and size */
        oldKeys := keys clone()
        keys clear()
        _size = 0

        /* Transfer old buckets to new buckets! */
        capacity = _capacity
        buckets = HashEntry[capacity] new()

        for (i in 0..oldCapacity) {
            entry := oldBuckets[i]
            if (entry key == null) continue

            put(entry key as K, entry value as V)

            while (entry next) {
                entry = entry next@
                put(entry key as K, entry value as V)
            }
        }

        // restore old keys to keep order
        keys = oldKeys

        return true
    }

    iterator: func -> BackIterator<V> {
        HashMapValueIterator<K, V> new(this)
    }

    backIterator: func -> BackIterator<V> {
        iter := HashMapValueIterator<K, V> new(this)
        iter index = keys getSize()
        return iter
    }

    clear: func {
        _size = 0
        for (i in 0..capacity) {
            buckets[i] = nullHashEntry
        }
        keys clear()
    }

    getSize: func -> SSizeT { _size }

    getKeys: func -> ArrayList<K> { keys }

    each: func ~withKeys (f: Func (K, V)) {
        for(key in getKeys()) {
            f(key, get(key))
        }
    }

    each: func (f: Func (V)) {
        for(key in getKeys()) {
            f(get(key))
        }
    }

}

HashMapValueIterator: class <K, T> extends BackIterator<T> {

    map: HashMap<K, T>
    index := 0

    init: func ~withMap (=map) {}

    hasNext?: func -> Bool { index < map keys size }

    next: func -> T {
        key := map keys get(index)
        index += 1
        return map get(key)
    }

    hasPrev?: func -> Bool { index > 0 }

    prev: func -> T {
        index -= 1
        key := map keys get(index)
        return map get(key)
    }

    remove: func -> Bool {
        result := map remove(map keys get(index))
        if(index <= map keys size) index -= 1
        return result
    }

}

operator [] <K, V> (map: HashMap<K, V>, key: K) -> V {
    map get(key)
}

operator []= <K, V> (map: HashMap<K, V>, key: K, value: V) {
    map put(key, value)
}
