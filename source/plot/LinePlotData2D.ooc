use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D

LinePlotData2D: class extends PlotData2D {

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
			result += "<path stroke='" + this color + "' stroke-opacity='" + this opacity toString() + "' fill='none' stroke-width='" + this lineWidth toString() + "' d='M " + (scaling x * this dataSerie[0] x) toString() + " " + (- scaling y * this dataSerie[0] y) toString() + " L "
			for (j in 1..this dataSerie count) {
				result += (scaling x * this dataSerie[j] x) toString() + " " + (- scaling y * this dataSerie[j] y) toString() + " "
			}
			result += "'/>"
		}
		result
	}

	getSvgLegend: func(legendCount: Int) -> String {
		boundaryOffset:=5
		result:= "<text id='" + this label + "' x='" + boundaryOffset + "' y='" + (this fontSize * legendCount + boundaryOffset) toString() + "' font-size='" + this fontSize toString() + "' fill='" + this color + "' fill-opacity='" + this opacity toString() + "'> ▬ " + this label + "</text>"
		result
	}
}
