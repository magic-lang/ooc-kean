/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry

_MapEntry: class {
	key: String
	value: Object
	_ownsObject: Bool
	init: func (=key, =value, =_ownsObject)
	free: override func {
		if (this _ownsObject)
			this value free()
		super()
	}
}

_Map: class {
	_entries := VectorList<_MapEntry> new()
	init: func
	free: override func {
		this _entries free()
		super()
	}
	add: func (key: String, value: Object, ownsObject: Bool) {
		entry := this get(key)
		if (entry != null) {
			if (entry _ownsObject)
				entry value free()
			entry value = value
		}
		else
			this _entries add(_MapEntry new(key, value, ownsObject))
	}
	get: func (key: String) -> _MapEntry {
		result: _MapEntry = null
		for (i in 0 .. this _entries count)
			if (this _entries[i] key == key)
				result = this _entries[i]
		result
	}
	apply: func (action: Func (String, Object)) {
		for (i in 0 .. this _entries count) {
			entry := this _entries[i]
			action(entry key, entry value)
		}
	}
}

Map: abstract class {
	_bindings := _Map new()
	init: func
	free: override func {
		this _bindings free()
		super()
	}
	useProgram: abstract func (forbiddenInput: Pointer, positionTransform, textureTransform: FloatTransform3D)
	add: func <T> (key: String, value: T) {
		if (T inheritsFrom(Object))
			this _bindings add(key, value as Object, false)
		else
			this _bindings add(key, Cell<T> new(value), true)
	}
	get: func (key: String) -> Object { this _bindings get(key) value }
	apply: func (action: Func (String, Object)) { this _bindings apply(action) }
}
