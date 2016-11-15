/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

Query: class {
	_attributes: VectorList<String>
	_values: VectorList<String>
	attributes ::= this _attributes
	values ::= this _values

	init: func (=_attributes, =_values)
	free: override func {
		(this _attributes, this _values) free()
		super()
	}
	toString: func -> String {
		contents := StringBuilder new()
		for (i in 0 .. this _attributes count) {
			if (i != 0)
				contents add(";")
			contents add(this _attributes[i])
			if (!this _values[i] empty())
				contents add("=") . add(this _values[i])
		}
		result := contents join("")
		contents free()
		result
	}
	contains: func (attribute: String) -> Bool {
		result := false
		for (i in 0 .. this _attributes count) {
			if (this _attributes[i] == attribute) {
				result = true
				break
			}
		}
		result
	}
	getValue: func (attribute: String) -> String {
		result := ""
		for (i in 0 .. this _attributes count) {
			if (this _attributes[i] == attribute) {
				result = this _values[i]
				break
			}
		}
		result
	}
	parse: static func (data: String) -> This {
		result: This
		if (!data empty()) {
			splitted := data split(';')
			attributes := VectorList<String> new()
			values := VectorList<String> new()
			for (i in 0 .. splitted count) {
				argument := splitted[i] split('=')
				values add(argument count > 1 ? argument[1] clone() : "")
				attributes add(argument[0] clone())
				argument free()
			}
			Debug error(attributes count != values count, "Length of attributes and values vectors are not the same")
			result = This new(attributes, values)
			splitted free()
		}
		result
	}
}
