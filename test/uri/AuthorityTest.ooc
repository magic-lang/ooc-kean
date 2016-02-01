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
			userText := Text new("name:password")
			endpointText := Text new("one.two:123")
			authorityText := userText + t"@" + endpointText
			authority := Authority parse(authorityText take())
			expect(authority user toText(), is equal to(userText))
			expect(authority endpoint toText(), is equal to(endpointText))
			expect(authority toText(), is equal to(authorityText))
			authority free()
		})
		this add("empty", func {
			authority := Authority parse(t"")
			expect(authority, is equal to(null))
		})
		this add("only endpoint", func {
			endpointText := Text new("one.two:123")
			authority := Authority parse(endpointText take())
			expect(authority user, is equal to(null))
			expect(authority endpoint toText(), is equal to(endpointText))
			expect(authority toText(), is equal to(endpointText))
			authority free()
		})
	}
}

AuthorityTest new() run() . free()
