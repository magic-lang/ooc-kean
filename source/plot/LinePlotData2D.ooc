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

	init: func ~default (lineStyle := LineStyle Solid) {
		super()
		this lineStyle = lineStyle
	}

	init: func ~dataSeries (dataSeries: VectorList<FloatPoint2D>, label := "", colorBgra := ColorBgra new(), lineStyle := LineStyle Solid) {
		super(dataSeries, label, colorBgra)
		this lineStyle = lineStyle
	}

	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra, lineStyle := LineStyle Solid) {
		this init(dataSeries, "", colorBgra, lineStyle)
	}

	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new(), lineStyle := LineStyle Solid) {
		super(xSeries, ySeries, label, colorBgra)
		this lineStyle = lineStyle
	}

	getSvg: func (transform: FloatTransform2D) -> String {
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

	getSvgLegend: func (legendCount, fontSize: Int) -> String {
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
		result = result & Shapes text(FloatPoint2D new(end x, end y + fontSize / 3), this label, fontSize, this opacity, this color)
		result
	}
}
