use ooc-base
use ooc-collections
use ooc-unit

LinkedListTest: class extends Fixture {
	init: func {
		super("LinkedList")
		this add("Basic use", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			first := linkedlist first()
			last := linkedlist last()
			expect(first, is equal to(2))
			expect(last, is equal to(7))
		})
		this add("Size and clear", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			expect(linkedlist size, is equal to(3))
			linkedlist removeAt(1)
			expect(linkedlist size, is equal to(2))
			linkedlist clear()
			expect(linkedlist size, is equal to(0))
		})
		this add("Last", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			last := linkedlist last()
			expect(last, is equal to(7))
		})
		this add("set and get", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			linkedlist set(0, 42)
			item := linkedlist get(0)
			expect(item, is equal to(42))
		})
		this add("operators", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			linkedlist[0] = 42
			item := linkedlist[0]
			expect(item, is equal to(42))
		})
	}
}

LinkedListTest new() run()
