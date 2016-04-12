/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use math
use unit

BoolVectorListTest: class extends Fixture {
	init: func {
		super("BoolVectorList")
		this add("tally and reverse", func {
			list := BoolVectorList new()
			list add(true) . add(false) . add(true) . add(true) . add(true) . add(false)
			expect(list tally(true), is equal to(4))
			expect(list tally(false), is equal to(2))
			reversed := list reverse()
			expect(reversed tally(true), is equal to(list tally(true)))
			expect(reversed tally(false), is equal to(list tally(false)))
			expect(!reversed[0])
			expect(reversed[1])
			expect(reversed[2])
			expect(reversed[3])
			expect(!reversed[4])
			expect(reversed[5])
			(list, reversed) free()
		})
		this add("dilation", func {
			list := this _createFromText(t"1100 0011 1000 1110")
			dilated := list dilation(3)
			expect(dilated[2])
			expect(!dilated[3])
			expect(dilated[5])
			expect(dilated[9])
			expect(!dilated[10])
			expect(dilated[11])
			expect(dilated[15])
			(list, dilated) free()
		})
		this add("erosion", func {
			list := this _createFromText(t"1100 0011 1000 1110")
			eroded := list erosion(3)
			expect(!eroded[1])
			expect(!eroded[2])
			expect(!eroded[5])
			expect(!eroded[6])
			expect(eroded[7])
			expect(!eroded[8])
			expect(!eroded[11])
			expect(!eroded[12])
			expect(eroded[13])
			expect(!eroded[14])
			expect(!eroded[15])
			(list, eroded) free()
		})
		this add("opening", func {
			list := this _createFromText(t"1101 1001")
			opened := list opening(3)
			expect(opened[0])
			expect(opened[1])
			expect(!opened[2])
			expect(!opened[3])
			expect(!opened[4])
			expect(!opened[5])
			expect(!opened[6])
			expect(!opened[7])
			(list, opened) free()
		})
		this add("closing", func {
			list := this _createFromText(t"1101 1001")
			closed := list closing(3)
			expect(closed[0])
			expect(closed[1])
			expect(closed[2])
			expect(closed[3])
			expect(closed[4])
			expect(closed[5])
			expect(closed[6])
			expect(closed[7])
			(list, closed) free()
		})
		this add("logical operators", func {
			list := this _createFromText(t"11010")
			other := this _createFromText(t"10001")
			listAndOther := list && other
			listOrOther := list || other
			expect(listAndOther tally(true), is equal to(1))
			expect(listOrOther tally(true), is equal to(4))
			(list, other, listAndOther, listOrOther) free()
		})
		this add("toFloatVectorList", func {
			list := this _createFromText(t"11001")
			floatList := list toFloatVectorList()
			expect(floatList sum, is equal to(3.0f) within(0.01f))
			(floatList, list) free()
		})
		this add("toText", func {
			list := this _createFromText(t"101")
			text := list toText() take()
			expect(text, is equal to(t"true\nfalse\ntrue"))
			(text, list) free()
		})
	}
	_createFromText: func (content: Text) -> BoolVectorList {
		result := BoolVectorList new()
		for (i in 0 .. content count) {
			if (content[i] == '1')
				result add(true)
			else if (content[i] == '0')
				result add(false)
		}
		result
	}
}

BoolVectorListTest new() run() . free()
