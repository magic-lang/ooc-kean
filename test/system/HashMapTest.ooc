/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

hashMapSum := 0
hashMapSumFunction: func (value: Int*) {
	hashMapSum += value@
}

HashTestClass: class {
	intVal: Int
	stringVal: String

	init: func ~default {
		this intVal = 0
		this stringVal = "Default"
	}
	init: func (=intVal, =stringVal)
}

HashMapTest: class extends Fixture {
	init: func {
		super("HashMap")
		this add("basic use (int, int)", func {
			hashmap := HashMap<Int, Int> new()
			for (i in 0 .. 100)
				hashmap put(i, 100 - i)

			for (i in 0 .. 100)
				expect(hashmap get(100 - i), is equal to(i))

			for (i in -100 .. 200)
				if (i >= 0 && i < 100)
					expect(hashmap contains(i), is true)
				else
					expect(hashmap contains(i), is false)

			expect(hashmap get(101, 999), is equal to(999))
			expect(hashmap remove(101, 999), is equal to(999))

			hashmap remove(10)
			expect(hashmap count, is equal to(99))
			hashmap put(10, 12345)
			expect(hashmap get(10), is equal to(12345))
			expect(hashmap count, is equal to(100))
			hashmap put(10, 54321)
			expect(hashmap get(10), is equal to(54321))
			expect(hashmap count, is equal to(100))

			hashmap clear()
			expect(hashmap count, is equal to(0))

			for (i in 1 .. 11)
				hashmap put(i, 10 - i)

			hashmap each(hashMapSumFunction)
			expect(hashMapSum, is equal to(45))

			hashmap free()
		})
		this add("basic use (char, String)", func {
			hashmap := HashMap<Char, String> new()
			hashmap put('a', "Apple") . put('b', "Banana") . put('c', "Car")
			hashmap put('d', "Door") . put('e', "Electricity") . put('f', "Fork")
			apple := hashmap get('a')
			expect(apple == "Apple", "1")
			fork := hashmap get('f')
			expect(fork == "Fork", "2")
			none := hashmap get('h', "nonexistant")
			expect(none == "nonexistant", "3")
			hashmap free()
		})
		this add("basic use (string, string)", func {
			hashmap := HashMap<String, String> new()
			hashmap put("best", "c++")
			hashmap put("ok", "c")
			hashmap put("sure", "java")
			expect(hashmap get("ok") == "c")
			expect(hashmap get("best") == "c++")
			hashmap put("best", "ooc")
			expect(hashmap get("best") == "ooc")
			expect(hashmap contains("best"), is true)
			expect(hashmap contains("better"), is false)
			hashmap free()
		})
		this add("basic use (text, text)", func {
			hashmap := HashMap<Text, Text> new()
			hashmap put(t"best", t"c++")
			hashmap put(t"ok", t"c")
			hashmap put(t"well", t"ooc")
			expect(hashmap get(t"well") == t"ooc")
			expect(hashmap get(t"ok") == t"c")
			expect(hashmap get(t"best") == t"c++")
			expect(hashmap get(t"nah", t"none") == t"none")
			expect(hashmap contains(t"best"), is true)
			expect(hashmap contains(t"better"), is false)
			hashmap free()
		})
		this add("basic use (string, class)", func {
			hashmap := HashMap<String, HashTestClass> new()
			first := HashTestClass new(1, "String")
			hashmap put("HashTestClassValue", first)
			defaultClass := HashTestClass new()
			hashmap put("first", first)
			hashmap put("default", defaultClass)

			_first := hashmap get("first")
			_default := hashmap get("default")
			_null := hashmap get("other")

			expect(_first, is notNull)
			expect(_default, is notNull)
			expect(_null, is Null)

			expect(_first stringVal == "String")
			expect(_default stringVal == "Default")
			expect(_first intVal, is equal to(1))
			expect(_default intVal, is equal to(0))

			hashmap remove("first")
			_notFirst := hashmap get("first")
			expect(_notFirst, is Null)
			_notFirst = hashmap get("first", defaultClass)
			expect(_notFirst, is notNull)
			expect(_notFirst stringVal == "Default")

			(hashmap, first, defaultClass) free()
		})
		this add("basic use (string, VectorList<String>)", func {
			hashmap := HashMap<String, VectorList<String>> new()
			vectorList := VectorList<String> new()
			vectorList add("one")
			vectorList add("two")
			vectorList add("three")
			hashmap put("VectorList", vectorList)
			list := hashmap get("VectorList")
			expect(list count, is equal to(3))
			expect(list[0] == "one")
			other := hashmap get("Uhoh")
			expect(other, is Null)
			replaceList := VectorList<String> new() . add("four") . add("five")
			old := hashmap put("VectorList", replaceList)
			expect(old, is notNull)
			list = hashmap get("VectorList")
			expect(list count, is equal to(2))
			(hashmap, vectorList, replaceList) free()
		})
		this add("resize", func {
			hashmap := HashMap<Int, Int> new(10)
			for (i in 0 .. 1000)
				hashmap put(i, 1000 - i)

			for (i in 0 .. 1000)
				expect(hashmap get(1000 - i), is equal to(i))
			for (i in -100 .. 2000)
				expect(hashmap contains(i) == i in(0 .. 1000))

			hashmap resize(100)

			for (i in 0 .. 1000)
				expect(hashmap get(1000 - i), is equal to(i))
			for (i in -100 .. 2000)
				expect(hashmap contains(i) == i in(0 .. 1000))

			hashmap resize(2)

			for (i in 0 .. 1000)
				expect(hashmap get(1000 - i), is equal to(i))
			for (i in -100 .. 2000)
				expect(hashmap contains(i) == i in(0 .. 1000))

			hashmap free()
		})
	}
}

HashMapTest new() run() . free()
