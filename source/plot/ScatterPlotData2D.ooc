use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import svg/Shapes

Shape: enum {
	CIRCLE
	SQUARE
}

ScatterPlotData2D: class extends PlotData2D {
	shape := Shape CIRCLE
	scalingRelativeLineWidth:= 5.0f

	init: func ~default() {
		super()
	}

	init: func ~dataSeries(dataSeries: VectorList<FloatPoint2D>, label := "", colorBgra := ColorBgra new()) {
			super(dataSeries, label, colorBgra)
	}

	init: func ~color(dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
			super(dataSeries, "", colorBgra)
	}

	getSVG: func (scaling: FloatPoint2D) -> String {
		result := ""
		if (!this dataSeries empty()) {
			for (i in 0..this dataSeries count) {
				match (this shape) {

					case Shape CIRCLE =>
						r := this scalingRelativeLineWidth / 2.0f * this lineWidth
						result = result & Shapes circle(scaling x * this dataSeries[i] x, - scaling y * this dataSeries[i] y, r, this opacity, this color)

					case Shape SQUARE =>
						x := scaling x * this dataSeries[i] x - this scalingRelativeLineWidth / 2.0f * this lineWidth
						y := -scaling y * this dataSeries[i] y - this scalingRelativeLineWidth / 2.0f * this lineWidth
						width := this scalingRelativeLineWidth * this lineWidth
						result = result & Shapes rect(x, y, width, width, this opacity, this color)
				}
			}
		}
		result
	}

	getSvgLegend: func (legendCount: Int) -> String {
		boundaryOffset := 5
		symbol: String
		match (this shape) {
			case Shape CIRCLE =>
				symbol = "•"
			case Shape SQUARE =>
				symbol = "■"
			case =>
				symbol = ""
		}
		result := "<text id='" clone() & this label clone() & "' x='" clone() & boundaryOffset toString() & "' y='" clone() & (this fontSize * legendCount + boundaryOffset) toString() & "' font-size='" clone() & this fontSize toString() & "' fill='" clone() & this color clone() & "' fill-opacity='" clone() & this opacity toString() & "'> " clone() & symbol clone() & "	" clone() & this label clone() & "</text>\n" clone()
		result
	}
}
