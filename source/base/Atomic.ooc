/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use system

AtomicInt: cover {
	_backend: atomic_int
	init: func@ (value := 0) {
		atomic_init(this _backend&, value)
	}
	get: func@ -> Int {
		atomic_load(this _backend&)
	}
	set: func@ (value: Int) {
		atomic_store(this _backend&, value)
	}
	swap: func@ (value: Int) -> Int {
		atomic_exchange(this _backend&, value)
	}
	add: func@ (value: Int) -> Int {
		atomic_fetch_add(this _backend&, value)
	}
	subtract: func@ (value: Int) -> Int {
		atomic_fetch_sub(this _backend&, value)
	}
}
