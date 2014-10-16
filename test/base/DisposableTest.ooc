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

use ooc-unit
use ooc-base

DisposableTest: class extends Fixture {
	init: func () {
		super("Disposable")
		this add("dispose", func() {
			c := DisposableImplementation new()
			d := c as IDisposable
			expect(c disposed, is false)
			d dispose()
			expect(c disposed, is true)
		})
	}
}
DisposableImplementation: class implements IDisposable {
	disposed := false
	init: func {	}
	dispose: func {
		this disposed = true
	}
}
DisposableTest new() run()
