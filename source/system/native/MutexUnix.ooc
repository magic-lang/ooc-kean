/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Mutex

version(unix || apple) {
	include pthread | (_XOPEN_SOURCE=500)
	include unistd

	PThreadMutex: cover from pthread_mutex_t
	PThreadMutexAttr: cover from pthread_mutexattr_t

	pthread_mutex_lock: extern func (PThreadMutex*)
	pthread_mutex_unlock: extern func (PThreadMutex*)
	pthread_mutex_init: extern func (PThreadMutex*, PThreadMutexAttr*)
	pthread_mutex_destroy: extern func (PThreadMutex*)
	pthread_mutexattr_init: extern func (PThreadMutexAttr*)
	pthread_mutexattr_settype: extern func (PThreadMutexAttr*, Int)

	PTHREAD_MUTEX_RECURSIVE: extern Int

	MutexUnix: class extends Mutex {
		_backend: PThreadMutex
		init: func {
			pthread_mutex_init(this _backend&, null)
		}
		free: override func {
			pthread_mutex_destroy(this _backend&)
			super()
		}
		lock: override func {
			pthread_mutex_lock(this _backend&)
		}
		unlock: override func {
			pthread_mutex_unlock(this _backend&)
		}
	}

	RecursiveMutexUnix: class extends RecursiveMutex {
		_backend: PThreadMutex
		init: func {
			attr: PThreadMutexAttr
			pthread_mutexattr_init(attr&)
			pthread_mutexattr_settype(attr&, PTHREAD_MUTEX_RECURSIVE)
			pthread_mutex_init(this _backend&, attr&)
		}
		free: override func {
			pthread_mutex_destroy(this _backend&)
			super()
		}
		lock: override func {
			pthread_mutex_lock(this _backend&)
		}
		unlock: override func {
			pthread_mutex_unlock(this _backend&)
		}
	}
}
