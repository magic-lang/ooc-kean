/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use draw

Image: abstract class {
	_size: IntVector2D
	_referenceCount: ReferenceCounter
	size ::= this _size
	width ::= this size x
	height ::= this size y
	referenceCount ::= this _referenceCount
	init: func (=_size) { this _referenceCount = ReferenceCounter new(this) }
	free: override func {
		this _referenceCount free()
		this _referenceCount = null
		super()
	}
	drawPoint: virtual func (position: FloatPoint2D, pen: Pen = Pen new(ColorRgba white)) {
		list := VectorList<FloatPoint2D> new(1)
		list add(position)
		this drawPoints(list, pen)
		list free()
	}
	drawLine: virtual func (start, end: FloatPoint2D, pen: Pen = Pen new(ColorRgba white)) {
		list := VectorList<FloatPoint2D> new(2)
		list add(start) . add(end)
		this drawLines(list, pen)
		list free()
	}
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>, pen: Pen = Pen new(ColorRgba white)) { Debug error("drawPoints unimplemented for class %s!" format(this class name)) }
	drawLines: virtual func (pointList: VectorList<FloatPoint2D>, pen: Pen = Pen new(ColorRgba white)) { Debug error("drawLines unimplemented for class %s!" format(this class name)) }
	drawBox: virtual func (box: FloatBox2D, pen: Pen = Pen new(ColorRgba white)) {
		positions := VectorList<FloatPoint2D> new(5)
		positions add(box leftTop)
		positions add(box rightTop)
		positions add(box rightBottom)
		positions add(box leftBottom)
		positions add(box leftTop)
		this drawLines(positions, pen)
		positions free()
	}
	blitWhiteSource: virtual func (source: This, offset: IntVector2D, sourceBox: IntBox2D) {
		normalizedSourceBox := (sourceBox toFloatBox2D()) / (source size toFloatVector2D())
		DrawState new(this) setBlendMode(BlendMode White) setInputImage(source) setSourceNormalized(normalizedSourceBox) setViewport(IntBox2D new(offset, sourceBox size)) draw()
	}
	blitWhite: func (source: This, offset: IntVector2D) {
		this blitWhiteSource(source as This, offset, IntBox2D new(source size))
	}
	fill: virtual func (color: ColorRgba) { Debug error("fill unimplemented for class %s!" format(this class name)) }
	draw: virtual func ~DrawState (drawState: DrawState) { Debug error("draw~DrawState unimplemented for class %s!" format(this class name)) }
	resizeWithin: func (restriction: IntVector2D) -> This {
		restrictionFraction := (restriction x as Float / this size x as Float) minimum(restriction y as Float / this size y as Float)
		this resizeTo((this size toFloatVector2D() * restrictionFraction) toIntVector2D())
	}
	resizeTo: abstract func (size: IntVector2D) -> This
	resizeTo: virtual func ~withMethod (size: IntVector2D, Interpolate: Bool) -> This { this resizeTo(size) }
	create: virtual func (size: IntVector2D) -> This { Debug error("create unimplemented for class %s!" format(this class name)); null }
	copy: abstract func -> This
	distance: virtual abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
	isValidIn: func (x, y: Int) -> Bool { x >= 0 && x < this size x && y >= 0 && y < this size y }
	// Writes white text on the existing image
	write: func (message: String, fontAtlas: This, localOrigin: IntPoint2D) {
		skippedRows := 2
		columns := 16
		fontSize := DrawContext getFontSize(fontAtlas)
		targetOffset := IntPoint2D new(0, 0)
		for (i in 0 .. message size) {
			charCode := message[i] as Int
			sourceX := charCode % columns
			sourceY := (charCode / columns) - skippedRows
			source := IntBox2D new(sourceX * fontSize x, sourceY * fontSize y, fontSize x, fontSize y)
			if ((charCode as Char) graph())
				this blitWhiteSource(fontAtlas, (localOrigin + (targetOffset * fontSize)) toIntVector2D(), source)
			targetOffset x += 1
			if (charCode == '\n') {
				targetOffset x = 0 // Carriage return
				targetOffset y += 1 // Line feed
			}
		}
	}
}
