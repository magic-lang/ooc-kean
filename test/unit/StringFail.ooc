/*
 * Copyright(C) 2014 - Simon Mika<simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or(at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see<http://www.gnu.org/licenses/>.
 */

use ooc-unit

//!shouldcrash
StringFail: class extends Fixture {
	init: func {
		super("StringFail")
		isNull := is Null // FIXME: Does not work to skip variable and put expression below, why?
		this add("empty is null", func { expect("", isNull) })
		this add("code is null", func { expect("code", isNull) })
		this add("null is not null", func { expect(null, is not Null) })

		this add("null is empty", func { expect(null, is empty) })
		this add("null is empty", func { expect(null, is empty) })
		this add("code is empty", func { expect("code", is empty) })
		this add("empty is not empty", func { expect("", is not empty) })
		
		isNotEqualToCode := is not equal to("code") // FIXME: Does not work to skip variable and put expression below, why?
		this add("code is not equal to code", func { expect("code", isNotEqualToCode) })
		this add("code is equal to nerd", func { expect("code", is equal to("nerd")) })
		this add("code is equal to null", func { expect("code", is equal to(null)) })
		this add("code is equal to empty", func { expect("code", is equal to("")) })
		this add("null is equal to code", func { expect(null, is equal to("code")) })
		this add("empty is equal to code", func { expect("", is equal to("code")) })
	}
}

StringFail new() run() . free()
