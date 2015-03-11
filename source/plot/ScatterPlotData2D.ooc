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
	shape:= Shape CIRCLE
	scalingRelativeLineWidth:= 3.0f

	init: func ~default() {
		super()
	}
	init: func ~dataserie(dataSerie: VectorList<FloatPoint2D>) {
		super(dataSerie)
	}
	init: func ~label(dataSerie: VectorList<FloatPoint2D>, label: String) {
		super(dataSerie, label)
	}
	init: func ~color(dataSerie: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		super(dataSerie, colorBgra)
	}
	init: func ~labelColor(dataSerie: VectorList<FloatPoint2D>, label: String, colorBgra: ColorBgra) {
		super(dataSerie,label,colorBgra)
	}

	getSVG: func(scaling: FloatPoint2D) -> String {
		result:= ""
		if (!this dataSerie empty()) {
			for(i in 0..this dataSerie count) {
				match (this shape) {

					case Shape CIRCLE =>
						r:= this scalingRelativeLineWidth / 2.0f * this lineWidth
						result += Shapes circle(scaling x * this dataSerie[i] x, - scaling y * this dataSerie[i] y, r, this opacity, this color)

					case Shape SQUARE =>
						x:= scaling x * this dataSerie[i] x - this scalingRelativeLineWidth / 2.0f * this lineWidth
						y:= -scaling y * this dataSerie[i] y - this scalingRelativeLineWidth / 2.0f * this lineWidth
						width:= this scalingRelativeLineWidth * this lineWidth
						result += Shapes rect(x, y, width, width, this opacity, this color)
				}

			}
		}
		result
	}

	getSvgLegend: func(legendCount: Int) -> String {
		boundaryOffset:=5
		symbol:=""
		match (this shape) {
			case Shape CIRCLE =>
				symbol = "•"
			case Shape SQUARE =>
				symbol = "■"
		}
		result:="<text id='" + this label + "' x='" + boundaryOffset + "' y='" + (this fontSize * legendCount + boundaryOffset) toString() + "' font-size='" + this fontSize toString() + "' fill='" + this color + "' fill-opacity='" + this opacity toString() + "'> " + symbol + "	" + this label + "</text>"
		result
	}

}
