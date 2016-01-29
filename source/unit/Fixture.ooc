/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
import Constraints

Fixture: abstract class {
	totalTime: static Double
	exitHandlerRegistered: static Bool
	failureNames: static VectorList<String>
	name: String
	tests := VectorList<Test> new(32, false)
	init: func (=name) {
		if (!This exitHandlerRegistered) {
			This exitHandlerRegistered = true
			atexit(This printFailures)
		}
	}
	free: override func {
		this tests free()
		this name free()
		super()
	}
	add: func (test: Test) {
		this tests add(test)
	}
	add: func ~action (name: String, action: Func) {
		test := Test new(name, action)
		this add(test)
	}
	run: func -> Bool {
		failures := VectorList<TestFailedException> new(32, false)
		result := true
		dateString := DateTime now toText(t"%hh:%mm:%ss ") + Text new(this name) + t" "
		This _print(dateString)
		timer := ClockTimer new() . start()
		for (i in 0 .. this tests count) {
			test := tests[i]
			This _expectCount = 0
			r := true
			try {
				test run()
				test free()
			} catch (e: TestFailedException) {
				e message = test name
				result = r = false
				failures add(e)
			}
			This _print(r ? t"." : t"f")
		}
		if (!result) {
			if (!This failureNames)
				This failureNames = VectorList<String> new()
			This failureNames add(this name clone())
		}
		This _print(result ? t" done" : t" failed")
		testTime := timer stop() / 1000.0
		This totalTime += testTime
		timeString := testTime > 0.01 ? t" in %.2fs\n" format(testTime) : t"\n"
		This _print(timeString)
		if (!result) {
			for (i in 0 .. failures count) {
				f := failures[i]
				if (f constraint instanceOf(CompareConstraint) && f value instanceOf(Cell))
					(this createFailureMessage(f) toString()) println()
				else
					This _print(t"  -> '%s' (expect: %i)\n" format(f message, f expect))
				f free()
			}
			This _testsFailed = true
		}
		failures free()
		timer free()
		result
	}
	createFailureMessage: func (failure: TestFailedException) -> Text {
		constraint := failure constraint as CompareConstraint
		// Left is the tested value, right is the correct/expected value
		leftValue := failure value as Cell
		rightValue := constraint correct as Cell
		result := TextBuilder new(t"  -> ")
		result append(Text new(failure message))
		result append(t": expected")
		match (constraint type) {
			case ComparisonType Equal =>
				result append(t"equal to")
			case ComparisonType LessThan =>
				result append(t"less than")
			case ComparisonType GreaterThan =>
				result append(t"greater than")
			case ComparisonType Within =>
				result append(t"equal to")
		}
		result append(rightValue toText())
		result append(t"was")
		result append(leftValue toText())
		if (constraint type == ComparisonType Within)
			result append(Text new(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision)))
		result join(' ')
	}
	_testsFailed: static Bool
	_expectCount: static Int = 0
	is ::= static IsConstraints new()
	testsFailed: static Bool { get { This _testsFailed } }
	printFailures: static func {
		This _print(t"Total time: %.2f s\n" format(This totalTime))
		if (This failureNames && (This failureNames count > 0)) {
			This _print(t"Failed tests: %i [" format(This failureNames count))
			for (i in 0 .. This failureNames count - 1)
				(This failureNames[i] + ", ") print()
			(This failureNames[This failureNames count -1] + ']') println()
		}
	}
	expect: static func (value: Object, constraint: Constraint) {
		++This _expectCount
		if (!constraint verify(value))
			TestFailedException new(value, constraint, This _expectCount) throw()
		else {
			constraint free()
			if (value instanceOf(Cell))
				(value as Cell) free()
		}
	}
	expect: static func ~char (value: Char, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~text (value: Text, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~boolean (value: Bool, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~int (value: Int, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~uint (value: UInt, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~uint8 (value: Byte, constraint: Constraint) {
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
	expect: static func ~llong (value: LLong, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~ullong (value: ULLong, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	_print: static func (text: Text) {
		text print()
		fflush(stdout)
	}
}

TestFailedException: class extends Exception {
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
	free: override func {
		(this action as Closure) free()
		this name free()
		super()
	}
	run: func { this action() }
}
