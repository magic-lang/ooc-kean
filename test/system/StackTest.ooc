/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

StackTest: class extends Fixture {
	init: func {
		super("Stack")
		this add("basic use", func {
			stack := Stack<Int> new()
			for (i in 1 .. 7)
				stack push(i)
			expect(stack count as Int, is equal to(6))
			expect(stack isEmpty, is false)
			value := stack pop()
			expect(value, is equal to(6))
			value = stack pop()
			expect(value, is equal to(5))
			expect(stack isEmpty, is false)
			stack clear()
			expect(stack isEmpty, is true)
			stack free()
		})
		this add("pop, top, peek", func {
			stack := Stack<Int> new()
			for (i in 1 .. 5000)
				stack push(i)
			first := stack top
			second := stack top
			expect(first, is equal to(second))
			first = stack pop()
			second = stack top
			expect(first - second, is equal to(1))
			expect(first, is equal to(4999))
			expect(second, is equal to(4998))
			stack free()
		})
		this add("clearing", func {
			stack := Stack<Int> new()
			for (i in 1 .. 5000)
				stack push(i)
			for (i in 0 .. 4999)
				expect(stack peek(i), is equal to(4999 - i))
			for (i in 1 .. 4999) {
				expect(stack count as Int, is equal to(5000 - i))
				expect(stack pop(), is equal to(5000 - i))
			}
			expect(stack pop(), is equal to(1))
			expect(stack isEmpty, is true)
			stack free()
		})
	}
}

StackTest new() run() . free()
