/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use math
import Modifiers

ComparisonType: enum {
	Unspecified
	Equal
	NotEqual
	LessThan
	LessOrEqual
	GreaterThan
	GreaterOrEqual
	Within
	NotWithin
}

IsConstraints: class extends ExpectModifier {
	true ::= TrueConstraint new(this)
	false ::= FalseConstraint new(this)
	Null ::= NullConstraint new(this)
	notNull ::= NotNullConstraint new(this)
	equal ::= EqualModifier new(this)
	notEqual ::= EqualModifier new(this, ComparisonType NotEqual)
	less ::= LessModifier new(this)
	lessOrEqual ::= LessModifier new(this, true)
	greater ::= GreaterModifier new(this)
	greaterOrEqual ::= GreaterModifier new(this, true)
	init: func
	within: func ~range (range: Range) -> RangeConstraint { RangeConstraint new(this, range) }
	within: func ~int (min, max: Int) -> RangeConstraint { RangeConstraint new(this, min, max) }
	within: func ~float (min, max: Float) -> RangeConstraint { RangeConstraint new(this, min, max) }
}

Constraint: abstract class extends ExpectModifier {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
}

TrueConstraint: class extends Constraint {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	test: override func (value: Object) -> Bool { value as Cell<Bool> get() }
}

FalseConstraint: class extends Constraint {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	test: override func (value: Object) -> Bool { !value as Cell<Bool> get() }
}

NullConstraint: class extends Constraint {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	test: override func (value: Object) -> Bool { value == null }
}

NotNullConstraint: class extends Constraint {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	test: override func (value: Object) -> Bool { value != null }
}

RangeConstraint: class extends Constraint {
	type := -1
	intMin, intMax: Int
	floatMin, floatMax: Float
	init: func ~range (parent: ExpectModifier, range: Range) {
		super(parent)
		(this intMin, this intMax, this type) = (range min, range max, 0)
	}
	init: func ~int (parent: ExpectModifier, min, max: Int) {
		super(parent)
		(this intMin, this intMax, this type) = (min, max, 0)
	}
	init: func ~float (parent: ExpectModifier, min, max: Float) {
		super(parent)
		(this floatMin, this floatMax, this type) = (min, max, 1)
	}
	test: override func (value: Object) -> Bool {
		testValue, compareMin, compareMax: Double
		match ((value as Cell) T) {
			case Float =>
				temp := (value as Cell<Float>) get()
				testValue = temp as Double
			case Int =>
				temp := (value as Cell<Int>) get()
				testValue = temp as Double
			case =>
				raise("Unknown type used with 'is within()'!")
		}
		match (this type) {
			case 0 => (compareMin, compareMax) = (this intMin as Double, this intMax as Double)
			case 1 => (compareMin, compareMax) = (this floatMin as Double, this floatMax as Double)
			case => raise("Unknown type used with 'is within()'!")
		}
		testValue >= compareMin && testValue < compareMax
	}
}

CompareConstraint: class extends Constraint {
	comparer: Func (Object, Object) -> Bool
	correct: Object
	type: ComparisonType
	init: func (parent: ExpectModifier, =correct, =comparer, type := ComparisonType Unspecified) {
		super(parent)
		this type = type
	}
	free: override func {
		if (this correct instanceOf(Cell))
			(this correct as Cell) free()
		(this comparer as Closure) free()
		super()
	}
	test: override func (value: Object) -> Bool {
		result := this comparer(value, this correct)
		this type == ComparisonType NotEqual ? !result : result
	}
}

CompareWithinConstraint: class extends CompareConstraint {
	actualType: Class
	precision: LDouble = -1.0L
	init: func (parent: ExpectModifier, .correct, .comparer, compareType := ComparisonType Within, =actualType) {
		super(parent, correct, comparer, compareType)
	}
	within: func ~float (precision: Float) -> CompareConstraint {
		this precision = precision as LDouble
		this _within()
	}
	within: func ~double (precision: Double) -> CompareConstraint {
		this precision = precision as Double
		this _within()
	}
	within: func ~ldouble (=precision) -> CompareConstraint {
		this _within()
	}
	_within: func -> CompareConstraint {
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		result: CompareConstraint
		match (this actualType) {
			case Float =>
				f := func (value, correct: Cell<Float>) -> Bool { correct get() equals(value get(), this precision) }
				result = CompareConstraint new(this, Cell<Float> new(this correct as Cell<Float> get()), f, this type)
			case Double =>
				f := func (value, correct: Cell<Double>) -> Bool { correct get() equals(value get(), this precision) }
				result = CompareConstraint new(this, Cell<Double> new(this correct as Cell<Double> get()), f, this type)
			case LDouble =>
				f := func (value, correct: Cell<LDouble>) -> Bool { correct get() equals(value get(), this precision) }
				result = CompareConstraint new(this, Cell<LDouble> new(this correct as Cell<LDouble> get()), f, this type)
			case FloatVector2D =>
				f := func (value, correct: Cell<FloatVector2D>) -> Bool { correct get() distance(value get()) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<FloatVector2D> new(this correct as Cell<FloatVector2D> get()), f, this type)
			case FloatVector3D =>
				f := func (value, correct: Cell<FloatVector3D>) -> Bool { correct get() distance(value get()) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<FloatVector3D> new(this correct as Cell<FloatVector3D> get()), f, this type)
			case FloatPoint2D =>
				f := func (value, correct: Cell<FloatPoint2D>) -> Bool { correct get() distance(value get()) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<FloatPoint2D> new(this correct as Cell<FloatPoint2D> get()), f, this type)
			case FloatPoint3D =>
				f := func (value, correct: Cell<FloatPoint3D>) -> Bool { correct get() distance(value get()) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<FloatPoint3D> new(this correct as Cell<FloatPoint3D> get()), f, this type)
			case Quaternion =>
				f := func (value, correct: Cell<Quaternion>) -> Bool { correct get() distance(value get()) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<Quaternion> new(this correct as Cell<Quaternion> get()), f, this type)
			case FloatRotation3D =>
				f := func (value, correct: Cell<FloatRotation3D>) -> Bool { correct get() _quaternion distance(value get() _quaternion) equals(0.f, this precision) }
				result = CompareConstraint new(this, Cell<FloatRotation3D> new(this correct as Cell<FloatRotation3D> get()), f, this type)
			case =>
				raise("Using within() for incompatible type %s in test!" format(this actualType name))
		}
		result
	}
	test: override func (value: Object) -> Bool {
		comparer := this comparer
		result := comparer(value, this correct)
		this type == ComparisonType NotWithin ? !result : result
	}
}
