/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */
 
import ./[Constraint, IsConstraints, Test, Modifier, TrueConstraint, FalseConstraint, TestFailedException]
import structs/ArrayList

Fixture: abstract class {
	name : String
	tests := ArrayList<Test> new()
	init : func (=name)
	add : func (test : Test) {
		this tests add(test)
	}
	add : func ~action (name : String, action : Func) {
		test := Test new(name, action)
		this add(test)
	}
	run : func () {
		result := true
		(this name + " ") print()
		this tests each(|test|
			r := true
			try {
				test run()
			} catch (e : TestFailedException) {
				e test = test
				result = r = false
			}
			(r ? "." : "f") print()
		)
		(result ? " done" : " failed") println()
		exit(result ? 0 : 1)
	}
	is::= static IsConstraints new()
	expect: static func (value: Object, constraint : Constraint) {
		if (constraint verify(value))
			TestFailedException new(value, constraint) throw()
	}
	expect: static func ~boolConstraint (value: Bool, constraint : Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~bool (value: Bool) {
		This expect(Cell new(value), is true)
	}
}
