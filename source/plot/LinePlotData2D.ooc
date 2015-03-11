use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D

LinePlotData2D: class extends PlotData2D {

	init: func ~default() {
		super()
	}
	init: func ~dataserie(dataSeries: VectorList<FloatPoint2D>) {
		super(dataSeries)
	}
	init: func ~label(dataSeries: VectorList<FloatPoint2D>, label: String) {
		super(dataSeries, label)
	}

	init: func ~color(dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		super(dataSeries, colorBgra)
	}

	init: func ~labelColor(dataSeries: VectorList<FloatPoint2D>, label: String, colorBgra: ColorBgra) {
		super(dataSeries,label,colorBgra)
	}

	getSVG: func (scaling: FloatPoint2D) -> String {
		result := ""
		if (!this dataSeries empty()) {
			result = result & "<path stroke='" clone() & this color clone() & "' stroke-opacity='" clone() & this opacity toString() & "' fill='none' stroke-width='" clone() & this lineWidth toString() & "' d='M " clone() & (scaling x * this dataSeries[0] x) toString() & " " clone() & (- scaling y * this dataSeries[0] y) toString() & " L " clone()
			for (j in 1..this dataSeries count) {
				result = result & (scaling x * this dataSeries[j] x) toString() & " " clone() & (- scaling y * this dataSeries[j] y) toString() & " " clone()
			}
			result = result & "'/>\n" clone()
		}
		result
	}

	getSvgLegend: func (legendCount: Int) -> String {
		boundaryOffset := 5
		result := "<text id='" clone() & this label clone() & "' x='" clone() & boundaryOffset toString() & "' y='" clone() & (this fontSize * legendCount + boundaryOffset) toString() & "' font-size='" clone() & this fontSize toString() & "' fill='" clone() & this color clone() & "' fill-opacity='" clone() & this opacity toString() & "'> ▬ " clone() & this label clone() & "</text>\n" clone()
		result
	}
}
