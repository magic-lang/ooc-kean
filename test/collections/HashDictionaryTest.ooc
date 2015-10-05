use ooc-base
use ooc-collections
use ooc-unit

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
			expect(dictionary get("IntegerValue", 0) == 1, is true)
			expect(dictionary get("Nonexistent", 0) == 0, is true)
		})
		this add("String", func {
			dictionary := HashDictionary new()
			dictionary add("StringValue", "String")
			dictionary add("IntegerValue", 1)
			expect(dictionary get("StringValue", "Default") == "String", is true)
			expect(dictionary get("IntegerValue", "Default") == "Default", is true)
			expect(dictionary get("Nonexistent", "Default") == "Default", is true)
		})
		this add("Cover", func {
			dictionary := HashDictionary new()
			testCover := TestCover new(1, "String")
			dictionary add("TestClassValue", testCover)
			expect(dictionary get("TestClassValue", this defaultCover) stringVal == "String", is true)
			expect(dictionary get("Nonexistent", this defaultCover) stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", this defaultCover) intVal == 1, is true)
			expect(dictionary get("Nonexistent", this defaultCover) intVal == 0, is true)
		})
		this add("Class", func {
			dictionary := HashDictionary new()
			testClass := TestClass new(1, "String")
			dictionary add("TestClassValue", testClass)
			expect(dictionary get("TestClassValue", this defaultClass) stringVal == "String", is true)
			expect(dictionary get("Nonexistent", this defaultClass) stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", this defaultClass) intVal == 1, is true)
			expect(dictionary get("Nonexistent", this defaultClass) intVal == 0, is true)
		})
		this add("ArrayList", func {
			dictionary := HashDictionary new()
			VectorListDefault := VectorList<String> new()
			VectorListDefault add("zero")
			vectorList := VectorList<String> new()
			vectorList add("one")
			vectorList add("two")
			vectorList add("three")
			dictionary add("VectorList", vectorList)
			expect(dictionary get("VectorList", VectorListDefault)[0] == "one", is true)
			expect(dictionary get("VectorList", VectorListDefault)[1] == "two", is true)
			expect(dictionary get("VectorList", VectorListDefault)[2] == "three", is true)
			expect(dictionary get("Nonexistent", VectorListDefault)[0] == "zero", is true)
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
		})
		this add("Clone", func {
			dictionary := HashDictionary new()
			dictionary add("First", "First")
			dictionary add("Int", 1)
			dictionary2 := dictionary clone()
			dictionary2 add ("Second", "Second")
			expect(dictionary get("Second", "Default") == "Default", is true)
			expect(dictionary get("First", "Default") == "First", is true)
			expect(dictionary2 get("Second", "Default") == "Second", is true)
			expect(dictionary2 get("First", "Default") == "First", is true)
			expect(dictionary2 get("Int", 0) == 1, is true)
		})
		this add("Get from primitive", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1337)
			dictionary add("First2", TestClass new(1337, "String"))
			expect(dictionary getAsType("First", Int, 0), is equal to(1337))
			expect(dictionary getAsType("First", Text, t"null") == t"null")
			expect(dictionary getAsType("Second", Int, 0) == 0)
			expect(dictionary getAsType("First", TestCover, defaultCover) intVal == 0)
			expect(dictionary getAsType("First", TestClass, null) == null)
			expect(dictionary getAsType("First2", TestClass, null) intVal == 1337)
		})
		this add("Get from cover", func {
			dictionary := HashDictionary new()
			testCover := TestCover new(1337, "String")
			dictionary add("First", testCover)
			expect(dictionary getAsType("First", TestCover, defaultCover) intVal == 1337)
			expect(dictionary getAsType("First", TestCover, defaultCover) stringVal == "String")
			expect(dictionary getAsType("Second", TestCover, defaultCover) intVal == 0)
			expect(dictionary getAsType("First", Int, 0) == 0)
			expect(dictionary getAsType("First", TestClass, null) == null)
		})
		this add("Get from class", func {
			dictionary := HashDictionary new()
			dictionary add("First", TestClass new(1337, "String"))
			expect(dictionary getAsType("First", TestClass, null) intVal == 1337)
			expect(dictionary getAsType("First", TestClass, null) stringVal == "String")
			expect(dictionary getAsType("Second", TestClass, null) == null)
			expect(dictionary getAsType("First", Int, 0) == 0)
			expect(dictionary getAsType("First", TestCover, defaultCover) intVal == 0)
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
			expect(dictionary3 getAsType("First", Int, 0) == 1338)
			expect(dictionary3 getAsType("Second", String, "null") == "Bar")
			expect(dictionary3 getAsType("Third", TestCover, defaultCover) intVal == 43)
			expect(dictionary3 getAsType("Third", TestCover, defaultCover) stringVal == "World")
			expect(dictionary3 getAsType("Fourth", TestClass, null) intVal == 102)
			expect(dictionary3 getAsType("Fourth", TestClass, null) stringVal == "Vader")
			expect(dictionary3 getAsType("Fifth", String, "null") == "Almost")
			expect(dictionary3 getAsType("Sixth", Int, 0) == 1002)
			expect(dictionary3 getAsType("Sixth", String, "null") == "null")
		})
		this add("Sizes", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1)
			dictionary add("Second", 2)
			dictionary add("Third", 3)
			expect(dictionary count == 3)
			expect(dictionary empty == false)
			expect(dictionary contains("Second") == true)
			dictionary remove("Second")
			expect(dictionary count == 2)
			expect(dictionary empty == false)
			expect(dictionary contains("Second") == false)
			dictionary remove("Third")
			dictionary remove("First")
			expect(dictionary count == 0)
			expect(dictionary empty == true)
		})
	}
}

HashDictionaryTest new() run()
