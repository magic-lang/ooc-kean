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

use base

ComparisonType: enum {
	Unspecified
	Equal
	LessThan
	GreaterThan
	Within
}

Modifier: abstract class {
	parent: This = null
	child: This = null
	init: func
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
	verify: func ~parent (value: Object, =child) -> Bool {
		this parent != null ? this parent verify(value, this): this test(value)
	}
	verify: func (value: Object) -> Bool {
		this verify(value, null)
	}
	test: virtual func (value: Object) -> Bool {
		this testChild(value)
	}
	testChild: func (value: Object) -> Bool {
		this child != null && this child test(value)
	}
}

Constraint: abstract class extends Modifier {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
}

TrueConstraint: class extends Constraint {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		value as Cell<Bool> get()
	}
}

FalseConstraint: class extends Constraint {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		!value as Cell<Bool> get()
	}
}

NullConstraint: class extends Constraint {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		value == null
	}
}

EmptyConstraint: class extends Constraint {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		value != null && value instanceOf?(String) && value as String empty()
	}
}

NotModifier: class extends Modifier {
	true ::= TrueConstraint new(this)
	false ::= FalseConstraint new(this)
	Null ::= NullConstraint new(this)
	empty ::= EmptyConstraint new(this)
	not ::= This new(this)
	equal ::= EqualModifier new(this)
	less ::= LessModifier new()
	greater ::= GreaterModifier new()
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		!(this testChild(value))
	}
}

EqualModifier: class extends Modifier {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	to: func ~object (correct: Object) -> CompareConstraint {
		f := func (value, c: Object) -> Bool {
			match c {
				case s: String => s == value as String
				case => c == value
			}
		}
		CompareConstraint new(this, correct, f, ComparisonType Equal)
	}
	to: func ~char (correct: Char) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Char> get() == c as Cell<Char> get() }
		CompareConstraint new(this, Cell<Char> new(correct), f, ComparisonType Equal)
	}
	to: func ~text (correct: Text) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Text> get() == c as Cell<Text> get() }
		CompareConstraint new(this, Cell<Text> new(correct), f, ComparisonType Equal)
	}
	to: func ~boolean (correct: Bool) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Bool> get() == c as Cell<Bool> get() }
		CompareConstraint new(this, Cell<Bool> new(correct), f, ComparisonType Equal)
	}
	to: func ~int (correct: Int) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Int> get() == c as Cell<Int> get() }
		CompareConstraint new(this, Cell<Int> new(correct), f, ComparisonType Equal)
	}
	to: func ~uint (correct: UInt) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<UInt> get() == c as Cell<UInt> get() }
		CompareConstraint new(this, Cell<UInt> new(correct), f, ComparisonType Equal)
	}
	to: func ~uint8 (correct: Byte) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Byte> get() == c as Cell<Byte> get() }
		CompareConstraint new(this, Cell<Byte> new(correct), f, ComparisonType Equal)
	}
	to: func ~long (correct: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Long> get() == c as Cell<Long> get() }
		CompareConstraint new(this, Cell<Long> new(correct), f, ComparisonType Equal)
	}
	to: func ~ulong (correct: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<ULong> get() == c as Cell<ULong> get() }
		CompareConstraint new(this, Cell<ULong> new(correct), f, ComparisonType Equal)
	}
	to: func ~float (correct: Float) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Float> get() == c as Cell<Float> get() }
		CompareWithinConstraint new(this, Cell<Float> new(correct), f)
	}
	to: func ~double (correct: Double) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Double> get() == c as Cell<Double> get() }
		CompareWithinConstraint new(this, Cell<Double> new(correct), f)
	}
	to: func ~ldouble (correct: LDouble) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<LDouble> get() == c as Cell<LDouble> get() }
		CompareWithinConstraint new(this, Cell<LDouble> new(correct), f)
	}
	to: func ~int64 (correct: Long) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Long> get() == c as Cell<Long> get() }
		CompareWithinConstraint new(this, Cell<Long> new(correct), f)
	}
	to: func ~uint64 (correct: ULong) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<ULong> get() == c as Cell<ULong> get() }
		CompareWithinConstraint new(this, Cell<ULong> new(correct), f)
	}
}

LessModifier: class extends Modifier {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
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
	than: func ~int64 (right: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Long> get()) < (c as Cell<Long> get()) }
		CompareConstraint new(this, Cell<Long> new(right), f, ComparisonType LessThan)
	}
	than: func ~uint64 (right: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULong> get()) < (c as Cell<ULong> get()) }
		CompareConstraint new(this, Cell<ULong> new(right), f, ComparisonType LessThan)
	}
}

GreaterModifier: class extends Modifier {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
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
	than: func ~int64 (right: Long) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<Long> get()) > (c as Cell<Long> get()) }
		CompareConstraint new(this, Cell<Long> new(right), f, ComparisonType LessThan)
	}
	than: func ~uint64 (right: ULong) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { (value as Cell<ULong> get()) > (c as Cell<ULong> get()) }
		CompareConstraint new(this, Cell<ULong> new(right), f, ComparisonType LessThan)
	}
}

CompareConstraint: class extends Constraint {
	comparer: Func (Object, Object) -> Bool
	correct: Object
	type: ComparisonType
	init: func (parent: Modifier, =correct, =comparer, type := ComparisonType Unspecified) {
		super(parent)
		this type = type
	}
	free: override func {
		if (this correct instanceOf?(Cell))
			(this correct as Cell) free()
		(this comparer as Closure) free()
		super()
	}
	test: override func (value: Object) -> Bool {
		this comparer(value, this correct)
	}
}

CompareWithinConstraint: class extends CompareConstraint {
	precision: LDouble
	init: func (parent: Modifier, .correct, .comparer) {
		super(parent, correct, comparer, ComparisonType Equal)
	}
	within: func ~float (precision: Float) -> CompareConstraint {
		this precision = precision as LDouble
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		f := func (value, correct: Object) -> Bool { (value as Cell<Float> get() - correct as Cell<Float> get()) abs() < precision }
		CompareConstraint new(this, Cell<Float> new(this correct as Cell<Float> get()), f, ComparisonType Within)
	}
	within: func ~double (precision: Double) -> CompareConstraint {
		this precision = precision as Double
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		f := func (value, correct: Object) -> Bool { (value as Cell<Double> get() - correct as Cell<Double> get()) abs() < precision }
		CompareConstraint new(this, Cell<Double> new(this correct as Cell<Double> get()), f, ComparisonType Within)
	}
	within: func ~ldouble (=precision) -> CompareConstraint {
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		f := func (value, correct: Object) -> Bool { (value as Cell<LDouble> get() - correct as Cell<LDouble> get()) abs() < precision }
		CompareConstraint new(this, Cell<LDouble> new(this correct as Cell<LDouble> get()), f, ComparisonType Within)
	}
	test: override func (value: Object) -> Bool {
		comparer := this comparer
		comparer(value, this correct)
	}
}

IsConstraints: class extends Modifier {
	true ::= TrueConstraint new(this)
	false ::= FalseConstraint new(this)
	Null ::= NullConstraint new(this)
	empty ::= EmptyConstraint new(this)
	not ::= NotModifier new(this)
	equal ::= EqualModifier new(this)
	less ::= LessModifier new(this)
	greater ::= GreaterModifier new(this)
	init: func
}
