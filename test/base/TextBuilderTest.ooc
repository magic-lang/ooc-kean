/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

TextBuilderTest: class extends Fixture {
	init: func {
		super("TextBuilder")
		this add("creating", func {
			tb := TextBuilder new()
			tb append(t"vid")
			tb append(t"flow")
			text := tb toText()
			expect(text take() count, is equal to(7))
			expect(text == t"vidflow")
			tb free()
			data := t"1,2,3" split(',')
			tb = TextBuilder new(data)
			data free()
			text = tb join(';') take()
			expect(text == t"1;2;3")
			tb free()
			text free()
		})
		this add("append", func {
			tb := TextBuilder new()
			tb append(t"test")
			tb append(t" test")
			tb append(t" data")
			expect(tb count, is equal to(14))
			expect(tb == t"test test data")
			tb append('a')
			tb append('b')
			tb append('c')
			expect(tb == t"test test dataabc")
			tb free()
		})
		this add("prepend", func {
			tb := TextBuilder new(t"World")
			tb prepend(t"Hello ")
			expect(tb count, is equal to(11))
			expect(tb == t"Hello World")
			tb prepend(t"String ")
			expect(tb count, is equal to(18))
			expect(tb == t"String Hello World")
			tb2 := TextBuilder new(t" in ooc")
			tb2 prepend(tb)
			expect(tb2 count, is equal to(25))
			expect(tb2 == t"String Hello World in ooc")
			tb prepend('x')
			tb prepend('y')
			tb prepend('z')
			expect(tb == t"zyxString Hello World")
			(tb, tb2) free()
		})
		this add("copy", func {
			sb := TextBuilder new(t"Hello World")
			sb2 := sb copy()
			expect(sb toText() == sb2 toText())
			(sb, sb2) free()
		})
		this add("== operator", func {
			sb := TextBuilder new(t"Hello")
			sb2 := TextBuilder new(t"Hello")
			sb3 := TextBuilder new(t"World")
			expect(sb == sb2)
			expect(sb != sb3)
			expect(sb == t"Hello")
			expect(sb != t"World")
			expect(t"Hello" == sb)
			expect(t"World" != sb)
			expect(sb == sb toText())
			t := sb toText()
			s := t take() toString()
			expect(s == t)
			(s, sb, sb2, sb3) free()
		})
		this add("join", func {
			tb := TextBuilder new()
			tb append(t"1")
			tb append(t"2")
			tb append(t"3")
			tb append(t"4")
			text := tb join(',')
			expect(text == t"1,2,3,4")
			text = tb join(t"--><--")
			expect(text == t"1--><--2--><--3--><--4")
			tb free()
		})
	}
}

TextBuilderTest new() run() . free()
