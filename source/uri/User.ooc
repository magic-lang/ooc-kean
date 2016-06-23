/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

User: class {
	_name: String
	_password: String
	name ::= this _name
	password ::= this _password

	init: func (=_name, =_password)
	free: override func {
		(this _name, this _password) free()
		super()
	}
	toString: func -> String {
		contents := StringBuilder new()
		if (!this name empty())
			contents add(this name)
		if (!this password empty())
			contents add(":") . add(this password)
		result := contents join("")
		contents free()
		result
	}
	parse: static func (data: String) -> This {
		result: This
		if (!data empty()) {
			splitted := data split(':')
			newPassword := splitted count > 1 ? splitted[1] clone() : ""
			newName := splitted[0] clone()
			result = This new(newName, newPassword)
			splitted free()
		}
		result
	}
}
