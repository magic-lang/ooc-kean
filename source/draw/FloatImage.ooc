/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry

FloatImage : class {
	// x = column
	// y = row
	_size: IntVector2D
	_pointer: Float*
	size ::= this _size
	pointer ::= this _pointer
	init: func ~IntVector2D (=_size)
	init: func ~WidthAndHeight (width, height: Int) {
		this _size = IntVector2D new(width, height)
		this _pointer = calloc(width * height, Float instanceSize)
	}
	free: override func {
		memfree(this _pointer)
		super()
	}
	operator [] (x, y: Int) -> Float {
		version(safe)
			Debug error(x > this _size x || y > this _size y || x < 0 || y < 0, "Accessing FloatImage index out of range in get")
		(this _pointer + (x + this _size x * y))@ as Float
	}
	operator []= (x, y: Int, value: Float) {
		version(safe)
			Debug error(x > this _size x || y > this _size y || x < 0 || y < 0, "Accessing FloatImage index out of range in set")
		(this _pointer + (x + this _size x * y))@ = value
	}
}
