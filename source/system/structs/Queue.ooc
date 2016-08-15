/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Queue: abstract class <T> {
	_count := 0
	count ::= this _count
	empty ::= this count == 0
	first: T {
		get { this[0] }
		set (value) { this[0] = value }
	}
	last: T {
		get { this[-1] }
		set (value) { this[-1] = value }
	}

	init: func
	clear: abstract func
	enqueue: abstract func (item: T)
	dequeue: abstract func ~default (fallback: T) -> T
	peek: abstract func ~default (fallback: T) -> T
	abstract operator [] (index: Int) -> T
	abstract operator []= (index: Int, value: T)
}
