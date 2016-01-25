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
