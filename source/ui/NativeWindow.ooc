/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
NativeWindow: abstract class {
	_display: Pointer
	_backend: Long
	_size: IntVector2D
	display ::= this _display
	backend ::= this _backend
	size ::= this _size

	init: func (=_size, =_backend, =_display)
}
