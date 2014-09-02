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

Event: class {
	_head: Func
	_tail: This
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	operator + (action: Func) -> This {
		Event new(action, this)
	}
	call: func {
		if (this _tail != null)
			this _tail call()
		this _head()
	}
}
Event1: class <T> {
	_head: Func(T)
	_tail: This<T>
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	operator + (action: Func(T)) -> This<T> {
		Event1 new(action, this)
	}
	call: func(argument: T) {
		if (this _tail != null)
			this _tail call(argument)
		this _head(argument)
	}
}
Event2: class <T0, T1> {
	_head: Func(T0, T1)
	_tail: This<T0, T1>
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	operator + (action: Func(T0, T1)) -> This<T0, T1> {
		Event2 new(action, this)
	}
	call: func(argument0: T0, argument1: T1) {
		if (this _tail != null)
			this _tail call(argument0, argument1)
		this _head(argument0, argument1)
	}
}
