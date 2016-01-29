/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import structs/HashMap
import ../[ThreadLocal, Mutex]
import ThreadUnix
include unistd

version(unix || apple) {
	include pthread

	pthread_self: extern func -> PThread

	ThreadLocalUnix: class <T> extends ThreadLocal<T> {
		values := HashMap<PThread, T> new()
		valuesMutex := Mutex new()

		init: func ~unix
		set: override func (value: T) {
			valuesMutex lock()
			values put(pthread_self(), value)
			valuesMutex unlock()
		}
		get: override func -> T {
			valuesMutex lock()
			value := values get(pthread_self())
			valuesMutex unlock()
			value
		}
		hasValue: override func -> Bool {
			valuesMutex lock()
			has := values contains(pthread_self())
			valuesMutex unlock()
			has
		}
	}
}
