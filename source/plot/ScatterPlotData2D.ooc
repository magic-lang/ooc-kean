use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import svg/Shapes

Shape: enum {
	Circle
	Square
}

ScatterPlotData2D: class extends PlotData2D {
	shape := Shape Circle
	scalingRelativeLineWidth := 5.0f
	init: func ~default {
		super()
	}
	init: func ~dataSeries (dataSeries: VectorList<FloatPoint2D>, label := "", colorBgra := ColorBgra new()) {
		super(dataSeries, label, colorBgra)
	}
	init: func ~color (dataSeries: VectorList<FloatPoint2D>, colorBgra: ColorBgra) {
		super(dataSeries, "", colorBgra)
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new()) {
		super(xSeries, ySeries, label, colorBgra)
	}
	getSvg: func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this dataSeries empty) {
			for (i in 0 .. this dataSeries count) {
				match (this shape) {
					case Shape Circle =>
						r := this scalingRelativeLineWidth / 2.0f * this lineWidth
						result = result & Shapes circle(FloatPoint2D new((transform * this dataSeries[i]) x, (transform * dataSeries[i]) y), r, this opacity, this color)
					case Shape Square =>
						x := (transform * this dataSeries[i]) x - this scalingRelativeLineWidth / 2.0f * this lineWidth
						y := (transform * this dataSeries[i]) y - this scalingRelativeLineWidth / 2.0f * this lineWidth
						width := this scalingRelativeLineWidth * this lineWidth
						result = result & Shapes rect(x, y, width, width, this opacity, this color)
					case =>
						result = result >> ""
				}
			}
		}
		result
	}
	getSvgLegend: func (legendCount, fontSize: Int) -> String {
		result := ""
		start := FloatPoint2D new(this legendOffset as Float, this legendOffset + (fontSize * legendCount) as Float - (fontSize as Float) / 2.0f)
		size := (fontSize as Float) * 0.8f
		halfLineHeight := (fontSize as Float) / 2.0f
		match (this shape) {
			case Shape Circle =>
				result = result & Shapes circle(FloatPoint2D new(start x + halfLineHeight, start y), size / 2.0f, this opacity, this color)
			case Shape Square =>
				result = result & Shapes rect(FloatPoint2D new(start x, start y - halfLineHeight), FloatPoint2D new(size, size), this opacity, this color)
			case =>
		}
		result & Shapes text(FloatPoint2D new(start x + fontSize as Float, start y + halfLineHeight), this label, fontSize, this opacity, this color)
	}
}
