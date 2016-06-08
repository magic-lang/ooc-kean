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
			(list, sorted) free()
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
			(list, copy) free()
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
			list add(1) . add(2) . add(1) . add(5) . add(2)
			list add(7) . add(6) . add(7) . add(7)
			compressed := list compress()
			expect(compressed[0], is equal to(1))
			expect(compressed[1], is equal to(2))
			expect(compressed[2], is equal to(5))
			expect(compressed[3], is equal to(6))
			expect(compressed[4], is equal to(7))
			(list, compressed) free()
		})
		this add("toString", func {
			list := IntVectorList new()
			list add(1) . add(2) . add(3)
			text := list toString()
			expect(text, is equal to("1\n2\n3"))
			text free()
			text = list toString(", ")
			expect(text, is equal to("1, 2, 3"))
			(text, list) free()
		})
		this add("parse", func {
			list := IntVectorList parse("1,2,3,4,5", ",")
			expect(list count, is equal to(5))
			for (i in 0 .. 5)
				expect(list[i], is equal to(i + 1))
			list free()
		})
	}
}

IntVectorListTest new() run() . free()
