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

use unit

// TODO: Skipping the variable and having "is not equal to" inside an expect call does not work
StringTest: class extends Fixture {
	init: func {
		super("String")
		isNull := is Null
		this add("null is null", func { expect(null, isNull) })
		this add("empty is not null", func { expect("", is not Null) })

		this add("empty is empty", func { expect("", is empty) })
		this add("code is not empty", func { expect("code", is not empty) })

		this add("code is equal to code", func { expect("code", is equal to("code")) })
		isNotEqualToNerd := is not equal to("nerd")
		this add("code is not equal to nerd", func { expect("code", isNotEqualToNerd) })
		isNotEqualToNull := is not equal to(null)
		this add("code is not equal to null", func { expect("code", isNotEqualToNull) })
		isNotEqualToEmpty := is not equal to("")
		this add("code is not equal to empty", func { expect("code", isNotEqualToEmpty) })
		isNotEqualToCode := is not equal to("code")
		this add("null is not equal to code", func { expect(null, isNotEqualToCode) })
		isNotEqualToCode2 := is not equal to("code")
		this add("empty is not equal to code", func { expect("", isNotEqualToCode2) })
	}
}

StringTest new() run() . free()
