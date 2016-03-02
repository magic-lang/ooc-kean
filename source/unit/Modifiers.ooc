/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Constraints

ExpectModifier: abstract class {
	parent: This = null
	child: This = null
	init: func ~parent (=parent)
	free: override func {
		if (this child) {
			if (this child parent == this)
				this child parent = null
			this child free()
		}
		if (this parent) {
			if (this parent child == this)
				this parent child = null
			this parent free()
		}
		super()
	}
	verify: func ~parent (value: Object, _child: This = null) -> Bool {
		this child = _child
		this parent != null ? this parent verify(value, this): this test(value)
	}
	test: virtual func (value: Object) -> Bool { this testChild(value) }
	testChild: func (value: Object) -> Bool { this child != null && this child test(value) }
}

EqualModifier: class extends ExpectModifier {
	comparisonType: ComparisonType
	withinType: ComparisonType
	init: func ~parent (parent: ExpectModifier, type := ComparisonType Equal) {
		super(parent)
		this comparisonType = type
		this withinType = type == ComparisonType Equal ? ComparisonType Within : ComparisonType NotWithin
	}
	to: func ~object (correct: Object) -> CompareConstraint {
		f := func (value, c: Object) -> Bool {
			match c {
				case s: String => s == value as String
				case => c == value
			}
		}
		CompareConstraint new(this, correct, f, this comparisonType)
	}
	to: func ~char (correct: Char) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Char> get() == c as Cell<Char> get() }
		CompareConstraint new(this, Cell<Char> new(correct), f, this comparisonType)
	}
	to: func ~text (correct: Text) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Text> get() == c as Cell<Text> get() }
		CompareConstraint new(this, Cell<Text> new(correct), f, this comparisonType)
	}
	to: func ~boolean (correct: Bool) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Bool> get() == c as Cell<Bool> get() }
		CompareConstraint new(this, Cell<Bool> new(correct), f, this comparisonType)
	}
	to: func ~int (correct: Int) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Int> get() == c as Cell<Int> get() }
		CompareConstraint new(this, Cell<Int> new(correct), f, this comparisonType)
	}
	to: func ~uint (correct: UInt) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<UInt> get() == c as Cell<UInt> get() }
		CompareConstraint new(this, Cell<UInt> new(correct), f, this comparisonType)
	}
	to: func ~uint8 (correct: Byte) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Byte> get() == c as Cell<Byte> get() }
		CompareConstraint new(this, Cell<Byte> new(correct), f, this comparisonType)
	}
	to: func ~long (correct: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Long> get() == c as Cell<Long> get() }
		CompareConstraint new(this, Cell<Long> new(correct), f, this comparisonType)
	}
	to: func ~ulong (correct: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<ULong> get() == c as Cell<ULong> get() }
		CompareConstraint new(this, Cell<ULong> new(correct), f, this comparisonType)
	}
	to: func ~float (correct: Float) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Float> get() == c as Cell<Float> get() }
		CompareWithinConstraint new(this, Cell<Float> new(correct), f, this withinType)
	}
	to: func ~double (correct: Double) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Double> get() == c as Cell<Double> get() }
		CompareWithinConstraint new(this, Cell<Double> new(correct), f, this withinType)
	}
	to: func ~ldouble (correct: LDouble) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<LDouble> get() == c as Cell<LDouble> get() }
		CompareWithinConstraint new(this, Cell<LDouble> new(correct), f, this withinType)
	}
	to: func ~llong (correct: LLong) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<LLong> get() == c as Cell<LLong> get() }
		CompareWithinConstraint new(this, Cell<LLong> new(correct), f, this withinType)
	}
	to: func ~ullong (correct: ULLong) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<ULLong> get() == c as Cell<ULLong> get() }
		CompareWithinConstraint new(this, Cell<ULLong> new(correct), f, this withinType)
	}
}

LessModifier: class extends ExpectModifier {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	than: func ~object (right: Object) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value < c }
		CompareConstraint new(this, right, f, ComparisonType LessThan)
	}
	than: func ~float (right: Float) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Float> get()) < (c as Cell<Float> get()) }
		CompareConstraint new(this, Cell<Float> new(right), f, ComparisonType LessThan)
	}
	than: func ~double (right: Double) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Double> get()) < (c as Cell<Double> get()) }
		CompareConstraint new(this, Cell<Double> new(right), f, ComparisonType LessThan)
	}
	than: func ~ldouble (right: LDouble) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<LDouble> get()) < (c as Cell<LDouble> get()) }
		CompareConstraint new(this, Cell<LDouble> new(right), f, ComparisonType LessThan)
	}
	than: func ~int (right: Int) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Int> get()) < (c as Cell<Int> get()) }
		CompareConstraint new(this, Cell<Int> new(right), f, ComparisonType LessThan)
	}
	than: func ~uint (right: UInt) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<UInt> get()) < (c as Cell<UInt> get()) }
		CompareConstraint new(this, Cell<UInt> new(right), f, ComparisonType LessThan)
	}
	than: func ~long (right: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Long> get()) < (c as Cell<Long> get()) }
		CompareConstraint new(this, Cell<Long> new(right), f, ComparisonType LessThan)
	}
	than: func ~ulong (right: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULong> get()) < (c as Cell<ULong> get()) }
		CompareConstraint new(this, Cell<ULong> new(right), f, ComparisonType LessThan)
	}
	than: func ~llong (right: LLong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<LLong> get()) < (c as Cell<LLong> get()) }
		CompareConstraint new(this, Cell<LLong> new(right), f, ComparisonType LessThan)
	}
	than: func ~ullong (right: ULLong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULLong> get()) < (c as Cell<ULLong> get()) }
		CompareConstraint new(this, Cell<ULLong> new(right), f, ComparisonType LessThan)
	}
}

GreaterModifier: class extends ExpectModifier {
	init: func ~parent (parent: ExpectModifier) { super(parent) }
	than: func ~object (right: Object) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value > c }
		CompareConstraint new(this, right, f, ComparisonType GreaterThan)
	}
	than: func ~float (right: Float) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Float> get()) > (c as Cell<Float> get()) }
		CompareConstraint new(this, Cell<Float> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~double (right: Double) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Double> get()) > (c as Cell<Double> get()) }
		CompareConstraint new(this, Cell<Double> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~ldouble (right: LDouble) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<LDouble> get()) > (c as Cell<LDouble> get()) }
		CompareConstraint new(this, Cell<LDouble> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~int (right: Int) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Int> get()) > (c as Cell<Int> get()) }
		CompareConstraint new(this, Cell<Int> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~uint (right: UInt) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<UInt> get()) > (c as Cell<UInt> get()) }
		CompareConstraint new(this, Cell<UInt> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~long (right: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Long> get()) > (c as Cell<Long> get()) }
		CompareConstraint new(this, Cell<Long> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~ulong (right: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULong> get()) > (c as Cell<ULong> get()) }
		CompareConstraint new(this, Cell<ULong> new(right), f, ComparisonType GreaterThan)
	}
	than: func ~llong (right: LLong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<LLong> get()) > (c as Cell<LLong> get()) }
		CompareConstraint new(this, Cell<LLong> new(right), f, ComparisonType LessThan)
	}
	than: func ~ullong (right: ULLong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULLong> get()) > (c as Cell<ULLong> get()) }
		CompareConstraint new(this, Cell<ULLong> new(right), f, ComparisonType LessThan)
	}
}
