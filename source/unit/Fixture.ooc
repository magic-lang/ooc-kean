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
	_previousDebugFunc: Func (String)
	_hasPreviousDebugFunc := false

	init: func (=name)
	free: override func {
		(this tests, this name) free()
		if (this _hasPreviousDebugFunc)
			Debug initialize(this _previousDebugFunc)
		super()
	}
	add: func ~action (name: String, action: Func) {
		this tests add(Test new(name, action))
	}
	run: func -> Bool {
		failures := VectorList<TestFailedException> new(32, false)
		result := true
		This _print((DateTime now toString("%hh:%mm:%ss ") >> this name) >> " ", true)
		timer := WallTimer new() . start()
		for (i in 0 .. this tests count) {
			test := this tests[i]
			r := true
			try {
				test run()
				test free()
			} catch (e: TestFailedException) {
				e message = e description != null ? ((test name >> " (") >> e description) >> ")" : test name
				result = r = false
				failures add(e)
			}
			This _print(r ? "." : "f")
		}
		if (!result) {
			if (!This failureNames)
				This failureNames = VectorList<String> new()
			This failureNames add(this name clone())
		}
		This _print(result ? " done" : " failed")
		testTime := timer stop() toMilliseconds() / 1000.f
		This totalTime += testTime
		if (testTime > 0.1)
			This _print(" in %.2fs" format(testTime), true)
		This _print("\n")
		if (!result) {
			for (i in 0 .. failures count) {
				f := failures[i]
				if (f constraint instanceOf(CompareConstraint) && f value instanceOf(Cell))
					This _print(this createCompareFailureMessage(f) >> "\n", true)
				else if (f constraint instanceOf(CompareConstraint) && f value instanceOf(String))
					This _print("  -> %s : expected equal to \"%s\" was \"%s\"\n" format(f message, (f constraint as CompareConstraint) correct as String, f value as String), true)
				else if (f constraint instanceOf(NullConstraint))
					This _print("  -> %s : expected null was %p\n" format(f message, f value&), true)
				else if (f constraint instanceOf(NotNullConstraint))
					This _print("  -> %s : expected not null was null\n" format(f message), true)
				else if (f constraint instanceOf(TrueConstraint))
					This _print("  -> %s : expected true was false\n" format(f message), true)
				else if (f constraint instanceOf(FalseConstraint))
					This _print("  -> %s : expected false was true\n" format(f message), true)
				else if (f constraint instanceOf(RangeConstraint))
					This _print(this createRangeFailureMessage(f) >> "\n", true)
				else
					This _print("  -> %s\n" format(f message), true)
				f free()
			}
			This _testsFailed = true
		}
		(failures, timer) free()
		result
	}
	createCompareFailureMessage: func (failure: TestFailedException) -> String {
		constraint := failure constraint as CompareConstraint
		(testedValue, expectedValue) := (failure value as Cell, constraint correct as Cell)
		result := StringBuilder new() . add("  ->") . add(failure message) . add(": expected")
		match (constraint type) {
			case ComparisonType Equal => result add("equal to")
			case ComparisonType NotEqual => result add("not equal to")
			case ComparisonType LessThan => result add("less than")
			case ComparisonType GreaterThan => result add("greater than")
			case ComparisonType LessOrEqual => result add("less than or equal to")
			case ComparisonType GreaterOrEqual => result add("greater than or equal to")
			case ComparisonType Within => result add("equal to")
			case ComparisonType NotWithin => result add("not equal to")
		}
		expectedText, testedText: String
		match (expectedValue T) {
			case FloatVector2D => (expectedText, testedText) = (expectedValue toString~floatvector2d(), testedValue toString~floatvector2d())
			case FloatVector3D => (expectedText, testedText) = (expectedValue toString~floatvector3d(), testedValue toString~floatvector3d())
			case FloatPoint2D => (expectedText, testedText) = (expectedValue toString~floatpoint2d(), testedValue toString~floatpoint2d())
			case FloatPoint3D => (expectedText, testedText) = (expectedValue toString~floatpoint3d(), testedValue toString~floatpoint3d())
			case Quaternion => (expectedText, testedText) = (expectedValue toString~quaternion(), testedValue toString~quaternion())
			case FloatEuclidTransform => (expectedText, testedText) = (expectedValue toString~floateuclidtransform(), testedValue toString~floateuclidtransform())
			case FloatRotation3D => (expectedText, testedText) = (expectedValue toString~floatrotation3d(), testedValue toString~floatrotation3d())
			case FloatTransform2D => (expectedText, testedText) = (expectedValue toString~floattransform2d(), testedValue toString~floattransform2d())
			case FloatTransform3D => (expectedText, testedText) = (expectedValue toString~floattransform3d(), testedValue toString~floattransform3d())
			case IntVector2D => (expectedText, testedText) = (expectedValue toString~intvector2d(), testedValue toString~intvector2d())
			case IntVector3D => (expectedText, testedText) = (expectedValue toString~intvector3d(), testedValue toString~intvector3d())
			case IntPoint2D => (expectedText, testedText) = (expectedValue toString~intpoint2d(), testedValue toString~intpoint2d())
			case IntPoint3D => (expectedText, testedText) = (expectedValue toString~intpoint3d(), testedValue toString~intpoint3d())
			case FloatComplex => (expectedText, testedText) = (expectedValue toString~floatcomplex(), testedValue toString~floatcomplex())
			case FloatMatrix => (expectedText, testedText) = (expectedValue toString~floatmatrix(), testedValue toString~floatmatrix())
			case FloatBox2D => (expectedText, testedText) = (expectedValue toString~floatbox2d(), testedValue toString~floatbox2d())
			case IntBox2D => (expectedText, testedText) = (expectedValue toString~intbox2d(), testedValue toString~intbox2d())
			case FloatShell2D => (expectedText, testedText) = (expectedValue toString~floatshell2d(), testedValue toString~floatshell2d())
			case IntShell2D => (expectedText, testedText) = (expectedValue toString~intshell2d(), testedValue toString~intshell2d())
			case => (expectedText, testedText) = (expectedValue toString(), testedValue toString())
		}
		result add(expectedText) . add("was") . add(testedText)
		if (constraint type == ComparisonType Within)
			result add(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision))
		result join(" ")
	}
	createRangeFailureMessage: func (failure: TestFailedException) -> String {
		constraint := failure constraint as RangeConstraint
		testedValue := failure value as Cell
		result := StringBuilder new() . add("  ->") . add(failure message) . add(": expected within")
		match (constraint type) {
			case 0 => result add(constraint intMin toString()) . add("and") . add(constraint intMax toString())
			case 1 => result add(constraint floatMin toString()) . add("and") . add(constraint floatMax toString())
		}
		result add("was") . add(testedValue toString())
		result join(' ')
	}
	hideDebugOutput: func {
		this _hasPreviousDebugFunc = true
		this _previousDebugFunc = Debug _printFunction
		Debug initialize(func (s: String) { })
	}

	_testsFailed: static Bool
	totalTime: static Double
	failureNames: static VectorList<String>
	testsFailed ::= static This _testsFailed

	printFailures: static func {
		This _print("Total time: %.2f s\n" format(This totalTime), true)
		if (This failureNames && (This failureNames count > 0)) {
			This _print("Failed tests: %i [" format(This failureNames count), true)
			for (i in 0 .. This failureNames count - 1)
				(This failureNames[i] + ", ") print()
			(This failureNames[This failureNames count -1] + ']') println()
		}
	}
	_print: static func (message: String, free := false) {
		message print()
		fflush(stdout)
		if (free)
			message free()
	}
	verify: static func (value: Object, constraint: ExpectModifier, description: String = null) {
		if (!constraint verify(value))
			TestFailedException new(value, constraint, description) throw()
		else {
			constraint free()
			if (value instanceOf(Cell))
				(value as Cell) free()
		}
	}
}

