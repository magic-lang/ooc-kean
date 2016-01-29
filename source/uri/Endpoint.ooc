/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Endpoint: class {
	_host: VectorList<Text>
	_port: Int
	host: VectorList<Text> { get {
		result := VectorList<Text> new()
		for (i in 0 .. this _host count)
			result add(this _host[i] take())
		result
	}}
	port ::= this _port

	init: func (=_host, =_port)
	free: override func {
		for (i in 0 .. this _host count)
			this _host[i] free(Owner Receiver)
		this _host free()
		super()
	}
	toText: func -> Text {
		result := Text new()
		for (i in 0 .. this _host count)
			result += i == 0 ? this _host[i] take() : t"." + this _host[i] take()
		if (this _port != 0) {
			portString := this _port toString()
			result += t":" + Text new(portString)
			portString free()
		}
		result
	}
	parse: static func(data: Text) -> This {
		result: This
		d := data take()
		if (!d isEmpty) {
			splitted := d split(t":")
			newPort := splitted count > 1 ? splitted remove() toInt() : 0
			newHost := splitted remove() split(t".")
			for (i in 0 .. newHost count)
				newHost[i] = newHost[i] take()
			result = This new(newHost, newPort)
			splitted free()
		}
		data free(Owner Receiver)
		result
	}
}
