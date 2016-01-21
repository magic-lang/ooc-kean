use base
use geometry

GuiEvent: abstract class {
	init: func
}

MouseEvent: class extends GuiEvent {
	_position: IntPoint2D
	position ::= this _position
	init: func (=_position)
}

KeyboardEvent: class extends GuiEvent {
	_key: Char
	key ::= this _key
	init: func (=_key)
}

RepaintEvent: class extends GuiEvent {
	_region: IntBox2D
	init: func (=_region)
}
