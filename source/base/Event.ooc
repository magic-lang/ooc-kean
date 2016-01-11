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
	head ::= this _head
	tail ::= this _tail
	init: func ~nil {
		this init(func) // TODO: this is really a stupid way to create null pointer although no null text is required
	}
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	free: override func {
		(this _head as Closure) free()
		if (this _tail != null)
			this _tail free()
		super()
	}
	add: func (action: Func) -> This {
		this add(This new(action, null))
	}
	add: func ~withEvent (event: This) -> This {
		if (event)
			if (this _tail)
				this _tail add(event)
			else
				this _tail = event
		this
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
	head ::= this _head
	tail ::= this _tail
	init: func ~nil {
		this init(func (argument: T)) // TODO: this is really a stupid way to create null pointer although no null text is required
	}
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	free: override func {
		(this _head as Closure) free()
		if (this _tail != null)
			this _tail free()
		super()
	}
	add: func (action: Func(T)) -> This<T> {
		this add(This<T> new(action, null))
	}
	add: func ~withEvent (event: This<T>) -> This<T> {
		if (event)
			if (this _tail)
				this _tail add(event)
			else
				this _tail = event
		this
	}
	call: func (argument: T) {
		if (this _tail != null)
			this _tail call(argument)
		this _head(argument)
	}
}

Event2: class <T0, T1> {
	_head: Func(T0, T1)
	_tail: This<T0, T1>
	head ::= this _head
	tail ::= this _tail
	init: func ~nil {
		this init(func (argument0: T0, argument1: T1)) // TODO: this is really a stupid way to create null pointer although no null text is required
	}
	init: func (=_head)
	init: func ~add (=_head, =_tail)
	free: override func {
		(this _head as Closure) free()
		if (this _tail != null)
			this _tail free()
		super()
	}
	add: func (action: Func(T0, T1)) -> This<T0, T1> {
		this add(This<T0, T1> new(action, null))
	}
	add: func ~withEvent (event: This<T0, T1>) -> This<T0, T1> {
		if (event)
			if (this _tail)
				this _tail add(event)
			else
				this _tail = event
		this
	}
	call: func (argument0: T0, argument1: T1) {
		if (this _tail != null)
			this _tail call(argument0, argument1)
		this _head(argument0, argument1)
	}
}
