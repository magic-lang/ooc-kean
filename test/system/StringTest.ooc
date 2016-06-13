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
		this add("literal", func {
			// The & operand tries to free the literals but if the lock works then they should resist the attempt
			result: String
			for (i in 1 .. 100) {
				result = "ab" & "cd"
				expect(result, is equal to("abcd"))
				result free()
			}
			ab := "ab"
			cd := "cd"
			for (i in 1 .. 100) {
				result = ab & cd
				expect(result, is equal to("abcd"))
				result free()
			}
		})
		this add("length", func {
			expect("" length(), is equal to(0))
			expect("y" length(), is equal to(1))
			expect("s7" length(), is equal to(2))
			expect("k2d" length(), is equal to(3))
			expect("a6Uj" length(), is equal to(4))
			expect("I2Na5" length(), is equal to(5))
			expect("4Qj2nG" length(), is equal to(6))
			expect("An59D4j" length(), is equal to(7))
			expect("12345678" length(), is equal to(8))
		})
		this add("substring", func {
			string := "12345678"
			substring := string substring(4)
			substring2 := string substring(1, 3)
			expect(substring, is equal to("5678"))
			expect(substring2, is equal to("23"))
			(substring, substring2) free()
		})
		this add("clone", func {
			This cloneTest("")
			This cloneTest("0")
			This cloneTest("01")
			This cloneTest("012")
			This cloneTest("0123")
			This cloneTest("01234")
			This cloneTest("012345")
			This cloneTest("0123456")
			This cloneTest("01234567")
			This cloneTest("012345678")
			This cloneTest("0123456789")
			This cloneTest("0123456789A")
			This cloneTest("0123456789AB")
			This cloneTest("0123456789ABC")
			This cloneTest("0123456789ABCD")
			This cloneTest("0123456789ABCDE")
			This cloneTest("0123456789ABCDEF")
		})
		this add("times, append, prepend", func {
			string := "456"
			times := string times(3)
			expect(times, is equal to("456456456"))

			first := string prepend("123")
			expect(first, is equal to("123456"))
			second := first append("789")
			expect(second, is equal to("123456789"))
			third := second prepend("abc")
			expect(third, is equal to("abc123456789"))
			fourth := third append("def")
			expect(fourth, is equal to("abc123456789def"))

			(times, first, second, third, fourth) free()
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
			This trimTestLeft('a', "", "")
			This trimTestLeft("a", "aa", "")
			This trimTestLeft('1', "123", "23")
			This trimTestLeft("1", "123", "23")
			This trimTestLeft('a', "aabcmarcusaaa", "bcmarcusaaa")
			This trimTestLeft("a", "aabcmarcusaaa", "bcmarcusaaa")
			This trimTestRight("", 'a', "")
			This trimTestRight("aa", "a", "")
			This trimTestRight("123", '3', "12")
			This trimTestRight("123", "3", "12")
			This trimTestRight("aabcmarcusaaa", 'a', "aabcmarcus")
			This trimTestRight("aabcmarcusaaa", "a", "aabcmarcus")
			This trimTest("", 'a', "")
			This trimTest("aa", 'a', "")
			This trimTest("a", 'b', "a")
			This trimTest("aba", 'a', "b")
			This trimTest("aaabaaaa", 'a', "b")
			This trimTest("aaaaababaa", 'a', "bab")
			This trimTest("aabababaaa", 'a', "babab")
			This trimTest("aabcmarcusaaa", 'a', "bcmarcus")
			This trimTest("aabcmarcusaaa", "a", "bcmarcus")
		})
		this add("toLower", func {
			This toLowerTest("", "")
			This toLowerTest(" ", " ")
			This toLowerTest("az", "az")
			This toLowerTest("AZ", "az")
			This toLowerTest("1", "1")
			This toLowerTest("abc123", "abc123")
			This toLowerTest("Abc123", "abc123")
			This toLowerTest("ABC123", "abc123")
			This toLowerTest("abcdeFGHijkl1234567890mnoPqrst$uvw!xyz", "abcdefghijkl1234567890mnopqrst$uvw!xyz")
		})
		this add("toUpper", func {
			This toUpperTest("", "")
			This toUpperTest(" ", " ")
			This toUpperTest("az", "AZ")
			This toUpperTest("AZ", "AZ")
			This toUpperTest("1", "1")
			This toUpperTest("abc 123", "ABC 123")
			This toUpperTest("Abc 123", "ABC 123")
			This toUpperTest("ABC 123", "ABC 123")
			This toUpperTest("abcdeFGHijkl1234567890mnoPqrst$uvw!xyz", "ABCDEFGHIJKL1234567890MNOPQRST$UVW!XYZ")
		})
		this add("capitalize", func {
			This capitalizeTest("", "")
			This capitalizeTest(" ", " ")
			This capitalizeTest("az", "Az")
			This capitalizeTest("AZ", "AZ")
			This capitalizeTest("1", "1")
			This capitalizeTest("8b", "8b")
			This capitalizeTest("test", "Test")
			This capitalizeTest("Test", "Test")
			This capitalizeTest("TEST", "TEST")
			This capitalizeTest("teST", "TeST")
			This capitalizeTest("abcdeFGHijkl1234567890mnoPqrst$uvw!xyz", "AbcdeFGHijkl1234567890mnoPqrst$uvw!xyz")
			This capitalizeTest("capitalizing a very long sentence just in case of weird upper limits when allocating the result.", "Capitalizing a very long sentence just in case of weird upper limits when allocating the result.")
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
		this add("reverse", func {
			This reverseTest("", "")
			This reverseTest(" ", " ")
			This reverseTest("1", "1")
			This reverseTest("12", "21")
			This reverseTest("a", "a")
			This reverseTest("ab", "ba")
			This reverseTest("abc", "cba")
			This reverseTest("Test", "tseT")
			This reverseTest("Test!", "!tseT")
			This reverseTest("marcus", "sucram")
			This reverseTest("sucram", "marcus")
			This reverseTest("Testing", "gnitseT")
			This reverseTest("Reversing a very long sentence just in case of weird upper limits when allocating the result.", ".tluser eht gnitacolla nehw stimil reppu driew fo esac ni tsuj ecnetnes gnol yrev a gnisreveR")
		})
		this add("findAll", func {
			This findTest("", "")
			This findTest("a", "")
			This findTest("", "a")
			This findTest("abab", "ab", 0, 2)
			This findTest("abcab", "ab", 0, 3)
			This findTest("ababa", "aba", 0) // Finding following overlaps would make it useless for split
			This findTest("Babcb babcb cbabcba.", "abc", 1, 7, 14)
		})
	}
	cloneTest: static func (input: String) {
		clone := input clone()
		other := clone clone()
		expect(input, is equal to(clone))
		clone free()
		expect(other, is equal to(input))
		other free()
	}
	toUpperTest: static func (input, expected: String) {
		result := input toUpper()
		expect(result, is equal to(expected))
		result free()
	}
	toLowerTest: static func (input, expected: String) {
		result := input toLower()
		expect(result, is equal to(expected))
		result free()
	}
	capitalizeTest: static func (input, expected: String) {
		result := input capitalize()
		expect(result, is equal to(expected))
		result free()
	}
	reverseTest: static func (input, expected: String) {
		result := input reverse()
		expect(result, is equal to(expected))
		result free()
	}
	trimTestLeft: static func ~char (c: Char, input, expected: String) {
		result := input trimLeft(c)
		expect(result, is equal to(expected))
		result free()
	}
	trimTestLeft: static func ~string (s, input, expected: String) {
		result := input trimLeft(s)
		expect(result, is equal to(expected))
		result free()
	}
	trimTestRight: static func ~char (input: String, c: Char, expected: String) {
		result := input trimRight(c)
		expect(result, is equal to(expected))
		result free()
	}
	trimTestRight: static func ~string (input, s, expected: String) {
		result := input trimRight(s)
		expect(result, is equal to(expected))
		result free()
	}
	trimTest: static func ~char (input: String, c: Char, expected: String) {
		result := input trim(c)
		expect(result, is equal to(expected))
		result free()
	}
	trimTest: static func ~string (input, s, expected: String) {
		result := input trim(s)
		expect(result, is equal to(expected))
		result free()
	}
	findTest: static func ~Zero (input, find: String) {
		result := input _buffer findAll(find _buffer)
		expect(result count, is equal to(0))
		result free()
	}
	findTest: static func ~One (input, find: String, first: Int) {
		result := input _buffer findAll(find _buffer)
		expect(result count, is equal to(1))
		expect(result[0], is equal to(first))
		result free()
	}
	findTest: static func ~Two (input, find: String, first, second: Int) {
		result := input _buffer findAll(find _buffer)
		expect(result count, is equal to(2))
		expect(result[0], is equal to(first))
		expect(result[1], is equal to(second))
		result free()
	}
	findTest: static func ~Three (input, find: String, first, second, third: Int) {
		result := input _buffer findAll(find _buffer)
		expect(result count, is equal to(3))
		expect(result[0], is equal to(first))
		expect(result[1], is equal to(second))
		expect(result[2], is equal to(third))
		result free()
	}
}

StringTest new() run() . free()
