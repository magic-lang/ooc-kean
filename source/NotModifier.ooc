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
 
import ./[Constraint, Modifier, TrueConstraint, FalseConstraint]

NotModifier : class extends Modifier {
	init: func { super() }
	init: func~parent(parent : Modifier) { super(parent) }
	verify: func(value : Object) -> Bool {
		!(this verifyChild(value))
	}
	true ::= TrueConstraint new (this)
	false ::= FalseConstraint new (this)
//	nan ::= NanConstraint new ()
//	empty ::= EmptyConstraint new ()
//	unique ::= UniqueConstraint new ()
	not ::= NotModifier new (this)
//	equal ::= EqualModifier new ()
//	same ::= SameModifier new ()
//	greater ::= greaterModifier new ()
//	at ::= AtModifier new ()
//	less ::= LessModifier new ()
//	instance
//	assignable
}
