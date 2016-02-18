/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Color

Pen: cover {
	color: ColorRgba { get set }
	width: Float { get set }
	alpha ::= this color alpha
	alphaAsFloat ::= this alpha as Float / 255.0
	init: func@ (=color, =width)
	init: func@ ~color (color: ColorRgba) { this init(color, 1.0f) }
	init: func@ ~default { this init(ColorRgba new(0, 0, 0, 255)) }
	init: func@ ~withRgb (colorRgb: ColorRgb) { this init(colorRgb toRgba()) }
	setAlpha: func@ (alpha: Byte) {
		this color = ColorRgba new(this color toRgb(), alpha)
	}
	setAlpha: func@ ~withFloat (value: Float) {
		this color = ColorRgba new(this color toRgb(), value * 255)
	}
}
