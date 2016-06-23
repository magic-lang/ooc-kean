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
			one := "one"
			two := "two"
			three := "three"
			valueOne := "1"
			valueTwo := "2"
			valueThree := "3"
			queryText := "one=1;two=2;three=3"
			query := Query parse(queryText)
			attributes := query attributes
			values := query values
			expect(attributes[0] == one)
			expect(attributes[1] == two)
			expect(attributes[2] == three)
			expect(values[0] == valueOne)
			expect(values[1] == valueTwo)
			expect(values[2] == valueThree)
			queryString := query toString()
			expect(queryString == queryText)
			expect(query contains(one) as Bool, is true)
			expect(query contains("non existing") as Bool, is false)
			expect(query getValue(two) == valueTwo)
			expect(query getValue("four") == "")
			(queryString, query) free()
		})
		this add("empty", func {
			query := Query parse("")
			expect(query, is Null)
		})
		this add("missing values", func {
			one := "one"
			two := "two"
			three := "three"
			valueOne := "1"
			valueThree := "3"
			queryText := "one=1;two;three=3"
			query := Query parse(queryText)
			attributes := query attributes
			values := query values
			expect(attributes[0] == one)
			expect(attributes[1] == two)
			expect(attributes[2] == three)
			expect(values[0] == valueOne)
			expect(values[1] == "")
			expect(values[2] == valueThree)
			queryString := query toString()
			expect(queryString == queryText)
			expect(query contains(one) as Bool, is true)
			expect(query contains(two) as Bool, is true)
			expect(query getValue(two) == "")
			expect(query getValue(three) == valueThree)
			(queryString, query) free()
		})
	}
}

QueryTest new() run() . free()
