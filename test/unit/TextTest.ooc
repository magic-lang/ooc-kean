/*
 * Copyright(C) 2015 - Simon Mika<simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or(at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see<http://www.gnu.org/licenses/>.
 */

use base
use unit

TextTest: class extends Fixture {
	init: func {
		super("Text")
		this add("Text is equal to Text", func {
			text1 := Text new(c"abc", 3)
			text2 := Text new(c"abc", 3)
			expect(text1, is equal to(text2))
			text1 free(); text2 free()
		})
		isNotEqualToText2 := is not equal to(Text new(c"cba", 3))
		this add("Text1 is not equal to Text2", func {
			text1 := Text new(c"abc", 3)
			expect(text1, isNotEqualToText2)
			text1 free()
		})
	}
}

TextTest new() run() . free()
