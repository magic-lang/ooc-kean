/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

Endpoint: class {
	_host: VectorList<String>
	_port: Int
	host ::= this _host
	port ::= this _port

	init: func (=_host, =_port)
	free: override func {
		this _host free()
		super()
	}
	toString: func -> String {
		contents := StringBuilder new()
		for (i in 0 .. this _host count) {
			if (i != 0)
				contents add(".")
			contents add(this _host[i])
		}
		portString := this _port toString()
		if (this _port != 0)
			contents add(":") . add(portString)
		result := contents join("")
		(contents, portString) free()
		result
	}
	parse: static func (data: String) -> This {
		result: This
		if (!data empty()) {
			splitted := data split(':')
			newPort := splitted count > 1 ? splitted[1] toInt() : 0
			newHost := splitted[0] split('.')
			result = This new(newHost, newPort)
			splitted free()
		}
		result
	}
}
