/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */
/*
use base
use unit

DebugTest: class extends Fixture {
	outputString: String = null

	init: func {
		super("Debug")
		Debug initialize(func (message: String) {
			if (this outputString != null)
				this outputString free()
			this outputString = message clone()
		})
		Debug _level = DebugLevel Everything

		this add("test print", func {
			Debug print("first", DebugLevel Everything)
			expect(this outputString, is equal to("first"))
			Debug print("second", DebugLevel Warning)
			expect(this outputString, is equal to("second"))
			Debug print("third", DebugLevel Everything)
			expect(this outputString, is equal to("third"))
		})
		this add("higher level", func {
			Debug _level = DebugLevel Warning
			Debug print("first", DebugLevel Warning)
			expect(this outputString, is equal to("first"))
			Debug print("second", DebugLevel Notification)
			expect(this outputString, is equal to("first"))
		})
		this add("test error", func {
			try {
				Debug error("first")
				expect(false)
			}
			catch (e: Exception) {
				expect(e, is notNull)
				e free()
			}
		})
	}
	free: override func {
		this outputString free()
		super()
	}
}

DebugTest new() run() . free()*/
