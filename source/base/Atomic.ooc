/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include ./atomic

AtomicBool: cover from atomic_bool {
	init: extern (atomic_init_bool) func@ (value := false)
	get: extern (atomic_load_bool) func@ -> Bool
	set: extern (atomic_store_bool) func@ (value: Bool)
	swap: extern (atomic_exchange_bool) func@ (value: Bool) -> Bool
	and: extern (atomic_fetch_and_bool) func@ (value: Bool) -> Bool
	or: extern (atomic_fetch_or_bool) func@ (value: Bool) -> Bool
	xor: extern (atomic_fetch_xor_bool) func@ (value: Bool) -> Bool
	new: static func (value := false) -> This {
		result: This
		result init(value)
		result
	}
}

AtomicInt: cover from atomic_int {
	init: extern (atomic_init_int) func@ (value := 0)
	get: extern (atomic_load_int) func@ -> Int
	set: extern (atomic_store_int) func@ (value: Int)
	swap: extern (atomic_exchange_int) func@ (value: Int) -> Int
	add: extern (atomic_fetch_add_int) func@ (value: Int) -> Int
	subtract: extern (atomic_fetch_sub_int) func@ (value: Int) -> Int
	new: static func (value := 0) -> This {
		result: This
		result init(value)
		result
	}
}
