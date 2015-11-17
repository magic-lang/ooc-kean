use ooc-draw
use ooc-collections
use ooc-math

PlotData2D: abstract class {
	label: String
	lineWidth: Float = 1.0f
	legendOffset: Float = 5.0f
	colorBgra: ColorBgra
	init: func (=label, =colorBgra)
	free: override func {
		this label free()
		super()
	}
	getSvg: abstract func (transform: FloatTransform2D) -> String
	getSvgLegend: abstract func (legendCount, fontSize: Int) -> String
	minValues: abstract func -> FloatPoint2D
	maxValues: abstract func -> FloatPoint2D
}
