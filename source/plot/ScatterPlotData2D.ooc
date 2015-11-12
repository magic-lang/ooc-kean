use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import svg/Shapes

ScatterPlotData2D: class extends PlotData2D {
	shape := Shape Circle
	scalingRelativeLineWidth := 5.0f
	dataSeries: VectorList<FloatPoint2D> { get set }
	init: func ~default {
		super("", ColorBgra new())
		this dataSeries = VectorList<FloatPoint2D> new()
	}
	init: func ~dataSeries (=dataSeries, label := "", colorBgra := ColorBgra new()) {
		super(label, colorBgra)
	}
	init: func ~color (=dataSeries, colorBgra: ColorBgra) {
		super("", colorBgra)
	}
	init: func ~twoFloatSeries (xSeries, ySeries: VectorList<Float>, label := "", colorBgra := ColorBgra new()) {
		super(label, colorBgra)
		this dataSeries = VectorList<FloatPoint2D> new()
		for (i in 0 .. ySeries count)
			this dataSeries add(FloatPoint2D new(xSeries != null ? xSeries[i] : (i + 1) as Float, ySeries[i]))
	}
	free: override func {
		this dataSeries free()
		super()
	}
	getSvg: func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this dataSeries empty) {
			for (i in 0 .. this dataSeries count) {
				match (this shape) {
					case Shape Circle =>
						r := this scalingRelativeLineWidth / 2.0f * this lineWidth
						result = result & Shapes circle(FloatPoint2D new((transform * this dataSeries[i]) x, (transform * this dataSeries[i]) y), r, this colorBgra)
					case Shape Square =>
						x := (transform * this dataSeries[i]) x - this scalingRelativeLineWidth / 2.0f * this lineWidth
						y := (transform * this dataSeries[i]) y - this scalingRelativeLineWidth / 2.0f * this lineWidth
						width := this scalingRelativeLineWidth * this lineWidth
						result = result & Shapes rect(x, y, width, width, this colorBgra)
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
				result = result & Shapes circle(FloatPoint2D new(start x + halfLineHeight, start y), size / 2.0f, this colorBgra)
			case Shape Square =>
				result = result & Shapes rect(FloatPoint2D new(start x, start y - halfLineHeight), FloatPoint2D new(size, size), this colorBgra)
			case =>
		}
		result & Shapes text(FloatPoint2D new(start x + fontSize as Float, start y + halfLineHeight), this label, fontSize, this colorBgra)
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
