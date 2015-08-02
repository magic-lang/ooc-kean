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
import math

Modifier: abstract class {
	parent: This
	child: This
	init: func {
		this parent = null
	}
	init: func ~parent (=parent)
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
		value != null && value instanceOf?(String) && value as String empty?()
	}
}
NotModifier: class extends Modifier {
	init: func { super() }
	init: func ~parent (parent: Modifier) { super(parent) }
	test: override func (value: Object) -> Bool {
		!(this testChild(value))
	}
	true ::= TrueConstraint new(this)
	false ::= FalseConstraint new(this)
	Null ::= NullConstraint new(this)
	empty ::= EmptyConstraint new(this)
	not ::= This new(this)
	equal ::= EqualModifier new(this)
//	nan ::= NanConstraint new()
//	unique ::= UniqueConstraint new()
//	same ::= SameModifier new()
//	greater ::= greaterModifier new()
//	at ::= AtModifier new()
//	less ::= LessModifier new()
//	instance
//	assignable
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
		CompareConstraint new(this, correct, f)
	}
	to: func ~boolean (correct: Bool) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Bool> get() == c as Cell<Bool> get() }
		CompareConstraint new(this, Cell<Bool> new(correct), f)
	}
	to: func ~integer (correct: Int) -> CompareConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Int> get() == c as Cell<Int> get() }
		CompareConstraint new(this, Cell<Int> new(correct), f)
	}
	to: func ~float (correct: Float) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Float> get() == c as Cell<Float> get() }
		CompareWithinConstraint new(this, Cell<Float> new(correct), f)
	}
	to: func ~double (correct: Double) -> CompareWithinConstraint {
		f := func (value, c: Object) -> Bool { value as Cell<Double> get() == c as Cell<Double> get() }
		CompareWithinConstraint new(this, Cell<Double> new(correct), f)
	}
}
CompareConstraint: class extends Constraint {
	comparer: Func (Object, Object) -> Bool
	correct: Object
	init: func (parent: Modifier, =correct, =comparer) {
		super(parent)
	}
	test: override func (value: Object) -> Bool {
		this comparer(value, this correct)
	}
}
CompareWithinConstraint: class extends CompareConstraint {
	init: func (parent: Modifier, .correct, .comparer) {
		super(parent, correct, comparer)
	}
	within: func ~float (precision: Float) -> CompareConstraint {
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		f := func (value, correct: Object) -> Bool { (value as Cell<Float> get() - correct as Cell<Float> get()) abs() < precision }
		CompareConstraint new(this, this correct, f)
	}
	within: func ~double (precision: Double) -> CompareConstraint {
		this comparer = func (value, correct: Object) -> Bool { this testChild(value) }
		f := func (value, correct: Object) -> Bool { (value as Cell<Double> get() - correct as Cell<Double> get()) abs() < precision }
		CompareConstraint new(this, this correct, f)
	}
	test: override func (value: Object) -> Bool {
		comparer := this comparer
		comparer(value, this correct)
	}
}
IsConstraints: class {
	init: func
	true ::= TrueConstraint new()
	false ::= FalseConstraint new()
	Null ::= NullConstraint new()
	empty ::= EmptyConstraint new()
	not ::= NotModifier new()
	equal ::= EqualModifier new()
//	nan ::= NanConstraint new()
//	unique ::= UniqueConstraint new()
//	same ::= SameModifier new()
//	greater ::= greaterModifier new()
//	at ::= AtModifier new()
//	less ::= LessModifier new()
//	instance
//	assignable
}
/*
	is equal to
	is same as
	// Comparision Constraints
	is true
	is false
	is nan
	is empty
	is unique
	is greater than
	is greater than or equal to
	is at least
	is less than
	is less than or equal to
	is at most
	// Type Constraints
	is of type
	is instance of type
	is assignable from
	// String Constraints
	text contains
	text does not contain
	text starts with
	text does not start with
	text ends with
	text does not end with
	text matches
	text does not match
	// Collection Constraints
	has all
	has some
	has none
	is unique
	has member
	is subset of
	*/
