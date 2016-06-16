/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use draw

ColorConvertTest: class extends Fixture {
	init: func {
		super("ColorConvert")
		this add("from RGB", func {
			color := ColorRgb new(80, 100, 120)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 141, 116)), is true)
			expect(color equals(ColorRgb new(80, 100, 120)), is true)
			expect(color toRgba() equals(ColorRgba new(80, 100, 120, 255)), is true)
			expect(color toMonochrome() equals(ColorMonochrome new(94)), is false)
			expect(color toYuv() equals(ColorYuv new(95, 141, 115)), is false)
			expect(color equals(ColorRgb new(81, 100, 120)), is false)
			expect(color toRgba() equals(ColorRgba new(81, 100, 120, 255)), is false)
		})
		this add("from RGBA", func {
			color := ColorRgba new(80, 100, 120, 60)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 141, 116)), is true)
			expect(color toRgb() equals(ColorRgb new(80, 100, 120)), is true)
			expect(color equals(ColorRgba new(80, 100, 120, 60)), is true)
		})
		this add("from Y", func {
			color := ColorMonochrome new(95)
			expect(color equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 128, 128)), is true)
			expect(color toRgb() equals(ColorRgb new(95, 95, 95)), is true)
			expect(color toRgba() equals(ColorRgba new(95, 95, 95, 255)), is true)
		})
		this add("from YUV", func {
			color := ColorYuv new(95, 141, 116)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color equals(ColorYuv new(95, 141, 116)), is true)
			expect(color toRgb() equals(ColorRgb new(78, 99, 118)), is true)
			expect(color toRgba() equals(ColorRgba new(78, 99, 118, 255)), is true)
		})
		this add("RGBA from text", func {
			color := ColorRgba fromString("79")
			expect(color equals(ColorRgba new(79, 79, 79, 255)))
			color = ColorRgba fromString("135,221")
			expect(color equals(ColorRgba new(135, 135, 135, 221)))
			color = ColorRgba fromString("78,56,34")
			expect(color equals(ColorRgba new(78, 56, 34, 255)))
			color = ColorRgba fromString("12,34,56,78")
			expect(color equals(ColorRgba new(12, 34, 56, 78)))
		})
	}
}

ColorConvertTest new() run() . free()
