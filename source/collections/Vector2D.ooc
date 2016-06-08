/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Vector2D: class <T> {
	_backend: T*
	_width: Int
	_height: Int
	width ::= this _width
	height ::= this _height
	init: func ~preallocated (=_backend, =_width, =_height)
	init: func (=_width, =_height) {
		this _backend = calloc(this _width * this _height, T size)
	}
	free: override func {
		memfree(this _backend)
		super()
	}
	operator [] (x, y: Int) -> T {
		version (safe)
			raise(x >= this width || x < 0 || y >= this height || y < 0, "Accessing Vector2D index out of range in get operator")
		this _backend[this width * y + x]
	}
	operator []= (x, y: Int, item: T) {
		version (safe)
			raise(x >= this width || x < 0 || y >= this height || y < 0, "Accessing Vector2D index out of range in set operator")
		this _backend[this width * y + x] = item
	}
}
