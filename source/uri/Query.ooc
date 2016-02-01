/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Query: class {
	_attributes: VectorList<Text>
	_values: VectorList<Text>
	attributes: VectorList<Text> { get {
		result := VectorList<Text> new()
		for (i in 0 .. this _attributes count)
			result add(this _attributes[i] take())
		result
	}}
	values: VectorList<Text> { get {
		result := VectorList<Text> new()
		for (i in 0 .. this _values count)
			result add(this _values[i] take())
		result
	}}

	init: func(=_attributes, =_values)
	free: override func {
		for (i in 0 .. this _attributes count)
			this _attributes[i] free(Owner Receiver)
		for (i in 0 .. this _values count)
			this _values[i] free(Owner Receiver)
		this _attributes free()
		this _values free()
		super()
	}
	toText: func -> Text {
		result := Text empty
		for (i in 0 .. this _attributes count) {
			argument := _attributes[i] take()
			if (this _values[i] take() != Text empty)
				argument += t"=" + this _values[i] take()
			result += i == 0 ? argument : t";" + argument
		}
		result
	}
	contains: func(attribute: Text) -> Bool {
		result := false
		for (i in 0 .. this _attributes count) {
			if (this _attributes[i] take() == attribute) {
				result = true
				i = this _attributes count
			}
		}
		result
	}
	getValue: func(attribute: Text) -> Text {
		result := Text empty
		for (i in 0 .. this _attributes count) {
			if (this _attributes[i] take() == attribute) {
				result = this _values[i] take()
				i = this _attributes count
			}
		}
		result
	}
	parse: static func(data: Text) -> This {
		result: This
		d := data take()
		if (!d isEmpty) {
			splitted := d split(t";")
			attributes := VectorList<Text> new()
			values := VectorList<Text> new()
			for (i in 0 .. splitted count) {
				argument := splitted[i] split(t"=")
				values add(argument count > 1 ? argument remove() take() : Text empty)
				attributes add(argument remove() take())
				argument free()
			}
			if (attributes count != values count)
				raise("Length of attributes and values vectors are not the same")
			result = This new(attributes, values)
			splitted free()
		}
		data free(Owner Receiver)
		result
	}
}
