use ooc-base
use ooc-unit
import structs/ArrayList

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
			defaultCover := TestCover new()
			testCover := TestCover new(1, "String")
			dictionary add("TestClassValue", Cell new(testCover))
			expect(dictionary get("TestClassValue", Cell new(defaultCover)) get() stringVal == "String", is true)
			expect(dictionary get("Nonexistent", Cell new(defaultCover)) get() stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", Cell new(defaultCover)) get() intVal == 1, is true)
			expect(dictionary get("Nonexistent", Cell new(defaultCover)) get() intVal == 0, is true)
		})

		this add("Class", func {
			dictionary := HashDictionary new()
			defaultClass := TestClass new()
			testClass := TestClass new(1, "String")
			dictionary add("TestClassValue", testClass)
			expect(dictionary get("TestClassValue", defaultClass) stringVal == "String", is true)
			expect(dictionary get("Nonexistent", defaultClass) stringVal == "Default", is true)
			expect(dictionary get("TestClassValue", defaultClass) intVal == 1, is true)
			expect(dictionary get("Nonexistent", defaultClass) intVal == 0, is true)
		})
		this add("ArrayList", func {
			dictionary := HashDictionary new()
			arrayListDefault := ArrayList<String> new()
			arrayListDefault add("zero")
			arrayList := ArrayList<String> new()
			arrayList add("one")
			arrayList add("two")
			arrayList add("three")
			dictionary add("ArrayList", arrayList)
			expect(dictionary get("ArrayList", arrayListDefault)[0] == "one", is true)
			expect(dictionary get("ArrayList", arrayListDefault)[1] == "two", is true)
			expect(dictionary get("ArrayList", arrayListDefault)[2] == "three", is true)
			expect(dictionary get("Nonexistent", arrayListDefault)[0] == "zero", is true)
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
			expect(dictionary getAsType("First", Int) == 1337)
			expect(dictionary getAsType("First", String) == null)
			expect(dictionary getAsType("Second", Int) == null)
			expect(dictionary getAsType("First", Cell<TestCover>) == null)
			expect(dictionary getAsType("First", TestClass) == null)
		})

		this add("Get from cover", func {
			dictionary := HashDictionary new()
			testCover := TestCover new(1337, "String")
			dictionary add("First", Cell new(testCover))
			expect(dictionary getAsType("First", Cell<TestCover>) get() intVal == 1337)
			expect(dictionary getAsType("First", Cell<TestCover>) get() stringVal == "String")
			expect(dictionary getAsType("Second", Cell<TestCover>) == null)
			expect(dictionary getAsType("First", Int) == null)
			expect(dictionary getAsType("First", TestClass) == null)
		})

		this add("Get from class", func {
			dictionary := HashDictionary new()
			dictionary add("First", TestClass new(1337, "String"))

			expect(dictionary getAsType("First", TestClass) intVal == 1337)
			expect(dictionary getAsType("First", TestClass) stringVal == "String")
			expect(dictionary getAsType("Second", TestClass) == null)
			expect(dictionary getAsType("First", Int) == null)
			expect(dictionary getAsType("First", Cell<TestCover>) == null)
		})
		this add("Merge", func {
			dictionary := HashDictionary new()
			dictionary add("First", 1337)
			dictionary add("Second", "Foo")
			dictionary add("Third", Cell new(TestCover new(42, "Hello")))
			dictionary add("Fourth", TestClass new(101, "Darth"))
			dictionary add("Fifth", "Almost")
			dictionary add("Sixth", "Done")

			dictionary2 := HashDictionary new()
			dictionary2 add("First", 1338)
			dictionary2 add("Second", "Bar")
			dictionary2 add("Third", Cell new(TestCover new(43, "World")))
			dictionary2 add("Fourth", TestClass new(102, "Vader"))
			dictionary2 add("Sixth", 1002)

			dictionary3 := dictionary merge(dictionary2)
			expect(dictionary3 getAsType("First", Int) == 1338)
			expect(dictionary3 getAsType("Second", String) == "Bar")
			expect(dictionary3 getAsType("Third", Cell<TestCover>) get() intVal == 43)
			expect(dictionary3 getAsType("Third", Cell<TestCover>) get() stringVal == "World")
			expect(dictionary3 getAsType("Fourth", TestClass) intVal == 102)
			expect(dictionary3 getAsType("Fourth", TestClass) stringVal == "Vader")
			expect(dictionary3 getAsType("Fifth", String) == "Almost")
			expect(dictionary3 getAsType("Sixth", Int) == 1002)
			expect(dictionary3 getAsType("Sixth", String) == null)
		})
	}
}
HashDictionaryTest new() run()
