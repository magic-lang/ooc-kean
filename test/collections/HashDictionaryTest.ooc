/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use unit

TestClass: class {
	intVal: Int
	stringVal: String

	init: func ~default {
		this intVal = 0
		this stringVal = "Default"
	}
	init: func (=intVal, =stringVal)
}
TestCover: cover {
	intVal: Int
	stringVal: String

	init: func@ ~default {
		this intVal = 0
		this stringVal = "Default"
	}
	init: func@ (=intVal, =stringVal)
}

HashDictionaryTest: class extends Fixture {
	defaultCover := TestCover new()
	defaultClass := TestClass new()

	init: func {
		super("HashDictionary")
		this add("Int", func {
			dictionary := HashDictionary new()
			dictionary add("IntegerValue", 1)
			expect(dictionary get("IntegerValue", 0), is equal to(1))
			expect(dictionary get("Nonexistent", 0), is equal to(0))
			dictionary free()
		})
		this add("String", func {
			dictionary := HashDictionary new()
			dictionary add("StringValue", "String")
			dictionary add("IntegerValue", 1)
			expect(dictionary get("StringValue", "Default") == "String", is true)
			expect(dictionary get("IntegerValue", "Default") == "Default", is true)
			expect(dictionary get("Nonexistent", "Default") == "Default", is true)
			dictionary free()
		})
		this add("Cover", func {
			dictionary := HashDictionary new()
			testCover := TestCover new(1, "String")
			dictionary add("TestClassValue", testCover)
			expect(dictionary get("TestClassValue", this defaultCover) stringVal == "String", is true)
			expect(dictionary get("Nonexistent", this defaultCover) stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", this defaultCover) intVal, is equal to(1))
			expect(dictionary get("Nonexistent", this defaultCover) intVal, is equal to(0))
			dictionary free()
		})
		this add("Class", func {
			dictionary := HashDictionary new()
			testClass := TestClass new(1, "String")
			dictionary add("TestClassValue", testClass)
			expect(dictionary get("TestClassValue", this defaultClass) stringVal == "String", is true)
			expect(dictionary get("Nonexistent", this defaultClass) stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", this defaultClass) intVal, is equal to(1))
			expect(dictionary get("Nonexistent", this defaultClass) intVal, is equal to(0))
			testClass free()
			dictionary free()
		})
		this add("VectorList", func {
			dictionary := HashDictionary new()
			vectorListDefault := VectorList<String> new()
			vectorListDefault add("zero")
			vectorList := VectorList<String> new()
			vectorList add("one")
			vectorList add("two")
			vectorList add("three")
			dictionary add("VectorList", vectorList)
			expect(dictionary get("VectorList", vectorListDefault)[0] == "one", is true)
			expect(dictionary get("VectorList", vectorListDefault)[1] == "two", is true)
			expect(dictionary get("VectorList", vectorListDefault)[2] == "three", is true)
			expect(dictionary get("Nonexistent", vectorListDefault)[0] == "zero", is true)
			dictionary free()
			vectorListDefault free()
		})
		this add("Copy constructor", func {
			dictionary := HashDictionary new()
			dictionary add("First", "First")
			dictionary2 := HashDictionary new(dictionary)
			dictionary2 add ("Second", "Second")
			expect(dictionary get("Second", "Default") == "Default", is true)
			expect(dictionary get("First", "Default") == "First", is true)
			expect(dictionary2 get("Second", "Default") == "Second", is true)
			expect(dictionary2 get("First", "Default") == "First", is true)
			dictionary free()
			dictionary2 free()
		})
		this add("Copy", func {
			dictionary := HashDictionary new()
			dictionary add("First", "First")
			dictionary add("Int", 1)
			dictionary2 := dictionary copy()
			dictionary2 add ("Second", "Second")
			expect(dictionary get("Second", "Default") == "Default", is true)
			expect(dictionary get("First", "Default") == "First", is true)
			expect(dictionary2 get("Second", "Default") == "Second", is true)
			expect(dictionary2 get("First", "Default") == "First", is true)
			expect(dictionary2 get("Int", 0) == 1, is true)
			dictionary free()
			dictionary2 free()
		})
		this add("Get from primitive", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1337)
			dictionary add("Second", TestClass new(1337, "String"))
			expect(dictionary get("First", 0), is equal to(1337))
			expect(dictionary get("First", t"null") == t"null")
			expect(dictionary get("Second", 0), is equal to(0))
			expect(dictionary get("First", this defaultCover) intVal, is equal to(0))
			expect(dictionary get("First", null), is Null)
			expect(dictionary get("Second", this defaultClass) intVal, is equal to(1337))
			dictionary free()
		})
		this add("Get from cover", func {
			dictionary := HashDictionary new()
			testCover := TestCover new(1337, "String")
			dictionary add("First", testCover)
			expect(dictionary get("First", this defaultCover) intVal, is equal to(1337))
			expect(dictionary get("First", this defaultCover) stringVal == "String")
			expect(dictionary get("Second", this defaultCover) intVal, is equal to(0))
			expect(dictionary get("First", 0), is equal to(0))
			expect(dictionary get("First", null), is Null)
			dictionary free()
		})
		this add("Get from class", func {
			dictionary := HashDictionary new()
			dictionary add("First", TestClass new(1337, "String"))
			expect(dictionary get("First", this defaultClass) intVal, is equal to(1337))
			expect(dictionary get("First", this defaultClass) stringVal == "String")
			expect(dictionary get("Second", null), is Null)
			expect(dictionary get("First", 0), is equal to(0))
			expect(dictionary get("First", this defaultCover) intVal, is equal to(0))
			dictionary free()
		})
		this add("Merge", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1337)
			dictionary add("Second", "Foo")
			dictionary add("Third", TestCover new(42, "Hello"))
			dictionary add("Fourth", TestClass new(101, "Darth"))
			dictionary add("Fifth", "Almost")
			dictionary add("Sixth", "Done")

			dictionary2 := HashDictionary new()
			dictionary2 add("First", 1338)
			dictionary2 add("Second", "Bar")
			dictionary2 add("Third", TestCover new(43, "World"))
			dictionary2 add("Fourth", TestClass new(102, "Vader"))
			dictionary2 add("Sixth", 1002)

			dictionary3 := dictionary merge(dictionary2)
			expect(dictionary3 get("First", 0), is equal to(1338))
			expect(dictionary3 get("Second", "null") == "Bar")
			expect(dictionary3 get("Third", this defaultCover) intVal, is equal to(43))
			expect(dictionary3 get("Third", this defaultCover) stringVal == "World")
			expect(dictionary3 get("Fourth", this defaultClass) intVal, is equal to(102))
			expect(dictionary3 get("Fourth", this defaultClass) stringVal == "Vader")
			expect(dictionary3 get("Fifth", "null") == "Almost")
			expect(dictionary3 get("Sixth", 0), is equal to(1002))
			expect(dictionary3 get("Sixth", "null") == "null")

			(dictionary, dictionary2, dictionary3) free()
		})
		this add("Sizes", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1)
			dictionary add("Second", 2)
			dictionary add("Third", 3)
			expect(dictionary count as Int, is equal to(3))
			expect(dictionary isEmpty, is false)
			expect(dictionary contains("Second"), is true)
			dictionary remove("Second")
			expect(dictionary count as Int, is equal to(2))
			expect(dictionary isEmpty, is false)
			expect(dictionary contains("Second"), is false)
			dictionary remove("Third")
			dictionary remove("First")
			expect(dictionary count as Int, is equal to(0))
			expect(dictionary isEmpty, is true)
			dictionary free()
		})
	}
	free: override func {
		this defaultClass free()
		super()
	}
}

HashDictionaryTest new() run() . free()
