/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use system

AtomicBool: cover {
	_backend: atomic_bool
	init: func@ (value := false) {
		atomic_init_bool(this _backend&, value)
	}
	get: func@ -> Bool {
		atomic_load_bool(this _backend&)
	}
	set: func@ (value: Bool) {
		atomic_store_bool(this _backend&, value)
	}
	swap: func@ (value: Bool) -> Bool {
		atomic_exchange_bool(this _backend&, value)
	}
	and: func@ (value: Bool) -> Bool {
		atomic_fetch_and_bool(this _backend&, value)
	}
	or: func@ (value: Bool) -> Bool {
		atomic_fetch_or_bool(this _backend&, value)
	}
	xor: func@ (value: Bool) -> Bool {
		atomic_fetch_xor_bool(this _backend&, value)
	}
}

AtomicInt: cover {
	_backend: atomic_int
	init: func@ (value := 0) {
		atomic_init_int(this _backend&, value)
	}
	get: func@ -> Int {
		atomic_load_int(this _backend&)
	}
	set: func@ (value: Int) {
		atomic_store_int(this _backend&, value)
	}
	swap: func@ (value: Int) -> Int {
		atomic_exchange_int(this _backend&, value)
	}
	add: func@ (value: Int) -> Int {
		atomic_fetch_add_int(this _backend&, value)
	}
	subtract: func@ (value: Int) -> Int {
		atomic_fetch_sub_int(this _backend&, value)
	}
}
