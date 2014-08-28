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
DictionaryTest: class extends Fixture {
  init: func {
    super("Dictionary")
    this add("Int", func {
      dictionary := Dictionary new()
      dictionary add("IntegerValue", 1)
      expect(dictionary get("IntegerValue", 0) == 1, is true)
      expect(dictionary get("Nonexistent", 0) == 0, is true)
    })
    this add("String", func {
      dictionary := Dictionary new()
      dictionary add("StringValue", "String")
      dictionary add("IntegerValue", 1)
      expect(dictionary get("StringValue", "Default") == "String", is true)
      expect(dictionary get("IntegerValue", "Default") == "Default", is true)
      expect(dictionary get("Nonexistent", "Default") == "Default", is true)
    })
    this add("Class", func {
      dictionary := Dictionary new()
      defaultClass := TestClass new()
      testclass := TestClass new(1, "String")
      dictionary add("TestClassValue", testclass)
      expect(dictionary get("TestClassValue", defaultClass) stringVal == "String", is true)
      expect(dictionary get("Nonexistent", defaultClass) stringVal == "Default", is true)
      expect(dictionary get("TestClassValue", defaultClass) intVal == 1, is true)
      expect(dictionary get("Nonexistent", defaultClass) intVal == 0, is true)
    })
    this add("ArrayList", func {
      dictionary := Dictionary new()
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
      dictionary := Dictionary new()
      dictionary add("First", "First")
      dictionary2 := Dictionary new(dictionary)
      dictionary2 add ("Second", "Second")
      expect(dictionary get("Second", "Default") == "Default", is true)
      expect(dictionary get("First", "Default") == "First", is true)
      expect(dictionary2 get("Second", "Default") == "Second", is true)
      expect(dictionary2 get("First", "Default") == "First", is true)
    })
  }
}
DictionaryTest new() run()
