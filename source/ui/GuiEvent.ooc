/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry

GuiEvent: abstract class {
	init: func
}

InputEvent: abstract class extends GuiEvent {
	_position: IntPoint2D
	position ::= this _position
	init: func (=_position)
}

MouseEvent: class extends InputEvent {
	init: func (position: IntPoint2D) { super(position) }
}

KeyboardEvent: class extends InputEvent {
	_key: Char
	key ::= this _key
	init: func (position: IntPoint2D, =_key) { super(position) }
}

RepaintEvent: class extends GuiEvent {
	_region: IntBox2D
	init: func (=_region)
}
