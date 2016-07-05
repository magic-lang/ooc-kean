/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use base
import Event

_Argument: class {
	_longIdentifier: String
	_shortIdentifier: Char
	_parameters: Int
	_action: Event
	_textAction: Event1<String>
	_listAction: Event1<VectorList<String>>
	init: func (=_longIdentifier, =_shortIdentifier, =_parameters, =_action)
	init: func ~noShort (=_longIdentifier, =_parameters, =_action)
	init: func ~parameter (=_longIdentifier, =_shortIdentifier, =_parameters, =_textAction)
	init: func ~parameterNoShort (=_longIdentifier, =_parameters, =_textAction)
	init: func ~parameters (=_longIdentifier, =_shortIdentifier, =_parameters, =_listAction)
	init: func ~parametersNoShort (=_longIdentifier, =_parameters, =_listAction)
	init: func ~default (=_textAction)
	free: override func {
		if (this _longIdentifier != null)
			this _longIdentifier free()
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
	add: func (longIdentifier: String, shortIdentifier: Char, action: Event) {
		this _arguments add(_Argument new(longIdentifier, shortIdentifier, 0, action))
	}
	add: func ~noShort (longIdentifier: String, action: Event) {
		this _arguments add(_Argument new(longIdentifier, 0, action))
	}
	add: func ~parameter (longIdentifier: String, shortIdentifier: Char, action: Event1<String>) {
		this _arguments add(_Argument new(longIdentifier, shortIdentifier, 1, action))
	}
	add: func ~parameterNoShort (longIdentifier: String, action: Event1<String>) {
		this _arguments add(_Argument new(longIdentifier, 1, action))
	}
	add: func ~parameters (longIdentifier: String, shortIdentifier: Char, parameters: Int, action: Event1<VectorList<String>>) {
		this _arguments add(_Argument new(longIdentifier, shortIdentifier, parameters, action))
	}
	add: func ~parametersNoShort (longIdentifier: String, parameters: Int, action: Event1<VectorList<String>>) {
		this _arguments add(_Argument new(longIdentifier, parameters, action))
	}
	addDefault: func (action: Event1<String>) {
		this _defaultArgument = _Argument new(action)
	}
	parse: func (input: VectorList<String>) {
		parameters := VectorList<String> new()
		arguments := VectorList<String> new()
		for (i in 0 .. input count) {
			(parameters, arguments) clear()
			current := input[i]
			if (current startsWith("--"))
				arguments add(current substring(2))
			else if (current startsWith("-"))
				for (j in 1 .. current size)
					arguments add(current[j] as String)
			else
				this _defaultArgument _textAction call(current)
			for (k in 0 .. arguments count) {
				if (argument := this _findArgument(arguments[k])) {
					if (argument _parameters > 1) {
						for (j in 0 .. argument _parameters)
							parameters add(input[i + j + 1])
						argument _listAction call(parameters)
					}
					else if (argument _parameters == 1)
						argument _textAction call(input[i + 1])
					else
						argument _action call()
					i += argument _parameters
				}
			}
		}
		(parameters, arguments) free()
	}
	_findArgument: func (identifier: String) -> _Argument {
		result: _Argument = null
		for (i in 0 .. this _arguments count) {
			shortIdentifierAsString := this _arguments[i] _shortIdentifier as String
			if (identifier == this _arguments[i] _longIdentifier || identifier == shortIdentifierAsString)
				result = this _arguments[i]
			shortIdentifierAsString free()
			if (result != null)
				break
		}
		result
	}
}
