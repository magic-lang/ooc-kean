/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

User: class {
	_name: Text
	_password: Text
	name ::= this _name take()
	password ::= this _password take()

	init: func(=_name, =_password)
	free: override func {
		this _name free(Owner Receiver)
		this _password free(Owner Receiver)
		super()
	}
	toText: func -> Text {
		result := Text empty
		if (!this name isEmpty)
			result += this name
		if (!this password isEmpty)
			result += t":" + this password
		result
	}
	parse: static func(data: Text) -> This {
		result: This
		d := data take()
		if (!d isEmpty) {
			splitted := d split(t":")
			newPassword := splitted count > 1 ? splitted remove() : Text empty
			newName := splitted remove()
			result = This new(newName take(), newPassword take())
			splitted free()
		}
		data free(Owner Receiver)
		result
	}
}
