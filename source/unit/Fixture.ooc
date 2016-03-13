/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use geometry
use math
import Constraints
import Modifiers

Fixture: abstract class {
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
	add: func ~action (name: String, action: Func) {
		this tests add(Test new(name, action))
	}
	run: func -> Bool {
		failures := VectorList<TestFailedException> new(32, false)
		result := true
		dateString := DateTime now toText(t"%hh:%mm:%ss ") + Text new(this name) + t" "
		This _print(dateString)
		timer := WallTimer new() . start()
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
		testTime := timer stop() / 1_000_000.0
		This totalTime += testTime
		timeString := testTime > 0.1 ? t" in %.2fs\n" format(testTime) : t"\n"
		This _print(timeString)
		if (!result) {
			for (i in 0 .. failures count) {
				f := failures[i]
				if (f constraint instanceOf(CompareConstraint) && f value instanceOf(Cell))
					This _print(this createCompareFailureMessage(f) + t"\n")
				else if (f constraint instanceOf(NullConstraint))
					This _print(Text new("  -> %s : expected null was %p\n" format(f message, f value&)))
				else if (f constraint instanceOf(NotNullConstraint))
					This _print(Text new("  -> %s : expected not null was null\n" format(f message)))
				else if (f constraint instanceOf(TrueConstraint))
					This _print(Text new("  -> %s : expected true was false\n" format(f message)))
				else if (f constraint instanceOf(FalseConstraint))
					This _print(Text new("  -> %s : expected false was true\n" format(f message)))
				else
					This _print(t"  -> %s (expect: %i)\n" format(f message, f expect))
				f free()
			}
			This _testsFailed = true
		}
		failures free()
		timer free()
		result
	}
	createCompareFailureMessage: func (failure: TestFailedException) -> Text {
		constraint := failure constraint as CompareConstraint
		(testedValue, expectedValue) := (failure value as Cell, constraint correct as Cell)
		result := TextBuilder new(t"  ->")
		result append(Text new(failure message))
		result append(t": expected")
		match (constraint type) {
			case ComparisonType Equal => result append(t"equal to")
			case ComparisonType NotEqual => result append(t"not equal to")
			case ComparisonType LessThan => result append(t"less than")
			case ComparisonType GreaterThan => result append(t"greater than")
			case ComparisonType LessOrEqual => result append(t"less than or equal to")
			case ComparisonType GreaterOrEqual => result append(t"greater than or equal to")
			case ComparisonType Within => result append(t"equal to")
			case ComparisonType NotWithin => result append(t"not equal to")
		}
		expectedText, testedText: Text
		match (expectedValue T) {
			case FloatVector2D => (expectedText, testedText) = (expectedValue toText~floatvector2d(), testedValue toText~floatvector2d())
			case FloatVector3D => (expectedText, testedText) = (expectedValue toText~floatvector3d(), testedValue toText~floatvector3d())
			case FloatPoint2D => (expectedText, testedText) = (expectedValue toText~floatpoint2d(), testedValue toText~floatpoint2d())
			case FloatPoint3D => (expectedText, testedText) = (expectedValue toText~floatpoint3d(), testedValue toText~floatpoint3d())
			case Quaternion => (expectedText, testedText) = (expectedValue toText~quaternion(), testedValue toText~quaternion())
			case FloatEuclidTransform => (expectedText, testedText) = (expectedValue toText~floateuclidtransform(), testedValue toText~floateuclidtransform())
			case FloatRotation3D => (expectedText, testedText) = (expectedValue toText~floatrotation3d(), testedValue toText~floatrotation3d())
			case FloatTransform2D => (expectedText, testedText) = (expectedValue toText~floattransform2d(), testedValue toText~floattransform2d())
			case FloatTransform3D => (expectedText, testedText) = (expectedValue toText~floattransform3d(), testedValue toText~floattransform3d())
			case IntVector2D => (expectedText, testedText) = (expectedValue toText~intvector2d(), testedValue toText~intvector2d())
			case IntVector3D => (expectedText, testedText) = (expectedValue toText~intvector3d(), testedValue toText~intvector3d())
			case IntPoint2D => (expectedText, testedText) = (expectedValue toText~intpoint2d(), testedValue toText~intpoint2d())
			case IntPoint3D => (expectedText, testedText) = (expectedValue toText~intpoint3d(), testedValue toText~intpoint3d())
			case => (expectedText, testedText) = (expectedValue toText(), testedValue toText())
		}
		result append(expectedText) . append(t"was") . append(testedText)
		if (constraint type == ComparisonType Within)
			result append(Text new(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision)))
		result join(' ')
	}

	_testsFailed: static Bool
	_expectCount: static Int = 0
	totalTime: static Double
	exitHandlerRegistered: static Bool
	failureNames: static VectorList<String>
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
	_print: static func (text: Text) {
		text print()
		fflush(stdout)
	}
	expect: static func (value: Object, constraint: Constraint) {
		This _expectCount += 1
		if (!constraint verify(value))
			TestFailedException new(value, constraint, This _expectCount) throw()
		else {
			constraint free()
			if (value instanceOf(Cell))
				(value as Cell) free()
		}
	}
	expect: static func ~isTrue (value: Bool) { This expect(Cell new(value), is true) }
	expect: static func ~char (value: Char, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~text (value: Text, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~boolean (value: Bool, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~int (value: Int, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~uint (value: UInt, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~uint8 (value: Byte, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~long (value: Long, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~ulong (value: ULong, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~float (value: Float, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~double (value: Double, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~ldouble (value: LDouble, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~llong (value: LLong, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~ullong (value: ULLong, constraint: Constraint) { This expect(Cell new(value), constraint) }

	expect: static func ~floatvector2d (value: FloatVector2D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floatvector3d (value: FloatVector3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floatpoint2d (value: FloatPoint2D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floatpoint3d (value: FloatPoint3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~quaternion (value: Quaternion, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floateuclidtransform (value: FloatEuclidTransform, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floatrotation3d (value: FloatRotation3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floattransform2d (value: FloatTransform2D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~floattransform3d (value: FloatTransform3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~intvector2d (value: IntVector2D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~intvector3d (value: IntVector3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~intpoint2d (value: IntPoint2D, constraint: Constraint) { This expect(Cell new(value), constraint) }
	expect: static func ~intpoint3d (value: IntPoint3D, constraint: Constraint) { This expect(Cell new(value), constraint) }
}

TestFailedException: class extends Exception {
	value: Object
	constraint: Constraint
	expect: Int
	init: func (=value, =constraint, =expect, message := "") { super(message) }
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
