//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This _program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This _program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this _program. If not, see <http://www.gnu.org/licenses/>.
use geometry
use base
use collections
import Map

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
version(!gpuOff) {
GpuMap: abstract class extends Map {
	_bindings := _Map new()
	init: func {
		this model = FloatTransform3D identity
		this view = FloatTransform3D identity
		this projection = FloatTransform3D identity
		this textureTransform = FloatTransform3D identity
	}
	free: override func {
		this _bindings free()
		super()
	}
	use: virtual func
	add: func <T> (key: String, value: T) {
		if (T inheritsFrom?(Object))
			this _bindings add(key, value as Object, false)
		else
			this _bindings add(key, Cell<T> new(value), true)
	}
	get: func (key: String) -> Object { this _bindings get(key) value }
	apply: func (action: Func (String, Object)) { this _bindings apply(action) }
}
}
