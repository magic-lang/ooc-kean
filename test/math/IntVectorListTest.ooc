/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use math
use collections

IntVectorListTest: class extends Fixture {
	init: func {
		super("IntVectorList")
		this add("sort", func {
			list := IntVectorList new()
			list add(-1)
			list add(2)
			list add(-3)
			list add(4)
			sorted := list sort()
			expect(sorted[0], is equal to(-3))
			expect(sorted[1], is equal to(-1))
			expect(sorted[2], is equal to(2))
			expect(sorted[3], is equal to(4))
			list free()
			sorted free()
		})
		this add("copy", func {
			list := IntVectorList new()
			list add(-1)
			list add(2)
			list add(-3)
			list add(4)
			copy := list copy()
			expect(list count == copy count)
			for (i in 0 .. list count)
				expect(copy[i], is equal to(list[i]))
			list free()
			copy free()
		})
		this add("contains", func {
			list := IntVectorList new()
			list add(-1)
			list add(2)
			list add(-3)
			list add(4)
			expect(list contains(2), is true)
			expect(list contains(-2), is false)
			list free()
		})
		this add("compress", func {
			list := IntVectorList new()
			list add(1)
			list add(2)
			list add(1)
			list add(5)
			list add(2)
			list add(7)
			list add(6)
			list add(7)
			list add(7)
			compressed := list compress()
			expect(compressed[0], is equal to(1))
			expect(compressed[1], is equal to(2))
			expect(compressed[2], is equal to(5))
			expect(compressed[3], is equal to(6))
			expect(compressed[4], is equal to(7))
			list free()
			compressed free()
		})
		this add("toText", func {
			list := IntVectorList new()
			list add(1) . add(2) . add(3)
			text := list toText() take()
			expect(text, is equal to(t"1\n2\n3"))
			text free()
			list free()
		})
	}
}

IntVectorListTest new() run() . free()
