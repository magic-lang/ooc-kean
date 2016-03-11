/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Cell: class <T> {
	val: __onheap__ T

	init: func (=val)
	init: func ~noval

	free: override func {
		memfree(this val)
		super()
	}

	set: func (=val)
	get: func -> T { val }

	toText: func -> Text {
		result: Text
		if (T inheritsFrom(Text))
			result = (this val as Text)
		else if (T inheritsFrom(String))
			result = Text new(this val as String)
		else if (T inheritsFrom(Bool))
			result = (this val as Bool) toText()
		else if (T inheritsFrom(Char))
			result = Text new((this val as Char) toString())
		else if (T inheritsFrom(Int))
			result = (this val as Int) toText()
		else if (T inheritsFrom(Long))
			result = (this val as Long) toText()
		else if (T inheritsFrom(LLong))
			result = (this val as LLong) toText()
		else if (T inheritsFrom(UInt))
			result = (this val as UInt) toText()
		else if (T inheritsFrom(ULong))
			result = (this val as ULong) toText()
		else if (T inheritsFrom(ULLong))
			result = (this val as ULLong) toText()
		else if (T inheritsFrom(Float))
			result = (this val as Float) toText()
		else if (T inheritsFrom(Double))
			result = (this val as Double) toText()
		else if (T inheritsFrom(LDouble))
			result = (this val as LDouble) toText()
		else
			raise("[Cell] toText() is not implemented on the specified type")
		result
	}
}

operator [] <T> (c: Cell<T>, T: Class) -> T {
	raise(!c T inheritsFrom(T), "Wants a %s, but got a %s" format(T name, c T name), Cell)
	c val
}
