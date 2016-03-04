/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use concurrent

WaitLock: class {
	_waitCondition := WaitCondition new()
	_mutex : Mutex
	_ownsMutex : Bool
	init: func {
		this _mutex = Mutex new()
		this _ownsMutex = true
	}
	init: func ~WithMutex (mutex: Mutex)
	{
		this _mutex = mutex
		this _ownsMutex = false
	}
	free: override func {
		if(this _ownsMutex) {
			this _mutex free()
			this _mutex = null
		}
		this _waitCondition free()
		this _waitCondition = null
		super()
	}
	lock: func { this _mutex lock() }
	unlock: func { this _mutex unlock() }
	lockWhen: func (condition: Func -> Bool)
	{
		this lock()
		while (!condition())
			this _waitCondition wait(this _mutex)
		(condition as Closure) free(Owner Receiver)
	}
	with: func (f: Func) {
		this _mutex with(f)
	}
	wake: func -> Bool
	{
		this _waitCondition signal()
	}
	wakeAll: func -> Bool
	{
		this _waitCondition broadcast()
	}
}
