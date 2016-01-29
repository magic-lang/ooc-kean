/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use uri

Authority: class {
	_user: User
	_endpoint: Endpoint
	user ::= this _user
	endpoint ::= this _endpoint

	init: func(=_user, =_endpoint)
	free: override func {
		if (this _user != null)
			this _user free()
		if (this _endpoint != null)
			this _endpoint free()
		super()
	}
	toText: func -> Text {
		result := Text new()
		if (this _user != null)
			result += this _user toText() + t"@"
		if (this _endpoint != null)
			result += this _endpoint toText()
		result
	}
	parse: static func(data: Text) -> This {
		result: This
		d := data take()
		if (!d isEmpty) {
			splitted := d split(t"@")
			newUser := splitted count > 1 ? User parse(splitted remove(0)) : null
			newEndpoint := Endpoint parse(splitted remove())
			result = This new(newUser, newEndpoint)
			splitted free()
		}
		data free(Owner Receiver)
		result
	}
}
