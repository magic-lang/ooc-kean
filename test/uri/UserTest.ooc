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
			name := "name"
			password := "password"
			userText := "name:password"
			user := User parse(userText)
			expect(user name, is equal to(name))
			expect(user password, is equal to(password))
			result := user toString()
			expect(result, is equal to(userText))
			(result, user) free()
		})
		this add("empty", func {
			user := User parse("")
			expect(user, is equal to(null))
		})
		this add("only name", func {
			name := "name"
			user := User parse(name)
			expect(user name, is equal to(name))
			expect(user password, is equal to(""))
			result := user toString()
			expect(result, is equal to(name))
			(result, user) free()
		})
	}
}

UserTest new() run() . free()
