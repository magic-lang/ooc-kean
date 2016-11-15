/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
import Image
import RasterMonochrome, RasterRgb, RasterRgba
import Color
import StbImage

RasterImage: abstract class extends Image {
	distanceRadius ::= 1
	stride: UInt { get }
	init: func (size: IntVector2D) { super(size) }
	apply: abstract func ~rgb (action: Func (ColorRgb))
	apply: abstract func ~yuv (action: Func (ColorYuv))
	apply: abstract func ~monochrome (action: Func (ColorMonochrome))
	resizeTo: override func (size: IntVector2D) -> Image { Debug error("resizeTo unimplemented for " + this class name); null }
	copy: abstract func -> This
	save: virtual func (filename: String) -> Int { Debug error("RasterImage save unimplemented for format!"); 0 }
	open: static func ~unknownType (filename: String) -> This {
		result: This
		(buffer, size, imageComponents) := StbImage load(filename)
		match (imageComponents) {
			case 1 =>
				result = RasterMonochrome new(buffer, size)
			case 3 =>
				result = RasterRgb new(buffer, size)
			case 4 =>
				result = RasterRgba new(buffer, size)
			case =>
				buffer free()
				Debug error("Unsupported number of channels in image")
		}
		result
	}
	fill: override func (color: ColorRgba) { Debug error("RasterImage fill unimplemented!") }
	draw: override func ~DrawState (drawState: DrawState) { this _draw(drawState inputImage, drawState getSourceLocal() toIntBox2D(), drawState getViewport(), drawState getTransformNormalized(), drawState interpolate, drawState flipSourceX, drawState flipSourceY) }
	_draw: virtual func (image: Image, source, destination: IntBox2D, normalizedTransform: FloatTransform3D, interpolate, flipX, flipY: Bool) { Debug error("_draw unimplemented for class " + this class name + "!") }
	drawPoint: override func (point: FloatPoint2D, pen: Pen) { this _drawPoint(point x as Int, point y as Int, pen) }
	_drawPoint: abstract func (x, y: Int, pen: Pen)
	drawPoints: override func (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		for (i in 0 .. pointList count)
			this drawPoint(pointList[i], pen)
	}
	_drawLine: func (start, end: IntPoint2D, pen: Pen) {
		if (start y == end y) {
			startX := start x minimum(end x)
			endX := start x maximum(end x)
			for (x in startX .. endX + 1)
				this _drawPoint(x, start y, pen)
		} else if (start x == end x) {
			startY := start y minimum(end y)
			endY := start y maximum(end y)
			for (y in startY .. endY + 1)
				this _drawPoint(start x, y, pen)
		} else {
			alpha := pen alphaAsFloat
			if (Int abs(end x - start x) < Int abs(end y - start y)) {
				slope := (end x - start x) as Float / (end y - start y) as Float
				startY := start y minimum(end y)
				endY := start y maximum(end y)
				for (y in startY .. endY + 1) {
					idealX := slope * (y - start y) + start x
					floor := idealX floor()
					weight := (idealX - floor) abs()
					pen setAlpha(alpha * (1.0f - weight))
					this _drawPoint(floor, y, pen)
					pen setAlpha(alpha * weight)
					this _drawPoint(floor + 1, y, pen)
				}
			} else {
				slope := (end y - start y) as Float / (end x - start x) as Float
				startX := start x minimum(end x)
				endX := start x maximum(end x)
				for (x in startX .. endX + 1) {
					idealY := slope * (x - start x) + start y
					floor := idealY floor()
					weight := (idealY - floor) abs()
					pen setAlpha(alpha * (1.0f - weight))
					this _drawPoint(x, floor, pen)
					pen setAlpha(alpha * weight)
					this _drawPoint(x, floor + 1, pen)
				}
			}
		}
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		for (i in 0 .. pointList count - 1) {
			start := IntPoint2D new(pointList[i] x, pointList[i] y)
			end := IntPoint2D new(pointList[i + 1] x, pointList[i + 1] y)
			this _drawLine(start, end, pen)
		}
	}
	_map: func (point: IntPoint2D) -> IntPoint2D {
		point + this _size / 2
	}
}
