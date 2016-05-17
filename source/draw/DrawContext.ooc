/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry
import images/DefaultFont

AlignWidth: enum {
	Nearest
	Floor
	Ceiling
}

DrawContext: abstract class {
	_defaultFontRaster: RasterMonochrome = null
	defaultFontRaster: RasterMonochrome { get {
		if (this _defaultFontRaster == null)
			this _defaultFontRaster = RasterMonochrome fromAscii(defaultFontAsciiImage)
		this _defaultFontRaster
	}}
	init: func
	free: override func {
		if (this _defaultFontRaster != null)
			this _defaultFontRaster free()
		super()
	}
	createMonochrome: abstract func (size: IntVector2D) -> Image
	createRgb: abstract func (size: IntVector2D) -> Image
	createRgba: abstract func (size: IntVector2D) -> Image
	createUv: abstract func (size: IntVector2D) -> Image
	createImage: abstract func (rasterImage: RasterImage) -> Image
	createYuv420Semiplanar: abstract func (size: IntVector2D) -> Image
	createYuv420Semiplanar: abstract func ~fromImages (y, uv: Image) -> Image
	createYuv420Semiplanar: abstract func ~fromRaster (raster: RasterYuv420Semiplanar) -> Image
	createImageFromTextAndFont: virtual func (message: Text, fontAtlas: Image) -> Image {
		target := this createMonochrome(This getTextPixelBounds(message take(), fontAtlas))
		target fill(ColorRgba black)
		target write(message take(), fontAtlas, IntPoint2D new(0, 0))
		message free(Owner Receiver)
		target
	}
	alignWidth: virtual func (width: Int, align := AlignWidth Nearest) -> Int { width }
	update: abstract func
	isAligned: virtual func (width: Int) -> Bool { true }
	getDefaultFont: virtual func -> Image { this defaultFontRaster }
	getFontSize: static func (fontAtlas: Image) -> IntVector2D { fontAtlas size / IntVector2D new(16, 6) }
	getTextIndexBounds: static func (message: Text) -> IntVector2D {
		takenMessage := message take()
		(x, y, width, height) := (0, 0, 0, 0)
		for (i in 0 .. takenMessage count) {
			current := takenMessage[i]
			x += 1
			if (current == '\n') {
				x = 0
				y += 1
			} else if (current graph()) {
				width = width maximum(x)
				height = height maximum(y + 1)
			}
		}
		message free(Owner Receiver)
		IntVector2D new(width, height)
	}
	getTextPixelBounds: static func (message: Text, fontAtlas: Image) -> IntVector2D {
		This getTextIndexBounds(message) * This getFontSize(fontAtlas)
	}
}
