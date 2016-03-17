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
	_longIdentifier: Text
	_shortIdentifier: Char
	_parameters: Int
	_action: Event
	_textAction: Event1<Text>
	_listAction: Event1<VectorList<Text>>
	init: func (=_longIdentifier, =_shortIdentifier, =_parameters, =_action)
	init: func ~noShort (=_longIdentifier, =_parameters, =_action)
	init: func ~parameter (=_longIdentifier, =_shortIdentifier, =_parameters, =_textAction)
	init: func ~parameterNoShort (=_longIdentifier, =_parameters, =_textAction)
	init: func ~parameters (=_longIdentifier, =_shortIdentifier, =_parameters, =_listAction)
	init: func ~parametersNoShort (=_longIdentifier, =_parameters, =_listAction)
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
	add: func ~noShort (longIdentifier: Text, action: Event) {
		this _arguments add(_Argument new(longIdentifier claim(), 0, action))
	}
	add: func ~parameter (longIdentifier: Text, shortIdentifier: Char, action: Event1<Text>) {
		this _arguments add(_Argument new(longIdentifier claim(), shortIdentifier, 1, action))
	}
	add: func ~parameterNoShort (longIdentifier: Text, action: Event1<Text>) {
		this _arguments add(_Argument new(longIdentifier claim(), 1, action))
	}
	add: func ~parameters (longIdentifier: Text, shortIdentifier: Char, parameters: Int, action: Event1<VectorList<Text>>) {
		this _arguments add(_Argument new(longIdentifier claim(), shortIdentifier, parameters, action))
	}
	add: func ~parametersNoShort (longIdentifier: Text, parameters: Int, action: Event1<VectorList<Text>>) {
		this _arguments add(_Argument new(longIdentifier claim(), parameters, action))
	}
	addDefault: func (action: Event1<Text>) {
		this _defaultArgument = _Argument new(action)
	}
	parse: func (input: VectorList<Text>) {
		parameters := VectorList<Text> new()
		arguments := VectorList<Text> new()
		for (i in 0 .. input count) {
			parameters clear()
			arguments clear()
			current := input[i] take()
			if (current beginsWith(t"--"))
				arguments add(current slice(2))
			else if (current beginsWith(t"-")) {
				current = current slice(1)
				for (j in 0 .. current count)
					arguments add(current slice(j, 1))
			}
			else
				this _defaultArgument _textAction call(current)
			for (k in 0 .. arguments count) {
				if (argument := this _findArgument(arguments[k])) {
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
		}
		for (i in 0 .. input count)
			input[i] free(Owner Receiver)
		(parameters, arguments) free()
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
