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
		This _print(this name + " ")
		this tests each(|test|
			This _expectCount = 0
			r := true
			try {
				test run()
			} catch (e: TestFailedException) {
				e test = test
				e message = test name
				result = r = false
				failures add(e)
			}
			This _print(r ? "." : "f")
		)
		This _print(result ? " done\n" : " failed\n")
		if (!result)
			for (f in failures) {
				// If the constraint is a CompareConstraint and the value being tested is a Cell,
				// we create a friendly message for the user.
				if (f constraint instanceOf?(CompareConstraint) && f value instanceOf?(Cell))
					(this createFailureMessage(f)) printfln()
				else
					"  -> '%s' (expect: %i)" printfln(f message, f expect)
			}
		failures free()
		exit(result ? 0 : 1)
	}
	createFailureMessage: func (failure: TestFailedException) -> String {
		constraint := failure constraint as CompareConstraint
		// Left is the tested value, right is the correct/expected value
		leftValue := failure value as Cell
		rightValue := constraint correct as Cell
		result := StringBuilder new("  -> '%s': expected" format(failure message))
		match (constraint type) {
			case ComparisonType Equal =>
				result append(" equal to")
			case ComparisonType LessThan =>
				result append(" less than")
			case ComparisonType GreaterThan =>
				result append(" greater than")
			case ComparisonType Within =>
				result append(" equal to")
		}
		result append(" '%s', was '%s'" format(rightValue toString(), leftValue toString()))
		if (constraint type == ComparisonType Within)
			result append(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision))
		result toString()
	}
	is ::= static IsConstraints new()
	_expectCount: static Int = 0
	expect: static func (value: Object, constraint: Constraint) {
		++This _expectCount
		if (!constraint verify(value))
			TestFailedException new(value, constraint, This _expectCount) throw()
	}
	expect: static func ~text (value: Text, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~boolean (value: Bool, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~integer (value: Int, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~long (value: Long, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~ulong (value: ULong, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~float (value: Float, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~double (value: Double, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~ldouble (value: LDouble, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~isTrue (value: Bool) {
		This expect(Cell new(value), is true)
	}
	_print: static func (string: String) {
		string print()
		fflush(stdout)
	}
}
TestFailedException: class extends Exception {
	test: Test
	value: Object
	constraint: Constraint
	expect: Int
	init: func (=value, =constraint, =expect, message := "") {
		this message = message
	}
}
Test: class {
	name: String
	action: Func
	init: func (=name, =action)
	run: func { this action() }
}
