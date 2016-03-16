/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use geometry
use draw
import PlotData2D
import svg/Shapes

LineStyle: enum {
	Solid
	Dashed
	Dotted
}

LinePlotData2D: class extends PlotData2D {
	lineStyle: LineStyle { get set }
	init: func ~default (lineStyle := LineStyle Solid) {
		super()
		this lineStyle = lineStyle
	}
	init: func ~dataSeries (dataSeries: VectorList<FloatPoint2D>, label := "", colorRgba := ColorRgba black, lineStyle := LineStyle Solid) {
		super(dataSeries, label, colorRgba)
		this lineStyle = lineStyle
	}
	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorRgba: ColorRgba, lineStyle := LineStyle Solid) {
		this init(dataSeries, "", colorRgba, lineStyle)
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorRgba := ColorRgba black, lineStyle := LineStyle Solid) {
		super(xSeries, ySeries, label, colorRgba)
		this lineStyle = lineStyle
	}
	getSvg: override func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this dataSeries empty) {
			result = result & "<path stroke='" + this color >> "' stroke-opacity='" & this opacity toString() >> "' fill='none' stroke-width='" & this lineWidth toString() >> "' d='M " & ((transform * this dataSeries[0]) x) toString() >> " " & ((transform * this dataSeries[0]) y) toString() >> " L "
			for (j in 1 .. this dataSeries count)
				result = result & ((transform * this dataSeries[j]) x) toString() >> " " & ((transform * this dataSeries[j]) y) toString() >> " "
			result = result >> "' "
			match (this lineStyle) {
				case LineStyle Dashed =>
					result = result >> "stroke-dasharray='" & (this lineWidth * 5) toString() >> "," & (this lineWidth * 5) toString() >> "'"
				case LineStyle Dotted =>
					result = result >> "stroke-dasharray='" & this lineWidth toString() >> "," & this lineWidth toString() >> "'"
				case => // LineStyle Solid
			}
			result = result >> "/>\n"
		}
		result
	}
	getSvgLegend: override func (legendCount, fontSize: Int) -> String {
		result: String
		start := FloatPoint2D new(this legendOffset, this legendOffset + (fontSize * legendCount - fontSize / 2) as Float)
		end := FloatPoint2D new(this legendOffset + fontSize, start y)
		match (this lineStyle) {
			case LineStyle Dashed =>
				result = Shapes line(start, end, this lineWidth, this opacity, this color, FloatPoint2D new((this lineWidth * 5) as Float, (this lineWidth * 5) as Float))
			case LineStyle Dotted =>
				result = Shapes line(start, end, this lineWidth, this opacity, this color, FloatPoint2D new(this lineWidth as Float, this lineWidth as Float))
			case => // LineStyle Solid
				result = Shapes line(start, end, this lineWidth, this opacity, this color)
		}
		result & Shapes text(FloatPoint2D new(end x, end y + fontSize / 3), this label, fontSize, this opacity, this color)
	}
}
