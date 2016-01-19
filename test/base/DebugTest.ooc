/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use base
use ooc-unit

DebugTest: class extends Fixture {
	outputString: String = null

	init: func {
		super("Debug")
		Debug initialize(func (message: String) {
			if (this outputString != null)
				this outputString free()
			this outputString = message clone()
		} )
		Debug _level = DebugLevel Everything

		this add("test print", func {
			Debug print("first", DebugLevel Everything)
			expect(this outputString, is equal to("first"))
			Debug print("second", DebugLevel Warning)
			expect(this outputString, is equal to("second"))
			Debug print(t"third", DebugLevel Everything)
			expect(this outputString, is equal to("third"))
		})
		this add("higher level", func {
			Debug _level = DebugLevel Warning
			Debug print("first", DebugLevel Warning)
			expect(this outputString, is equal to("first"))
			Debug print("second", DebugLevel Notification)
			expect(this outputString, is equal to("first"))
		})
	}
}

DebugTest new() run() . free()
