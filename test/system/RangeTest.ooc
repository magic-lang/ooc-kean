/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use math

RangeTest: class extends Fixture {
	init: func {
		super("Range")
		this add("properties", func {
			range := 0 .. 10
			expect(range min, is equal to(0))
			expect(range max, is equal to(10))
			expect(range count, is equal to(11))
		})
		this add("equals", func {
			range := 0 .. 10
			range2 := 0 .. 10
			range3 := 1 .. 10
			expect(range == range)
			expect(range == range2)
			expect(range != range3)
		})
		this add("shift", func {
			range := 1 .. 10
			range2 := 0 .. 9
			range3 := 2 .. 11
			expect(range - 1 == range2)
			expect(range + 1 == range3)
		})
		this add("clamp", func {
			range := 2 .. 8
			smallRange := 4 .. 6
			lowRange := 0 .. 5
			highRange := 6 .. 10
			lowerRange := 0 .. 1
			higherRange := 20 .. 21
			expect(range clamp(range) min, is equal to(range min))
			expect(range clamp(range) max, is equal to(range max))
			expect(range clamp(smallRange) min, is equal to(smallRange min))
			expect(range clamp(smallRange) max, is equal to(smallRange max))
			expect(range clamp(lowRange) min, is equal to(range min))
			expect(range clamp(lowRange) max, is equal to(lowRange max))
			expect(range clamp(highRange) min, is equal to(highRange min))
			expect(range clamp(highRange) max, is equal to(range max))
			expect(range clamp(lowerRange) min, is equal to(lowerRange max))
			expect(range clamp(lowerRange) max, is equal to(lowerRange max))
			expect(range clamp(higherRange) min, is equal to(higherRange min))
			expect(range clamp(higherRange) max, is equal to(higherRange min))
		})
	}
}

RangeTest new() run() . free()
