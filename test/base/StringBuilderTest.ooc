/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR s PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received s copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
use ooc-base
use ooc-unit

StringBuilderTest: class extends Fixture {
	init: func {
		super("StringBuilder")
		this add("constructor", func {
			sb := StringBuilder new("Hello")
			expect(sb count, is equal to(1))
			expect(sb toString(), is equal to("Hello"))
			sb2 := StringBuilder new(sb)
			expect(sb2 count, is equal to(1))
			expect(sb2 toString(), is equal to("Hello"))
		})
		this add("append", func {
			sb := StringBuilder new("Hello")
			sb append(" World")
			expect(sb count, is equal to(2))
			expect(sb toString(), is equal to("Hello World"))
			sb2 := StringBuilder new("Dlrow olleh ")
			sb2 append(sb)
			expect(sb2 count, is equal to(3))
			expect(sb2 toString(), is equal to("Dlrow olleh Hello World"))
		})
		this add("prepend", func {
			sb := StringBuilder new("World")
			sb prepend("Hello ")
			expect(sb count, is equal to(2))
			expect(sb toString(), is equal to("Hello World"))
			sb2 := StringBuilder new(" Dlrow olleh")
			sb2 prepend(sb)
			expect(sb2 count, is equal to(3))
			expect(sb2 toString(), is equal to("Hello World Dlrow olleh"))
		})
		this add("copy", func {
			sb := StringBuilder new("Hello World")
			sb2 := sb copy()
			expect(sb toString(), is equal to(sb2 toString()))
		})
		this add("+ operator", func {
			sb := StringBuilder new("Hello")
			sb2 := StringBuilder new(" World")
			sb3 := sb + sb2
			expect(sb3 count, is equal to(2))
			expect(sb3 toString(), is equal to("Hello World"))
			sb4 := sb + " World"
			expect(sb4 count, is equal to(2))
			expect(sb4 toString(), is equal to("Hello World"))
			sb5 := "Hello" + sb2
			expect(sb5 count, is equal to(2))
			expect(sb5 toString(), is equal to("Hello World"))
		})
	}
}
StringBuilderTest new() run()
