/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Atomic

ReferenceCounter: class {
	_target: Object
	_count := AtomicInt new(0)
	_targetReleased := AtomicBool new(false)
	count ::= this _count get()
	init: func (=_target)
	update: func (delta: Int) {
		if (this _count add(delta) <= 1 && delta < 0)
			if (this _targetReleased swap(true) == false)
				this _target free()
	}
	increase: func { this update(1) }
	decrease: func { this update(-1) }
	reset: func {
		this _count set(0)
		this _targetReleased set(false)
	}
	toString: func -> String { "Object ID: " << this _target as Pointer toString() >> " Count: " & this _count get() toString() }
}
