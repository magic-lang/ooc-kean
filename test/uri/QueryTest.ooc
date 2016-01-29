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

QueryTest: class extends Fixture {
	init: func {
		super("Query")
		this add("parse", func {
			one := t"one"
			two := t"two"
			three := t"three"
			valueOne := t"1"
			valueTwo := t"2"
			valueThree := t"3"
			queryText := (one + t"=" + valueOne + t";" + two + t"=" + valueTwo + t";" + three + t"=" + valueThree) take()
			query := Query parse(queryText)
			attributes := query attributes
			values := query values
			expect(attributes[0] == one)
			expect(attributes[1] == two)
			expect(attributes[2] == three)
			expect(values[0] == valueOne)
			expect(values[1] == valueTwo)
			expect(values[2] == valueThree)
			expect(query toText() == queryText)
			expect(query contains(one) == true)
			expect(query contains(t"non existing") == false)
			expect(query getValue(two) == valueTwo)
			expect(query getValue(t"four") == Text empty)
			queryText free(Owner Sender)
			attributes free()
			values free()
			query free()
		})
		this add("empty", func {
			query := Query parse(t"")
			expect(query == null)
		})
		this add("missing values", func {
			one := t"one"
			two := t"two"
			three := t"three"
			valueOne := t"1"
			valueThree := t"3"
			queryText := (one + t"=" + valueOne + t";" + two + t";" + three + t"=" + valueThree) take()
			query := Query parse(queryText)
			attributes := query attributes
			values := query values
			expect(attributes[0] == one)
			expect(attributes[1] == two)
			expect(attributes[2] == three)
			expect(values[0] == valueOne)
			expect(values[1] == Text empty)
			expect(values[2] == valueThree)
			expect(query toText() == queryText)
			expect(query contains(one) == true)
			expect(query contains(two) == true)
			expect(query getValue(two) == Text empty)
			expect(query getValue(three) == valueThree)
			queryText free(Owner Sender)
			attributes free()
			values free()
			query free()
		})
	}
}

QueryTest new() run() . free()
