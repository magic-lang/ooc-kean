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

use ooc-base
import Constraints
import structs/ArrayList

Fixture: abstract class {
	name: String
	tests := ArrayList<Test> new()
	init: func (=name)
	add: func (test: Test) {
		this tests add(test)
	}
	add: func ~action (name: String, action: Func) {
		test := Test new(name, action)
		this add(test)
	}
	run: func {
		failures := ArrayList<TestFailedException> new()
		result := true
		(this name + " ") print()
		this tests each(|test|
			r := true
			try {
				test run()
			} catch (e: TestFailedException) {
				e test = test
				e message = test name + " " + e message
				result = r = false
				failures add(e)
			}
			(r ? "." : "f") print()
		)
		(result ? " done" : " failed") println()
		if (!result)
			for (f in failures)
				"  -> '%s'" printfln(f message)
		failures free()
		exit(result ? 0 : 1)
	}
	is ::= static IsConstraints new()
	expect: static func (value: Object, constraint: Constraint, message := "") {
		if (!constraint verify(value))
			TestFailedException new(value, constraint, message) throw()
	}
	expect: static func ~text (value: Text, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~boolean (value: Bool, constraint: Constraint) {
		This expect(Cell new(value), constraint, "was #{value}")
	}
	expect: static func ~integer (value: Int, constraint: Constraint) {
		This expect(Cell new(value), constraint, "was #{value}")
	}
	expect: static func ~float (value: Float, constraint: Constraint) {
		This expect(Cell new(value), constraint, "was #{value}")
	}
	expect: static func ~double (value: Double, constraint: Constraint) {
		This expect(Cell new(value), constraint, "was #{value}")
	}
	expect: static func ~isTrue (value: Bool) {
		This expect(Cell new(value), is true, "was #{value}")
	}
}
TestFailedException: class extends Exception {
	test: Test
	value: Object
	constraint: Constraint
	init: func (=value, =constraint, message := "") {
		this message = message
	}
}
Test: class {
	name: String
	action: Func
	init: func (=name, =action)
	run: func { this action() }
}
