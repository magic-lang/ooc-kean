/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
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

use ooc-collections
use ooc-base
import Event

_Argument: class {
	_longIdentifier: Text
	_shortIdentifier: Char
	_parameters: Int
	_action: Event
	_textAction: Event1<Text>
	_listAction: Event1<VectorList<Text>>
	init: func (=_longIdentifier, =_shortIdentifier, =_parameters, =_action)
	init: func ~parameter (=_longIdentifier, =_shortIdentifier, =_parameters, =_textAction)
	init: func ~parameters (=_longIdentifier, =_shortIdentifier, =_parameters, =_listAction)
	init: func ~default (=_textAction)
	free: override func {
		this _longIdentifier free(Owner Receiver)
		if (this _action != null)
			this _action free()
		if (this _textAction != null)
			this _textAction free()
		if (this _listAction != null)
			this _listAction free()
		super()
	}
}

ArgumentParser: class {
	_arguments: VectorList<_Argument>
	_defaultArgument: _Argument
	init: func {
		this _arguments = VectorList<_Argument> new()
	}
	free: override func {
		this _arguments free()
		if (this _defaultArgument)
			this _defaultArgument free()
		super()
	}
	add: func (longIdentifier: Text, shortIdentifier: Char, action: Event) {
		this _arguments add(_Argument new(longIdentifier claim(), shortIdentifier, 0, action))
	}
	add: func ~parameter (longIdentifier: Text, shortIdentifier: Char, action: Event1<Text>) {
		this _arguments add(_Argument new(longIdentifier claim(), shortIdentifier, 1, action))
	}
	add: func ~parameters (longIdentifier: Text, shortIdentifier: Char, parameters: Int, action: Event1<VectorList<Text>>) {
		this _arguments add(_Argument new(longIdentifier claim(), shortIdentifier, parameters, action))
	}
	addDefault: func (action: Event1<Text>) {
		this _defaultArgument = _Argument new(action)
	}
	parse: func (input: VectorList<Text>) {
		parameters := VectorList<Text> new()
		for (i in 0 .. input count) {
			parameters clear()
			current := input[i] take()
			if (current beginsWith(t"--"))
				current = current slice(2)
			else if (current beginsWith(t"-"))
				current = current slice(1)
			else
				this _defaultArgument _textAction call(current)
			if (argument := this _findArgument(current)) {
				if (argument _parameters > 1) {
					for (j in 0 .. argument _parameters)
						parameters add(input[i + j + 1] take())
					argument _listAction call(parameters)
				}
				else if (argument _parameters == 1)
					argument _textAction call(input[i + 1] take())
				else
					argument _action call()
				i += argument _parameters
			}
		}
		for (i in 0 .. input count)
			input[i] free(Owner Receiver)
		parameters free()
	}
	_findArgument: func (identifier: Text) -> _Argument {
		result: _Argument
		for (i in 0 .. this _arguments count)
			if (identifier == this _arguments[i] _longIdentifier take() || identifier == Text new(this _arguments[i] _shortIdentifier)) {
				result = _arguments[i]
				break
			}
		result
	}
}
