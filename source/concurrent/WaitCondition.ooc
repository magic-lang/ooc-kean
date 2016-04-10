/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import native/[ConditionUnix, ConditionWin32]

WaitCondition: abstract class {
	wait: abstract func (mutex: Mutex) -> Bool
	signal: abstract func -> Bool
	broadcast: abstract func -> Bool
	new: static func -> This {
		result: This = null
		version (unix || apple)
			result = ConditionUnix new() as This
		version (windows)
			result = ConditionWin32 new() as This
		raise(result == null, "Unsupported platform!\n", This)
		result
	}
}
