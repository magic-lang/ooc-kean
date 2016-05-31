/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use uri

Authority: class {
	_user: User
	_endpoint: Endpoint
	user ::= this _user
	endpoint ::= this _endpoint

	init: func (=_user, =_endpoint)
	free: override func {
		if (this _user != null)
			this _user free()
		if (this _endpoint != null)
			this _endpoint free()
		super()
	}
	toString: func -> String {
		contents := StringBuilder new()
		userString: String = null
		endpointString: String = null
		if (this _user != null) {
			userString = this _user toString()
			contents add(userString) . add("@")
		}
		if (this _endpoint != null) {
			endpointString = this _endpoint toString()
			contents add(endpointString)
		}
		result := contents join("")
		contents free()
		if (userString != null)
			userString free()
		if (endpointString != null)
			endpointString free()
		result
	}
	parse: static func (data: String) -> This {
		result: This
		if (!data empty()) {
			splitted := data split('@')
			newUser := splitted count > 1 ? User parse(splitted[0]) : null
			newEndpoint := splitted count > 1 ? Endpoint parse(splitted[1]) : Endpoint parse(splitted[0])
			result = This new(newUser, newEndpoint)
			splitted free()
		}
		result
	}
}
