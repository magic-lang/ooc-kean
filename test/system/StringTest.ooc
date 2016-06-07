/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

StringTest: class extends Fixture {
	init: func {
		super("String")
		this add("length, substring", func {
			string := "12345678"
			expect(string length(), is equal to(8))
			substring := string substring(4)
			substring2 := string substring(1, 3)
			expect(substring, is equal to("5678"))
			expect(substring2, is equal to("23"))
			(substring, substring2) free()
		})
		this add("clone", func {
			string := "123456"
			clone := string clone()
			other := clone clone()
			expect(string, is equal to(clone))
			clone free()
			expect(other, is equal to(string))
			other free()
		})
		this add("times, append, prepend", func {
			string := "123"
			times := string times(3)
			expect(times, is equal to("123123123"))
			times free()

			prepend := string prepend("0")
			append := prepend append("45")
			expect(append, is equal to("012345"))
			(prepend, append) free()
		})
		this add("empty", func {
			empty := ""
			expect(empty empty(), is true)
		})
		this add("startsWith, endsWith", func {
			string := "123456789"
			expect(string startsWith("123456789"))
			expect(string startsWith("1234"))
			expect(string startsWith("123"))
			expect(string startsWith("234"), is false)
			expect(string endsWith("123456789"))
			expect(string endsWith("6789"))
			expect(string endsWith("9"))
			expect(string endsWith("99"), is false)
		})
		this add("searching", func {
			string := "01234567891011121314151617181920"
			expect(string count('1'), is equal to(12))
			expect(string count("01"), is equal to(2))
			expect(string indexOf('3'), is equal to(3))
			expect(string lastIndexOf('3'), is equal to(17))
			indices := string findAll("01")
			expect(indices count, is equal to(2))
			expect(indices[0], is equal to(0))
			expect(indices[1], is equal to(11))
			indices free()
		})
		this add("trim", func {
			string := "aabcmarcusaaa"
			leftChar := string trimLeft('a')
			leftString := string trimLeft("a")
			rightChar := string trimRight('a')
			rightString := string trimRight("a")
			leftRightChar := string trim('a')
			leftRightString := string trim("a")

			expect(leftChar, is equal to("bcmarcusaaa"))
			expect(leftString, is equal to("bcmarcusaaa"))
			expect(rightChar, is equal to("aabcmarcus"))
			expect(rightString, is equal to("aabcmarcus"))
			expect(leftRightChar, is equal to("bcmarcus"))
			expect(leftRightString, is equal to("bcmarcus"))

			(leftChar, leftString, rightChar, rightString, leftRightChar, leftRightString) free()
		})
		this add("toLower, toUpper, capitalize", func {
			string := "abcdeFGHijkl1234567890mnoPqrst$uvw!xyz"
			lower := string toLower()
			upper := string toUpper()
			capitalized := string capitalize()
			expect(lower, is equal to("abcdefghijkl1234567890mnopqrst$uvw!xyz"))
			expect(upper, is equal to("ABCDEFGHIJKL1234567890MNOPQRST$UVW!XYZ"))
			expect(capitalized, is equal to("AbcdeFGHijkl1234567890mnoPqrst$uvw!xyz"))
			(lower, upper, capitalized) free()
		})
		this add("replaceAll", func {
			string := "1 two three one 2 three one two 3"
			ones := string replaceAll("one", "1")
			twos := string replaceAll("2", "two")
			threes := string replaceAll("three", "3")
			expect(ones, is equal to("1 two three 1 2 three 1 two 3"))
			expect(twos, is equal to("1 two three one two three one two 3"))
			expect(threes, is equal to("1 two 3 one 2 3 one two 3"))
			(ones, twos, threes) free()
		})
		this add("reverse", func {
			string := "marcus"
			reversed := string reverse()
			expect(reversed, is equal to("sucram"))
			doubleReverse := reversed reverse()
			expect(doubleReverse, is equal to("marcus"))
			(reversed, doubleReverse) free()
		})
		this add("casts", func {
			myint := "12345" toInt()
			expect(myint, is equal to(12345))
			mylong := "123456789" toLong()
			expect(mylong, is equal to(123456789L))
			myfloat := "123.45" toFloat()
			expect(myfloat, is equal to(123.45f) within(0.00001f))
			mydouble := "123.456789" toDouble()
			expect(mydouble, is equal to(123.456789) within(0.00001))
		})
		this add("split", func {
			languages := "ooc, c, c++, java, c#"
			languagelist := languages split(", ")
			expect(languagelist count, is equal to(5))
			expect(languagelist[2], is equal to("c++"))
			languagelist free()

			languagelist = languages split(',')
			expect(languagelist count, is equal to(5))
			expect(languagelist[2], is equal to(" c++"))
			languagelist free()
		})
		this add("concatenation", func {
			(a, b, c, d, e) := ("a", "b", "c", "d", "e")
			ab := a + b
			bc := b + c
			cd := c + d
			de := d + e
			abbc := ab >> bc
			expect(abbc, is equal to("abbc"))
			cdabbc := cd << abbc
			expect(cdabbc, is equal to("cdabbc"))
			decdabbc := de & cdabbc
			expect(decdabbc, is equal to("decdabbc"))
			(bc, cd, decdabbc) free()
		})
	}
}

StringTest new() run() . free()
