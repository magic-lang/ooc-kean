use ooc-draw
use ooc-collections
use ooc-math

PlotData2D: abstract class {
	label: String { get set}
	fontSize: Int { get set }
	lineWidth: Float { get set }
	colorBgra: ColorBgra { get set }
	color: String { get set }
	opacity: Float { get set }
	dataSeries: VectorList<FloatPoint2D> { get set }

	init: func ~default() {
		this init(VectorList<FloatPoint2D> new(), "")
	}
	init: func ~dataserie(dataSeries: VectorList<FloatPoint2D>) {
		this dataSeries = dataSeries
		this lineWidth = 1
		this fontSize = 14
		if (this label == null)
			this label = ""
	}
	init: func ~label(dataSeries: VectorList<FloatPoint2D>, label: String) {
		this label = label
		this init(dataSeries)
	}

	init: func ~color(dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		this colorBgra = colorBgra
		this init(dataSeries)
	}

	init: func ~labelColor(dataSeries: VectorList<FloatPoint2D>, label: String, colorBgra: ColorBgra) {
		this label = label
		this colorBgra = colorBgra
		this init(dataSeries)
	}

	getSVG: abstract func (scaling: FloatPoint2D) -> String
	getSvgLegend: abstract func(legendCount: Int) -> String

	minValues: func -> FloatPoint2D {
		result: FloatPoint2D
		if (dataSeries empty())
			result = FloatPoint2D new()
		else {
			result = dataSeries[0]
			for (i in 1..dataSeries count)
				result = result minimum(dataSeries[i])
		}
		result
	}

	maxValues: func -> FloatPoint2D {
		result: FloatPoint2D
		if (dataSeries empty())
			result = FloatPoint2D new()
		else {
			result = dataSeries[0]
			for (i in 1..dataSeries count)
				result = result maximum(dataSeries[i])
		}
		result
	}
}