TestFailedException: class extends Exception {
	description: String
	value: Object
	constraint: ExpectModifier
	init: func (=value, =constraint, =description) { super(null as String) }
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

expect: func ~isTrue (value: Bool, message: String = null) { Fixture verify(Cell new(value), is true, message) }
expect: func ~object (value: Object, constraint: ExpectModifier, message: String = null) { Fixture verify(value, constraint, message) }
expect: func ~char (value: Char, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~boolean (value: Bool, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~int (value: Int, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~uint (value: UInt, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~uint8 (value: Byte, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~long (value: Long, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~ulong (value: ULong, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~float (value: Float, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~double (value: Double, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~ldouble (value: LDouble, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~llong (value: LLong, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~ullong (value: ULLong, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }

expect: func ~floatvector2d (value: FloatVector2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatvector3d (value: FloatVector3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatpoint2d (value: FloatPoint2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatpoint3d (value: FloatPoint3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~quaternion (value: Quaternion, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floateuclidtransform (value: FloatEuclidTransform, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatrotation3d (value: FloatRotation3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floattransform2d (value: FloatTransform2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floattransform3d (value: FloatTransform3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intvector2d (value: IntVector2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intvector3d (value: IntVector3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intpoint2d (value: IntPoint2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intpoint3d (value: IntPoint3D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatcomplex (value: FloatComplex, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatmatrix (value: FloatMatrix, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatbox2d (value: FloatBox2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intbox2d (value: IntBox2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~floatshell2d (value: FloatShell2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
expect: func ~intshell2d (value: IntShell2D, constraint: ExpectModifier, message: String = null) { Fixture verify(Cell new(value), constraint, message) }
