/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections

Application: class {
	_arguments := VectorList<String> new()
	_name: String
	name ::= this _name
	arguments ::= this _arguments
	init: func (argc: Int, argv: CString*) {
		this _name = String new(argv[0])
		for (i in 1 .. argc)
			this _arguments add(String new(argv[i]))
	}
	free: override func {
		(this _arguments, this _name) free()
		super()
	}
	processEvents: virtual func
}
