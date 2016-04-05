/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use unit

LinkedListTest: class extends Fixture {
	init: func {
		super("LinkedList")
		this add("Basic use", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			for (_ in 0 .. 10)
				linkedlist add(42)
			listcopy := linkedlist copy()
			linkedlist add(5)
			linkedlist add(7)
			first := linkedlist first()
			last := linkedlist last()
			copylast := listcopy last()
			expect(first, is equal to(2))
			expect(last, is equal to(7))
			expect(copylast, is equal to(42))
			(linkedlist, listcopy) free()
		})
		this add("Size and clear", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			expect(linkedlist size, is equal to(3))
			linkedlist removeAt(1)
			expect(linkedlist size, is equal to(2))
			linkedlist clear()
			expect(linkedlist size, is equal to(0))
			linkedlist free()
		})
		this add("Last", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			last := linkedlist last()
			expect(last, is equal to(7))
			status := linkedlist removeLast()
			expect(status)
			last = linkedlist last()
			expect(last, is equal to(5))
			linkedlist free()
		})
		this add("set and get", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			old := linkedlist set(0, 42)
			item := linkedlist get(0)
			expect(old, is equal to(2))
			expect(item, is equal to(42))
			linkedlist free()
		})
		this add("indexes and deletion", func {
			linkedlist := LinkedList<Int> new()
			for (i in 0 .. 10)
				linkedlist add(i)
			for (i in 0 .. 10)
				linkedlist add(9 - i)
			firstTwo := linkedlist indexOf(2)
			lastTwo := linkedlist lastIndexOf(2)
			expect(firstTwo, is equal to(2))
			expect(lastTwo, is equal to(17))
			linkedlist remove(1) . remove(8) . removeLast()
			expect(linkedlist size, is equal to(17))
			firstTwo = linkedlist indexOf(2)
			lastTwo = linkedlist lastIndexOf(2)
			expect(firstTwo, is equal to(1))
			expect(lastTwo, is equal to(15))
			linkedlist free()
		})
		this add("operators", func {
			linkedlist := LinkedList<Int> new()
			linkedlist add(2)
			linkedlist add(5)
			linkedlist add(7)
			linkedlist[0] = 42
			item := linkedlist[0]
			expect(item, is equal to(42))
			linkedlist free()
		})
	}
}

LinkedListTest new() run() . free()
