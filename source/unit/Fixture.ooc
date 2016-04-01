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

	init: func (=name)
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
			test := this tests[i]
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
				else if (f constraint instanceOf(RangeConstraint))
					This _print(this createRangeFailureMessage(f) + t"\n")
				else
					This _print(t"  -> %s\n" format(f message))
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
			case FloatComplex => (expectedText, testedText) = (expectedValue toText~floatcomplex(), testedValue toText~floatcomplex())
			case FloatMatrix => (expectedText, testedText) = (expectedValue toText~floatmatrix(), testedValue toText~floatmatrix())
			case IntTransform2D => (expectedText, testedText) = (expectedValue toText~inttransform2d(), testedValue toText~inttransform2d())
			case FloatBox2D => (expectedText, testedText) = (expectedValue toText~floatbox2d(), testedValue toText~floatbox2d())
			case IntBox2D => (expectedText, testedText) = (expectedValue toText~intbox2d(), testedValue toText~intbox2d())
			case FloatShell2D => (expectedText, testedText) = (expectedValue toText~floatshell2d(), testedValue toText~floatshell2d())
			case IntShell2D => (expectedText, testedText) = (expectedValue toText~intshell2d(), testedValue toText~intshell2d())
			case => (expectedText, testedText) = (expectedValue toText(), testedValue toText())
		}
		result append(expectedText) . append(t"was") . append(testedText)
		if (constraint type == ComparisonType Within)
			result append(Text new(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision)))
		result join(' ')
	}
	createRangeFailureMessage: func (failure: TestFailedException) -> Text {
		constraint := failure constraint as RangeConstraint
		testedValue := failure value as Cell
		result := TextBuilder new(t"  ->")
		result append(Text new(failure message))
		result append(t": expected within")
		match (constraint type) {
			case 0 => result append(constraint intMin toText()) . append(t"and") . append(constraint intMax toText())
			case 1 => result append(constraint floatMin toText()) . append(t"and") . append(constraint floatMax toText())
		}
		result append(t"was")
		result append(testedValue toText())
		result join(' ')
	}

	_testsFailed: static Bool
	totalTime: static Double
	failureNames: static VectorList<String>
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
	verify: static func (value: Object, constraint: ExpectModifier) {
		if (!constraint verify(value))
			TestFailedException new(value, constraint) throw()
		else {
			constraint free()
			if (value instanceOf(Cell))
				(value as Cell) free()
		}
	}
}

TestFailedException: class extends Exception {
	value: Object
	constraint: ExpectModifier
	init: func (=value, =constraint, message := "") { super(message) }
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

expect: func ~isTrue (value: Bool) { Fixture verify(Cell new(value), is true) }
expect: func ~object (value: Object, constraint: ExpectModifier) { Fixture verify(value, constraint) }
expect: func ~char (value: Char, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~text (value: Text, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~boolean (value: Bool, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~int (value: Int, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~uint (value: UInt, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~uint8 (value: Byte, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~long (value: Long, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~ulong (value: ULong, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~float (value: Float, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~double (value: Double, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~ldouble (value: LDouble, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~llong (value: LLong, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~ullong (value: ULLong, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }

expect: func ~floatvector2d (value: FloatVector2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatvector3d (value: FloatVector3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatpoint2d (value: FloatPoint2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatpoint3d (value: FloatPoint3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~quaternion (value: Quaternion, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floateuclidtransform (value: FloatEuclidTransform, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatrotation3d (value: FloatRotation3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floattransform2d (value: FloatTransform2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floattransform3d (value: FloatTransform3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intvector2d (value: IntVector2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intvector3d (value: IntVector3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intpoint2d (value: IntPoint2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intpoint3d (value: IntPoint3D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatcomplex (value: FloatComplex, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatmatrix (value: FloatMatrix, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~inttransform2d (value: IntTransform2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatbox2d (value: FloatBox2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intbox2d (value: IntBox2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~floatshell2d (value: FloatShell2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
expect: func ~intshell2d (value: IntShell2D, constraint: ExpectModifier) { Fixture verify(Cell new(value), constraint) }
