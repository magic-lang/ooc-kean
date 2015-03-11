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
	dataSerie: VectorList<FloatPoint2D> { get set }

	init: func ~default() {
		this init(VectorList<FloatPoint2D> new(), "")
	}
	init: func ~dataserie(dataSerie: VectorList<FloatPoint2D>) {
		this dataSerie = dataSerie
		this lineWidth = 1
		this fontSize = 14
		if (this label == null)
			this label = ""
	}
	init: func ~label(dataSerie: VectorList<FloatPoint2D>, label: String) {
		this label = label
		this init(dataSerie)
	}

	init: func ~color(dataSerie: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		this colorBgra = colorBgra
		this init(dataSerie)
	}

	init: func ~labelColor(dataSerie: VectorList<FloatPoint2D>, label: String, colorBgra: ColorBgra) {
		this label = label
		this colorBgra = colorBgra
		this init(dataSerie)
	}

	getSVG: abstract func(scaling: FloatPoint2D) -> String
	getSvgLegend: abstract func(legendCount: Int) -> String

	minValues: func() -> FloatPoint2D {
		result: FloatPoint2D
		if (dataSerie empty())
			result = FloatPoint2D new()
		else {
			result = dataSerie[0]
			for (i in 1..dataSerie count)
				result = result minimum(dataSerie[i])
		}
		result
	}

	maxValues: func() -> FloatPoint2D {
		result: FloatPoint2D
		if (dataSerie empty())
			result = FloatPoint2D new()
		else {
			result = dataSerie[0]
			for (i in 1..dataSerie count)
				result = result maximum(dataSerie[i])
		}
		result
	}
}
