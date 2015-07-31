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

use ooc-collections
import Event

Argument: class {
	_longIdentifier: String
	_shortIdentifier: String
	_parameters: Int
	_help: String
	_action: Event
	_action1: Event1<String>
	init: func (=_longIdentifier, =_shortIdentifier, =_parameters, =_help, =_action)
	init: func ~parameter(=_longIdentifier, =_shortIdentifier, =_parameters, =_help, =_action1)
	free: override func {
		if (this _action != null)
			this _action free()
		if (this _action1 != null)
			this _action1 free()
		super()
	}
}

TokenType: enum {
	Short
	Long
	Parameter
}

Token: class {
	_type: TokenType
	_value: String
	init: func (type: TokenType, value: String) {
		this _type = type
		this _value = value
	}
	free: override func {
		this _value free()
		super()
	}
}

CLIParser: class {
	_arguments: VectorList<Argument>
	init: func {
		this _arguments = VectorList<Argument> new()
	}

	add: func (longIdentifier: String, shortIdentifier: String, parameters: Int, help: String, action: Event) {
		this _arguments add(Argument new(longIdentifier, shortIdentifier, parameters, help, action))
	}
	add: func ~parameter(longIdentifier: String, shortIdentifier: String, parameters: Int, help: String, action: Event1<String>) {
		this _arguments add(Argument new(longIdentifier, shortIdentifier, parameters, help, action))
	}
	parse: func (input: VectorList<String>, inputLength: Int) {
		tokens := VectorList<Token> new()
		for (i in 0..inputLength) {
			tmpStr := input[i]
			tmpLength := tmpStr length()
			if (tmpStr startsWith?("--")) {
				subStr := tmpStr substring(2)
				tokens add(Token new(TokenType Long, subStr))
			} else if ((tmpStr startsWith?("-")) && (tmpLength > 1)) {
				newStr := tmpStr substring(1)
				for (i in 0..tmpLength - 1) {
					tokens add(Token new(TokenType Short, newStr[i]toString()))
				}
				newStr free()
			} else {
				tokens add(Token new(TokenType Parameter, tmpStr clone()))
			}
		}
		argument: Argument
		for (i in 0..tokens count) {
			argument = null
			if (tokens[i] _type == TokenType Short) {
				for (j in 0..this _arguments count) {
					if (this _arguments[j] _shortIdentifier == tokens[i] _value) {
							argument = this _arguments[j]
					}
				}
			} else if (tokens[i] _type == TokenType Long) {
				for (j in 0..this _arguments count) {
					if (this _arguments[j] _longIdentifier == tokens[i] _value) {
						argument = this _arguments[j]
					}
				}
			} else if (tokens[i] _type == TokenType Parameter) {
				raise("Unassociated Parameter")
			}
			if (argument != null) {
				parameters := VectorList<String> new()
				for ( k in 0..argument _parameters) {
					if (tokens[i + 1] _type == TokenType Parameter) {
						parameters add(tokens[i + 1] _value clone())
						token := tokens remove(i + 1)
						token free()
					}
				}
				if (parameters count == 0) {
					argument _action call()
				} else if (parameters count == 1) {
					argument _action1 call(parameters[0])
				}
				parameters free()
			}
		}
		tokens free()
	}
	free: override func {
		this _arguments free()
		super()
	}
}
