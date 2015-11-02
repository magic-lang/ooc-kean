use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import svg/Shapes

LineStyle: enum {
	Solid
	Dashed
	Dotted
}

LinePlotData2D: class extends PlotData2D {
	lineStyle: LineStyle { get set }
	dataSeries: VectorList<FloatPoint2D> { get set }

	init: func ~default (lineStyle := LineStyle Solid) {
		super("", ColorBgra new())
		this dataSeries = VectorList<FloatPoint2D> new()
		this lineStyle = lineStyle
	}

	init: func ~dataSeries (=dataSeries, label := "", colorBgra := ColorBgra new(), lineStyle := LineStyle Solid) {
		super(label, colorBgra)
		this lineStyle = lineStyle
	}

	init: func ~color (=dataSeries, colorBgra: ColorBgra, lineStyle := LineStyle Solid) {
		super("", colorBgra)
		this lineStyle = lineStyle
	}

	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new(), lineStyle := LineStyle Solid) {
		this dataSeries = VectorList<FloatPoint2D> new()
		for (i in 0 .. ySeries count) {
			this dataSeries add(FloatPoint2D new(xSeries != null ? xSeries[i] : (i + 1) as Float, ySeries[i]))
		}
		super(label, colorBgra)
		this lineStyle = lineStyle
	}

	free: override func {
		this dataSeries free()
		super()
	}

	getSvg: func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this dataSeries empty) {
			result = result & "<path stroke='" + Shapes getColor(this colorBgra) >> "' stroke-opacity='" & Shapes getOpacity(this colorBgra) >> "' fill='none' stroke-width='" & this lineWidth toString() >> "' d='M " & ((transform * this dataSeries[0]) x) toString() >> " " & ((transform * this dataSeries[0]) y) toString() >> " L "
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

	getSvgLegend: func (legendCount, fontSize: Int) -> String {
		result: String
		start := FloatPoint2D new(this legendOffset, this legendOffset + (fontSize * legendCount - fontSize / 2) as Float)
		end := FloatPoint2D new(this legendOffset + fontSize, start y)
		match (this lineStyle) {
			case LineStyle Dashed =>
				result = Shapes line(start, end, this lineWidth, this colorBgra, FloatPoint2D new((this lineWidth * 5) as Float, (this lineWidth * 5) as Float))
			case LineStyle Dotted =>
				result = Shapes line(start, end, this lineWidth, this colorBgra, FloatPoint2D new(this lineWidth as Float, this lineWidth as Float))
			case => // LineStyle Solid
				result = Shapes line(start, end, this lineWidth, this colorBgra)
		}
		result = result & Shapes text(FloatPoint2D new(end x, end y + fontSize / 3), this label, fontSize, this colorBgra)
		result
	}

	minValues: override func -> FloatPoint2D {
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

	maxValues: override func -> FloatPoint2D {
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
