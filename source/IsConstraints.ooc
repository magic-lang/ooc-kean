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

import TrueConstraint, FalseConstraint, NotModifier

IsConstraints : class {
	init: func()
	true ::= TrueConstraint new ()
	false ::= FalseConstraint new ()
//	nan ::= NanConstraint new ()
//	empty ::= EmptyConstraint new ()
//	unique ::= UniqueConstraint new ()
	not ::= NotModifier new ()
//	equal ::= EqualModifier new ()
//	same ::= SameModifier new ()
//	greater ::= greaterModifier new ()
//	at ::= AtModifier new ()
//	less ::= LessModifier new ()
//	instance
//	assignable
	
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
}
