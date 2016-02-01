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

UserTest: class extends Fixture {
	init: func {
		super("User")
		this add("parse", func {
			name := t"name"
			password := t"password"
			userText := (name + t":" + password) take()
			user := User parse(userText)
			expect(user name, is equal to(name))
			expect(user password, is equal to(password))
			expect(user toText(), is equal to(userText))
			userText free(Owner Sender)
			user free()
		})
		this add("empty", func {
			user := User parse(t"")
			expect(user, is equal to(null))
		})
		this add("only name", func {
			name := Text new("name")
			user := User parse(name)
			expect(user name, is equal to(name))
			expect(user password, is equal to(Text empty))
			expect(user toText(), is equal to(name))
			user free()
		})
	}
}

UserTest new() run() . free()
