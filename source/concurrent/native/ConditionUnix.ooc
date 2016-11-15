/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(unix || apple) {
use base
import ../WaitCondition

ConditionUnix: class extends WaitCondition {
	_backend: PThreadCond*

	init: func {
		this _backend = calloc(1, PThreadCond size) as PThreadCond*
		result := pthread_cond_init(this _backend, null)
		if (result != 0)
			Debug error("Something went wrong when calling pthread_cond_init")
	}
	free: override func {
		pthread_cond_destroy(this _backend)
		memfree(this _backend)
		super()
	}
	wait: override func (mutex: Mutex) -> Bool {
		version(safe)
			Debug error(mutex class != MutexUnix, "ConditionUnix can work only with MutexUnix")
		pthread_cond_wait(this _backend, mutex as MutexUnix _backend&) == 0
	}
	signal: override func -> Bool { pthread_cond_signal(this _backend) == 0 }
	broadcast: override func -> Bool { pthread_cond_broadcast(this _backend) == 0 }
}
}
