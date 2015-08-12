use ooc-unit
use ooc-math
import math
import lang/IO

RangeTest: class extends Fixture {
	init: func {
		super("Range")
		this add("properties", func {
			range := 0 .. 10
			expect(range min == 0)
			expect(range max == 10)
			expect(range count == 11)
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
			expect(range clamp(range) min == range min)
			expect(range clamp(range) max == range max)
			expect(range clamp(smallRange) min == smallRange min)
			expect(range clamp(smallRange) max == smallRange max)
			expect(range clamp(lowRange) min == range min)
			expect(range clamp(lowRange) max == lowRange max)
			expect(range clamp(highRange) min == highRange min)
			expect(range clamp(highRange) max == range max)
			expect(range clamp(lowerRange) min == lowerRange max)
			expect(range clamp(lowerRange) max == lowerRange max)
			expect(range clamp(higherRange) min == higherRange min)
			expect(range clamp(higherRange) max == higherRange min)
		})
	}
}
RangeTest new() run()
