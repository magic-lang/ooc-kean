/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import native/[ThreadLocalUnix, ThreadLocalWin32]

ThreadLocal: abstract class <T> {
	set: abstract func (value: T)
	get: abstract func -> T
	hasValue: abstract func -> Bool
	new: static func <T> -> This<T> {
		result: This<T> = null
		version (unix || apple)
			result = ThreadLocalUnix<T> new() as This
		version (windows)
			result = ThreadLocalWin32<T> new() as This
		if (result == null)
			Exception new(This, "Unsupported platform!\n") throw()
		result
	}
	new: static func ~withVal <T> (val: T) -> This <T> {
		instance := This<T> new()
		instance set(val)
		instance
	}
}
