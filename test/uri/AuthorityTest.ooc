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

AuthorityTest: class extends Fixture {
	init: func {
		super("Authority")
		this add("parse", func {
			userText := "name:password"
			endpointText := "one.two:123"
			authorityText := "name:password@one.two:123"
			authority := Authority parse(authorityText)

			(userString, endpointString, authorityString) := (authority user, authority endpoint, authority) toString()
			expect(userString, is equal to(userText))
			expect(endpointString, is equal to(endpointText))
			expect(authorityString, is equal to(authorityText))
			(userString, endpointString, authorityString) free()
			authority free()
		})
		this add("empty", func {
			authority := Authority parse("")
			expect(authority, is Null)
		})
		this add("only endpoint", func {
			endpointText := "one.two:123"
			authority := Authority parse(endpointText)
			expect(authority user, is Null)
			(endPointString, authorityString) := (authority endpoint, authority) toString()
			expect(endPointString, is equal to(endpointText))
			expect(authorityString, is equal to(endpointText))
			(endPointString, authorityString) free()
			authority free()
		})
	}
}

AuthorityTest new() run() . free()
