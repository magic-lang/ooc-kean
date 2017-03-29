/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use collections
use geometry

PlotData2D: abstract class {
	label: String { get set }
	lineWidth: Float { get set }
	legendOffset: Float { get set }
	colorRgba: ColorRgba { get set }
	color: String { get set }
	opacity: Float { get set }
	dataSeries: VectorList<FloatPoint2D> { get set }
	init: func ~default {
		this init(VectorList<FloatPoint2D> new())
	}
	init: func ~dataSeries (=dataSeries, label := "", colorRgba := ColorRgba black) {
		this lineWidth = 1
		this legendOffset = 5.0f
		this label = label
		this colorRgba = colorRgba
	}
	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorRgba: ColorRgba) {
		this init(dataSeries, "", colorRgba)
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorRgba := ColorRgba black) {
		dataSeries := VectorList<FloatPoint2D> new()
		for (i in 0 .. ySeries count) {
			dataSeries add(FloatPoint2D new(xSeries != null ? xSeries[i] : (i + 1) as Float, ySeries[i]))
		}
		this init(dataSeries, label, colorRgba)
	}
	free: override func {
		this dataSeries free()
		if (this color)
			this color free()
		super()
	}
	getSvg: abstract func (transform: FloatTransform2D) -> String
	getSvgLegend: abstract func (legendCount, fontSize: Int) -> String
	minValues: func -> FloatPoint2D {
		result: FloatPoint2D
		if (this dataSeries empty)
			result = FloatPoint2D new()
		else {
			result = this dataSeries[0]
			for (i in 1 .. this dataSeries count)
				result = result minimum(this dataSeries[i])
		}
		result
	}
	maxValues: func -> FloatPoint2D {
		result: FloatPoint2D
		if (this dataSeries empty)
			result = FloatPoint2D new()
		else {
			result = this dataSeries[0]
			for (i in 1 .. this dataSeries count)
				result = result maximum(this dataSeries[i])
		}
		result
	}
}
