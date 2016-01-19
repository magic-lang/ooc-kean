use draw
use collections
use ooc-geometry

PlotData2D: abstract class {
	label: String { get set }
	lineWidth: Float { get set }
	legendOffset: Float { get set }
	colorBgra: ColorBgra { get set }
	color: String { get set }
	opacity: Float { get set }
	dataSeries: VectorList<FloatPoint2D> { get set }
	init: func ~default {
		this init(VectorList<FloatPoint2D> new())
	}
	init: func ~dataSeries (=dataSeries, label := "", colorBgra := ColorBgra new()) {
		this lineWidth = 1
		this legendOffset = 5.0f
		this label = label
		this colorBgra = colorBgra
	}
	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		this init(dataSeries, "", colorBgra)
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new()) {
		dataSeries := VectorList<FloatPoint2D> new()
		for (i in 0 .. ySeries count) {
			dataSeries add(FloatPoint2D new(xSeries != null ? xSeries[i] : (i + 1) as Float, ySeries[i]))
		}
		this init(dataSeries, label, colorBgra)
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
		if (dataSeries empty)
			result = FloatPoint2D new()
		else {
			result = dataSeries[0]
			for (i in 1 .. dataSeries count)
				result = result minimum(dataSeries[i])
		}
		result
	}
	maxValues: func -> FloatPoint2D {
		result: FloatPoint2D
		if (dataSeries empty)
			result = FloatPoint2D new()
		else {
			result = dataSeries[0]
			for (i in 1 .. dataSeries count)
				result = result maximum(dataSeries[i])
		}
		result
	}
}
