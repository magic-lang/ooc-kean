/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent

SynchronizedResource: abstract class {
	_threadAffinity: ThreadId
	_recycle := true
	init: func { this _threadAffinity = Thread currentThreadId() }
	checkThreadAffinity: func -> Bool {
		this _threadAffinity equals(Thread currentThreadId())
	}
}

SynchronizedResourceRecycler: class {
	_mutex := Mutex new()
	_resources := HashMap<ThreadId, VectorList<SynchronizedResource>> new()
	init: func
	free: override func {
		this _clear()
		(this _mutex, this _resources) free()
	}
	create: func -> SynchronizedResource {
		result: SynchronizedResource = null
		this _mutex lock()
		objects := this _resources get(Thread currentThreadId())
		if (objects && objects count > 0)
			result = objects remove()
		this _mutex unlock()
		result
	}
	create: func ~withTestFunction (testSettings: Func (SynchronizedResource) -> Bool) -> SynchronizedResource {
		result: SynchronizedResource = null
		this _mutex lock()
		objects := this _resources get(Thread currentThreadId())
		if (objects)
			for (i in 0 .. objects count)
				if (testSettings(objects[i])) {
					result = objects[i]
					objects removeAt(i)
					break
				}
		this _mutex unlock()
		result
	}
	recycle: func (object: SynchronizedResource) {
		this _mutex lock()
		threadId := Thread currentThreadId()
		objects := this _resources get(threadId)
		if (!objects)
			objects = VectorList<SynchronizedResource> new()
		objects add(object)
		this _resources put(threadId, objects)
		this _mutex unlock()
	}
	_clear: func {
		this _mutex lock()
		this _resources each(func (list: VectorList<SynchronizedResource>) {
			if (list) {
				for (i in 0 .. list count) {
					object := list[i]
					object _recycle = false
					object free()
					list[i] = null
				}
				list free()
			}
		})
		this _mutex unlock()
	}
}
