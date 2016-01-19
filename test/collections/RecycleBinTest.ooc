use unit
use base
use collections

MyClass: class {
	content: Int
	bin: static RecycleBin<This>
	freed: static VectorList<This>
	allocated: static Int = 0
	init: func (=content) { This allocated += 1 }
	free: override func {
		// < 0 means force free
		if (this content < 0)
			freed add(this)
		else
			this bin add(this)
	}
	create: static func (content: Int) -> This {
		matches := func (instance: This) -> Bool { content == instance content }
		This bin search(matches) ?? This new(content)
	}
}

RecycleBinTest: class extends Fixture {
	init: func {
		super("RecycleBin")
		this add("Recycle", func {
			binSize := 10
			allocationCount := 2 * binSize
			bin := RecycleBin<MyClass> new(binSize, func (instance: MyClass) { instance content = -1; instance free() })
			MyClass bin = bin
			freed := VectorList<MyClass> new()
			MyClass freed = freed

			for (i in 0 .. allocationCount)
				MyClass create(i) free()
			expect(bin isFull)
			expect(freed count, is equal to(allocationCount - binSize))
			for (i in 0 .. freed count)
				expect(freed[i] content == -1)

			for (i in 0 .. bin _list count)
				expect(bin _list[i] content >= 0)

			bin free()
			expect(freed count, is equal to(MyClass allocated))
			freed free()
		})
	}
}

RecycleBinTest new() run() . free()
