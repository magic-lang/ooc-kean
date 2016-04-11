/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

HashEntry: cover {
	key: Pointer
	value: Pointer
	next: This* = null
	init: func@ { this init(null, null) }
	init: func@ ~keyVal (=key, =value)
	free: func {
		if (this key != null)
			memfree(this key)
		if (this value != null)
			memfree(this value)
		if (this next != null) {
			temp := this next@
			temp free()
			memfree(this next)
		}
	}
}

intHash: func <K> (key: K) -> SizeT { (key as Int) as SizeT }
pointerHash: func <K> (key: K) -> SizeT { (key as Pointer) as SizeT }

/**
	Port of Austin Appleby's Murmur Hash implementation
	http://code.google.com/p/smhasher/
*/
murmurHash: func <K> (keyTagazok: K) -> SizeT {
	seed: SizeT = 1

	len := K size
	m = 0x5bd1e995: SizeT
	r = 24: SSizeT
	l := len

	h : SizeT = seed ^ len
	data := (keyTagazok&) as Byte*

	while (true) {
		k := (data as SizeT*)@

		k *= m
		k ^= k >> r
		k *= m

		h *= m
		h ^= k

		data += 4
		if (len < 4) break
		len -= 4
	}

	t := 0

	if (len == 3) h ^= data[2] << 16
	if (len == 2) h ^= data[1] << 8
	if (len == 1) h ^= data[0]

	t *= m; t ^= t >> r; t *= m; h *= m; h ^= t
	l *= m; l ^= l >> r; l *= m; h *= m; h ^= l

	h ^= h >> 13
	h *= m
	h ^= h >> 15

	h
}

/**
 * khash's ac_X31_hash_string
 * http://attractivechaos.awardspace.com/khash.h.html
 * @access private
 * @param s The string to hash
 * @return UInt
 */
acX31Hash: func <K> (key: K) -> SizeT {
	raise(key == null, "key in acX31Hash must be non-null!")
	s : Char* = (K == String) ? (key as String) toCString() as Char* : key as Char*
	h = s@ : SizeT
	if (h) {
		s += 1
		while (s@) {
			h = (h << 5) - h + s@
			s += 1
		}
	}
	h
}

getStandardHashFunc: func <T> (T: Class) -> Func <T> (T) -> SizeT {
	if (T == String)
		acX31Hash
	else if (T size == Pointer size)
		pointerHash
	else if (T size == UInt size)
		intHash
	else
		murmurHash
}

