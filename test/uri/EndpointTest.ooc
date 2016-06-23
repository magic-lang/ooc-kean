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
			one := "one"
			two := "two"
			three := "three"
			port := "1232"
			endpointText := "one.two.three:1232"
			endpoint := Endpoint parse(endpointText)
			list := endpoint host
			expect(list[0] == one)
			expect(list[1] == two)
			expect(list[2] == three)
			expect(endpoint port == port toInt())
			endpointString := endpoint toString()
			expect(endpointString == endpointText)
			(endpoint, endpointString) free()
		})
		this add("empty", func {
			endpoint := Endpoint parse("")
			expect(endpoint, is Null)
		})
		this add("only hos", func {
			one := "one"
			two := "two"
			endpointText := "one.two"
			endpoint := Endpoint parse(endpointText)
			list := endpoint host
			expect(list[0] == one)
			expect(list[1] == two)
			expect(endpoint port == 0)
			endpointString := endpoint toString()
			expect(endpointString == endpointText)
			(endpoint, endpointString) free()
		})
	}
}

EndpointTest new() run() . free()
