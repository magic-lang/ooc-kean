/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use uri
use collections
use base
use unit

EndpointTest: class extends Fixture {
	init: func {
		super("Endpoint")
		this add("parse", func {
			one := t"one"
			two := t"two"
			three := t"three"
			host := one + t"." + two + t"." + three
			port := t"1232"
			endpointText := (host + t":" + port) take()
			endpoint := Endpoint parse(endpointText)
			list := endpoint host
			expect(list[0] == one)
			expect(list[1] == two)
			expect(list[2] == three)
			expect(endpoint port == port take() toInt())
			expect(endpoint toText() == endpointText)
			endpointText free(Owner Sender)
			list free()
			endpoint free()
		})
		this add("empty", func {
			endpoint := Endpoint parse(t"")
			expect(endpoint == null)
		})
		this add("only host", func {
			one := t"one"
			two := t"two"
			endpointText := (one + t"." + two) take()
			endpoint := Endpoint parse(endpointText)
			list := endpoint host
			expect(list[0] == one)
			expect(list[1] == two)
			expect(endpoint port == 0)
			expect(endpoint toText() == endpointText)
			endpointText free(Owner Sender)
			list free()
			endpoint free()
		})
	}
}

EndpointTest new() run() . free()
