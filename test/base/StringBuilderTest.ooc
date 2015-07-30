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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
use ooc-base
use ooc-unit

StringBuilderTest: class extends Fixture {
	init: func {
		super("StringBuilder")
		this add("constructor", func {
				a := StringBuilder new("Hello")
				expect(a count, is equal to(1))
				expect(a toString(), is equal to("Hello"))
		})
		this add("add", func {
				a := StringBuilder new("Hello")
				a add(" World")
				expect(a count, is equal to(2))
				expect(a toString(), is equal to("Hello World"))
		})
		this add("append", func {
				a := StringBuilder new("Hello World")
				b := StringBuilder new(" Dlrow olleh")
				a append(b)
				expect(a count, is equal to(2))
				expect(a toString(), is equal to("Hello World Dlrow olleh"))
		})
		this add("prepend", func {
				a := StringBuilder new("Hello World")
				b := StringBuilder new("Dlrow olleh ")
				a prepend(b)
				expect(a count, is equal to(2))
				expect(a toString(), is equal to("Dlrow olleh Hello World"))
		})
		this add("copy", func {
			a := StringBuilder new("Hello World")
			b := a copy()
			expect(a toString(), is equal to(b toString()))
		})
		/*this add("+ operator", func {
			a := StringBuilder new("Hello World")
			b := StringBuilder new(" Dlrow olleh")
			c := a + b
			c class name println()
			//expect(c count, is equal to(2))
			//expect(c toString(), is equal to("Hello World Dlrow olleh"))
		})*/
	}
}
StringBuilderTest new() run()
