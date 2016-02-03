/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

CharBufferIterator: class <T> extends BackIterator<T> {
	i := 0
	str: CharBuffer

	init: func ~withStr (=str)

	hasNext: override func -> Bool {
		i < str size
	}

	next: override func -> T {
		c := (str data + i)@
		i += 1
		c
	}

	hasPrevious: override func -> Bool {
		i > 0
	}

	prev: override func -> T {
		i -= 1
		(str data + i)@
	}

	remove: override func -> Bool { false } // this could be implemented!
}
