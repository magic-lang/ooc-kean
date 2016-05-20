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
import Canvas

Image: abstract class {
	_size: IntVector2D
	_referenceCount: ReferenceCounter
	_canvas: Canvas
	size ::= this _size
	width ::= this size x
	height ::= this size y
	crop: IntShell2D { get set }
	wrap: Bool { get set }
	referenceCount ::= this _referenceCount
	canvas: Canvas { get {
		if (this _canvas == null)
			this _canvas = this _createCanvas()
		this _canvas
	}}
	init: func (=_size) {
		this _referenceCount = ReferenceCounter new(this)
	}
	init: func ~fromImage (original: This) {
		this init(original size)
		this crop = original crop
		this wrap = original wrap
	}
	free: override func {
		if (this referenceCount != null)
			this referenceCount free()
		this _referenceCount = null
		if (this _canvas != null)
			this _canvas free()
		this _canvas = null
		super()
	}
	drawPoint: func ~white (position: FloatPoint2D) { this canvas drawPoint~white(position) }
	drawPoint: func ~explicit (position: FloatPoint2D, pen: Pen) { this canvas drawPoint~explicit(position, pen) }
	drawLine: func ~white (start, end: FloatPoint2D) { this canvas drawLine~white(start, end) }
	drawLine: func ~explicit (start, end: FloatPoint2D, pen: Pen) { this canvas drawLine~explicit(start, end, pen) }
	drawPoints: func ~white (pointList: VectorList<FloatPoint2D>) { this canvas drawPoints~white(pointList) }
	drawPoints: func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) { this canvas drawPoints~explicit(pointList, Pen new(ColorRgba white)) }
	drawLines: func ~white (pointList: VectorList<FloatPoint2D>) { this canvas drawLines~white(pointList) }
	drawLines: func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) { this canvas drawLines~explicit(pointList, Pen new(ColorRgba white)) }
	drawBox: func ~white (box: FloatBox2D) { this canvas drawBox~white(box) }
	drawBox: func ~explicit (box: FloatBox2D, pen: Pen) { this canvas drawBox~explicit(box, Pen new(ColorRgba white)) }
	fill: func ~implicitCanvas (color: ColorRgba) { this canvas fill(color) }
	resizeWithin: func (restriction: IntVector2D) -> This {
		restrictionFraction := (restriction x as Float / this size x as Float) minimum(restriction y as Float / this size y as Float)
		this resizeTo((this size toFloatVector2D() * restrictionFraction) toIntVector2D())
	}
	resizeTo: abstract func (size: IntVector2D) -> This
	resizeTo: virtual func ~withMethod (size: IntVector2D, Interpolate: Bool) -> This {
		this resizeTo(size)
	}
	create: virtual func (size: IntVector2D) -> This { raise("Image::create not implemented for type: %s" format(this class name)); null }
	copy: abstract func -> This
	distance: virtual abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
	isValidIn: func (x, y: Int) -> Bool {
		x >= 0 && x < this size x && y >= 0 && y < this size y
	}
	_createCanvas: virtual func -> Canvas { null }
	// Writes white text on the existing image
	write: virtual func (message: Text, fontAtlas: This, localOrigin: IntPoint2D) {
		takenMessage := message take()
		skippedRows := 2
		visibleRows := 6
		columns := 16
		fontSize := DrawContext getFontSize(fontAtlas)
		viewport := IntBox2D new(localOrigin, fontSize)
		targetOffset := IntPoint2D new(0, 0)
		characterDrawState := DrawState new(this) setInputImage(fontAtlas) setBlendMode(BlendMode White)
		for (i in 0 .. takenMessage count) {
			charCode := takenMessage[i] as Int
			sourceX := charCode % columns
			sourceY := (charCode / columns) - skippedRows
			source := FloatBox2D new((sourceX as Float) / columns, (sourceY as Float) / visibleRows, 1.0f / columns, 1.0f / visibleRows)
			if ((charCode as Char) graph())
				characterDrawState setViewport(viewport + (targetOffset * fontSize)) setSourceNormalized(source) draw()
			targetOffset x += 1
			if (charCode == '\n') {
				targetOffset x = 0 // Carriage return
				targetOffset y += 1 // Line feed
			}
		}
		message free(Owner Receiver)
	}
}
