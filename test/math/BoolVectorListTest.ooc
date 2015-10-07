/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

use ooc-math
use ooc-unit
import math

BoolVectorListTest: class extends Fixture {
	init: func {
		super("BoolVectorList")
		tolerance := 0.0001f
		this add("tally and reverse", func {
			list := BoolVectorList new()
			list add(true)
			list add(false)
			list add(true)
			list add(true)
			list add(true)
			list add(false)
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
			list free()
		})
		
		this add("dilation", func {
			list := BoolVectorList new() //1100001110001110
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(false)
			list add(false)
			list add(true)
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(false)
			list add(true)
			list add(true)
			list add(true)
			list add(false)
			dilated := list dilation(3)
			expect(dilated[2])
			expect(!dilated[3])
			expect(dilated[5])
			expect(dilated[9])
			expect(!dilated[10])
			expect(dilated[11])
			expect(dilated[15])
			list free()
			dilated free()
		})
		
		this add("erosion", func {
			list := BoolVectorList new() //1100001110001110
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(false)
			list add(false)
			list add(true)
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(false)
			list add(true)
			list add(true)
			list add(true)
			list add(false)
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
			list free()
			eroded free()
		})
		
		this add("opening", func {
			list := BoolVectorList new() //11011001
			list add(true)
			list add(true)
			list add(false)
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(true)
			opened := list opening(3)
			expect(opened[0])
			expect(opened[1])
			expect(!opened[2])
			expect(!opened[3])
			expect(!opened[4])
			expect(!opened[5])
			expect(!opened[6])
			expect(!opened[7])
			list free()
			opened free()
		})
		
		this add("closing", func {
			list := BoolVectorList new() //11011001
			list add(true)
			list add(true)
			list add(false)
			list add(true)
			list add(true)
			list add(false)
			list add(false)
			list add(true)
			closed := list closing(3)
			expect(closed[0])
			expect(closed[1])
			expect(closed[2])
			expect(closed[3])
			expect(closed[4])
			expect(closed[5])
			expect(closed[6])
			expect(closed[7])
			list free()
			closed free()
		})
		
		this add("logical operators", func {
			list := BoolVectorList new() //11010
			list add(true)
			list add(true)
			list add(false)
			list add(true)
			list add(false)
			other := BoolVectorList new() //10001
			other add(true)
			other add(false)
			other add(false)
			other add(false)
			other add(true)
			listAndOther := list && other
			listOrOther := list || other
			expect(listAndOther tally(true), is equal to(1))
			expect(listOrOther tally(true), is equal to(4))
			list free()
			other free()
			listAndOther free()
			listOrOther free()
		})
	}
}

BoolVectorListTest new() run()
