use ooc-collections
use ooc-math
use ooc-draw
import math
import PlotData2D
import svg/Shapes

AnyShape: cover {
	shape: Shape
	region: FloatBox2D
	init: func@ (=shape, =region)
}

ShapePlotData2D: class extends PlotData2D {
	_shapes: VectorList<AnyShape>

	init: func (label := "", colorBgra := ColorBgra new()) {
		super(label, colorBgra)
		this _shapes = VectorList<AnyShape> new()
	}

	addRectangle: func (box: FloatBox2D) {
		this _shapes add(AnyShape new(Shape Rectangle, box))
	}

	free: override func {
		this _shapes free()
		super()
	}

	getSvg: func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this _shapes empty) {
			for (i in 0 .. this _shapes count) {
				object := this _shapes[i]
				pointA := transform * (object region leftTop)
				pointB := transform * (object region rightBottom)
				area := FloatBox2D new(pointA, pointB)
				match (this _shapes[i] shape) {
					case Shape Rectangle =>
						result = result & Shapes rect(area left, area top, area width, area height, this opacity, this color)
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
		result = result & Shapes rect(FloatPoint2D new(start x, start y - halfLineHeight), FloatPoint2D new(size, size), this opacity, this color)
		result = result & Shapes text(FloatPoint2D new(start x + fontSize as Float, start y + halfLineHeight), this label, fontSize, this opacity, this color)
		result
	}

	minValues: override func -> FloatPoint2D {
		result: FloatPoint2D
		if (this _shapes empty)
			result = FloatPoint2D new()
		else {
			object := this _shapes[0] // Convert rvalue to lvalue
			result = object region leftTop
			for (i in 1 .. this _shapes count) {
				object := this _shapes[i] // Convert rvalue to lvalue
				result = result minimum(object region leftTop)
			}
		}
		result
	}

	maxValues: override func -> FloatPoint2D {
		result: FloatPoint2D
		if (this _shapes empty)
			result = FloatPoint2D new()
		else {
			object := this _shapes[0] // Convert rvalue to lvalue
			result = object region rightBottom
			for (i in 1 .. this _shapes count) {
				object := this _shapes[i] // Convert rvalue to lvalue
				result = result maximum(object region rightBottom)
			}
		}
		result
	}
}
