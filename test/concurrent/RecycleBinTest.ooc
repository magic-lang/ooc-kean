/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base
use concurrent

MyClass: class {
	content: Int
	bin: static RecycleBin<This>
	allocated: static Int = 0
	freed: static Int = 0
	init: func (=content) { This allocated += 1 }
	free: override func {
		// < 0 means force free
		if (this content < 0) {
			This freed += 1
			super()
		}
		else
			this bin add(this)
	}
	create: static func (content: Int) -> This {
		This bin search(|instance| content == instance content) ?? This new(content)
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

			for (i in 0 .. allocationCount)
				MyClass create(i) free()
			expect(bin isFull)
			expect(MyClass freed, is equal to(binSize))

			for (i in 0 .. bin _list count)
				expect(bin _list[i] content, is greaterOrEqual than(0))

			bin free()
			expect(MyClass freed, is equal to(MyClass allocated))
		})
	}
}

RecycleBinTest new() run() . free()
