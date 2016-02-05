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

Shape: enum {
	Circle
	Square
}

ScatterPlotData2D: class extends PlotData2D {
	_shape := Shape Circle
	_scalingRelativeLineWidth := 5.0f
	shape: Shape {
		get { this _shape }
		set (newShape) {
			this _shape = newShape
		}
	}
	init: func ~default {
		super()
	}
	init: func ~dataSeries (dataSeries: VectorList<FloatPoint2D>, label := "", colorBgra := ColorBgra new(), size := 5.f, shape := Shape Circle) {
		super(dataSeries, label, colorBgra)
		this _scalingRelativeLineWidth = size
		this _shape = shape
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new(), size := 5.f, shape := Shape Circle) {
		super(xSeries, ySeries, label, colorBgra)
		this _scalingRelativeLineWidth = size
		this _shape = shape
	}
	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		super(dataSeries, "", colorBgra)
	}
	getSvg: override func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this dataSeries empty) {
			for (i in 0 .. this dataSeries count) {
				match (this _shape) {
					case Shape Circle =>
						r := this _scalingRelativeLineWidth / 2.0f * this lineWidth
						result = result & Shapes circle(FloatPoint2D new((transform * this dataSeries[i]) x, (transform * dataSeries[i]) y), r, this opacity, this color)
					case Shape Square =>
						x := (transform * this dataSeries[i]) x - this _scalingRelativeLineWidth / 2.0f * this lineWidth
						y := (transform * this dataSeries[i]) y - this _scalingRelativeLineWidth / 2.0f * this lineWidth
						width := this _scalingRelativeLineWidth * this lineWidth
						result = result & Shapes rect(x, y, width, width, this opacity, this color)
					case =>
						result = result >> ""
				}
			}
		}
		result
	}
	getSvgLegend: override func (legendCount, fontSize: Int) -> String {
		result := ""
		start := FloatPoint2D new(this legendOffset as Float, this legendOffset + (fontSize * legendCount) as Float - (fontSize as Float) / 2.0f)
		size := (fontSize as Float) * 0.8f
		halfLineHeight := (fontSize as Float) / 2.0f
		match (this _shape) {
			case Shape Circle =>
				result = result & Shapes circle(FloatPoint2D new(start x + halfLineHeight, start y), size / 2.0f, this opacity, this color)
			case Shape Square =>
				result = result & Shapes rect(FloatPoint2D new(start x, start y - halfLineHeight), FloatPoint2D new(size, size), this opacity, this color)
			case =>
		}
		result & Shapes text(FloatPoint2D new(start x + fontSize as Float, start y + halfLineHeight), this label, fontSize, this opacity, this color)
	}
}