HashMap: class <K, V> {
	_count: SizeT
	capacity: SizeT
	hashKey: Func <K> (K) -> SizeT
	buckets: HashEntry[]
	keys: VectorList<K>
	count ::= this _count
	isEmpty ::= this keys empty

	init: func { init(3) }
	init: func ~withCapacity (=capacity) {
		this _count = 0
		this buckets = HashEntry[capacity] new()
		this keys = VectorList<K> new(32, false)
		this hashKey = getStandardHashFunc(K)
	}
	free: override func {
		for (i in 0 .. this buckets length)
			this buckets[i] free()
		(this buckets, this keys) free()
		super()
	}
	getEntry: func (key: K, result: HashEntry*) -> Bool {
		hash: SizeT = this hashKey(key) % this capacity
		entry := this buckets[hash]
		success := false
		if (entry key != null)
			while (true) {
				if (This _keyEquals(entry key as K, key)) {
					if (result)
						result@ = entry
					success = true
					break
				}
				if (entry next)
					entry = entry next@
				else
					break
			}
		success
	}
	getEntryForHash: func (key: K, hash: SizeT, result: HashEntry*) -> Bool {
		entry := this buckets[hash]
		success := false
		if (entry key != null)
			while (true) {
				if (This _keyEquals(entry key as K, key)) {
					if (result)
						result@ = entry
					success = true
					break
				}
				if (entry next)
					entry = entry next@
				else
					break
			}
		success
	}
	copy: func -> This<K, V> {
		copy := This<K, V> new()
		f := func (k: K, v: V) { copy put(k, v) }
		this each(f)
		(f as Closure) free()
		copy
	}
	merge: func (other: This<K, V>) -> This<K, V> {
		c := this copy()
		c merge~inplace(other)
		c
	}
	merge: func ~inplace (other: This<K, V>) -> This<K, V> {
		f := func (k: K, v: V) { this put(k, v) }
		other each(f)
		(f as Closure) free()
		this
	}
	put: func (key: K, value: V) {
		hash: SizeT = this hashKey(key) % this capacity
		entry: HashEntry

		if (this getEntryForHash(key, hash, entry&))
			memcpy(entry value, value, V size)
		else {
			this keys add(key)
			current := this buckets[hash]
			if (current key != null) {
				currentPointer := (this buckets data as HashEntry*)[hash]&

				while (currentPointer@ next)
					currentPointer = currentPointer@ next

				newEntry := calloc(1, HashEntry size) as HashEntry*

				newEntry@ key = calloc(1, K size)
				memcpy(newEntry@ key, key, K size)

				newEntry@ value = calloc(1, V size)
				memcpy(newEntry@ value, value, V size)

				currentPointer@ next = newEntry
			} else {
				entry key = calloc(1, K size)
				memcpy(entry key, key, K size)

				entry value = calloc(1, V size)
				memcpy(entry value, value, V size)

				entry next = null

				this buckets[hash] = entry
			}
			this _count += 1
			if ((this _count as Float / this capacity as Float) > 0.75)
				this resize(this _count * (this _count > 50000 ? 2 : 4))
		}
	}
	get: func (key: K) -> V {
		entry: HashEntry
		result: V = null
		if (this getEntry(key, entry&))
			result = entry value as V
		result
	}
	contains: func (key: K) -> Bool {
		this getEntry(key, null)
	}
	remove: func (key: K) -> Bool {
		hash : SizeT = this hashKey(key) % this capacity
		prev: HashEntry* = null
		entry: HashEntry* = (this buckets data as HashEntry*)[hash]&

		result := false
		if (entry@ key != null) {
			while (true) {
				if (This _keyEquals(entry@ key as K, key)) {
					memfree(entry@ key)
					memfree(entry@ value)

					if (prev)
						prev@ next = entry@ next
					else if (entry@ next)
						this buckets[hash] = entry@ next@
					else
						this buckets[hash] = HashEntry new()

					for (i in 0 .. this keys count) {
						cKey := this keys[i]
						if (This _keyEquals(key, cKey)) {
							this keys removeAt(i)
							break
						}
					}
					this _count -= 1
					result = true
					break
				}
				if (entry@ next) {
					prev = entry
					entry = entry@ next
				} else
					break
			}
		}
		result
	}
	resize: func (_capacity: SizeT) {
		oldCapacity := this capacity
		oldBuckets := this buckets
		oldKeys := this keys copy()
		this keys clear()
		this _count = 0
		this capacity = _capacity
		this buckets = HashEntry[this capacity] new()
		for (i in 0 .. oldCapacity) {
			entry := oldBuckets[i]
			if (entry key != null) {
				this put(entry key as K, entry value as V)
				old := entry
				while (entry next) {
					entry = entry next@
					this put(entry key as K, entry value as V)
				}
				old free()
			}
		}
		oldBuckets free()
		this keys free()
		this keys = oldKeys
	}
	iterator: func -> BackIterator<V> {
		HashMapValueIterator<K, V> new(this)
	}
	backIterator: func -> BackIterator<V> {
		iter := HashMapValueIterator<K, V> new(this)
		iter index = this keys count
		iter
	}
	clear: func {
		this _count = 0
		for (i in 0 .. this capacity)
			this buckets[i] = HashEntry new()
		this keys clear()
	}
	each: func ~withKeys (f: Func (K, V)) {
		for (i in 0 .. this keys count) {
			key := this keys[i]
			f(key, this get(key))
		}
	}
	each: func (f: Func (V)) {
		for (i in 0 .. this keys count)
			f(this get(this keys[i]))
	}
	_keyEquals: static func <T> (first, second: T) -> Bool {
		match (T) {
			case String => first as String equals(second as String)
			case Pointer => first as Pointer == second as Pointer
			case Int => first as Int == second as Int
			case => memcmp(first, second, T size) == 0
		}
	}
}

HashMapValueIterator: class <K, T> extends BackIterator<T> {
	map: HashMap<K, T>
	index := 0
	init: func ~withMap (=map)
	hasNext: override func -> Bool { this index < this map keys count }
	hasPrevious: override func -> Bool { this index > 0 }
	next: override func -> T {
		key := this map keys[this index]
		this index += 1
		this map get(key)
	}
	prev: override func -> T {
		this index -= 1
		key := this map keys[this index]
		this map get(key)
	}
	remove: override func -> Bool {
		result := this map remove(this map keys[this index])
		if (this index <= this map keys count)
			this index -= 1
		result
	}
}

operator [] <K, V> (map: HashMap<K, V>, key: K) -> V { map get(key) }
operator []= <K, V> (map: HashMap<K, V>, key: K, value: V) { map put(key, value) }
