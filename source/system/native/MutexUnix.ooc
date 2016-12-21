/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Mutex

version(unix || apple) {
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
			version(debugDeadlock) {
				timeLimit_sec := 1
				deadline: TimeSpec
				currentTime: TimeVal
				gettimeofday(currentTime&, null)
				(deadline tv_sec, deadline tv_nsec) = (currentTime tv_sec + (timeLimit_sec as TimeT), (currentTime tv_usec * 1000) as Int)
				if (pthread_mutex_timedlock(this _backend&, deadline&) != 0)
					raise("Error! [" + this class name + " stalled for more than " + timeLimit_sec + " seconds and timed out]")
			}
			else
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
