use ooc-collections
use ooc-math
use ooc-draw
import math
import PlotData2D
import svg/Shapes

AnyShape: cover {
	shape: Shape
	region: FloatBox2D
	colorBgra: ColorBgra
	init: func@ (=shape, =region, =colorBgra)
}
ShapePlotData2D: class extends PlotData2D {
	_shapes: VectorList<AnyShape>
	init: func (label := "", colorBgra := ColorBgra new()) {
		super(label, colorBgra)
		this _shapes = VectorList<AnyShape> new()
	}
	addRectangle: func (box: FloatBox2D, colorBgra := ColorBgra new()) {
		this _shapes add(AnyShape new(Shape Rectangle, box, colorBgra))
	}
	addCircle: func (center: FloatPoint2D, radius: Float, colorBgra := ColorBgra new()) {
		this addEllipse(center, radius, radius, colorBgra)
	}
	addEllipse: func (center: FloatPoint2D, radiusX, radiusY: Float, colorBgra := ColorBgra new()) {
		this _shapes add(AnyShape new(Shape Ellipse, FloatBox2D new(center x - radiusX, center y - radiusY, radiusX * 2.0f, radiusY * 2.0f), colorBgra))
	}
	free: override func {
		this _shapes free()
		super()
	}
	getSvg: func (transform: FloatTransform2D) -> String {
		result := ""
		if (!this _shapes empty) {
			noneColor := ColorBgra new(0, 0, 0, 0)
			for (i in 0 .. this _shapes count) {
				object := this _shapes[i]
				pointA := transform * (object region leftTop)
				pointB := transform * (object region rightBottom)
				area := FloatBox2D new(pointA, pointB)
				color := (noneColor == object colorBgra) ? this colorBgra : object colorBgra
				match (this _shapes[i] shape) {
					case Shape Rectangle =>
						result = result & Shapes rect(area left, area top, area width, area height, color)
					case Shape Ellipse =>
						result = result & Shapes ellipse(area center, area width * 0.5f, area height * 0.5f, color)
					case =>
						// Unknown shapes are drawn as red boxes
						result = result & Shapes rect(area left, area top, area width, area height, colorBgra new(0, 0, 255, 255))
				}
			}
		}
		result
	}
	getSvgLegend: func (legendCount, fontSize: Int) -> String {
		result := ""
		start := FloatPoint2D new(this legendOffset as Float, this legendOffset + (fontSize * legendCount) as Float - (fontSize as Float) / 2.0f)
		size := 0.8f * fontSize
		halfLineHeight := 0.5f * fontSize
		result = result & Shapes rect(FloatPoint2D new(start x, start y - halfLineHeight), FloatPoint2D new(size, size), this colorBgra)
		result & Shapes text(FloatPoint2D new(start x + fontSize as Float, start y + halfLineHeight), this label, fontSize, this colorBgra)
	}
	minValues: override func -> FloatPoint2D {
		result: FloatPoint2D
		if (this _shapes empty)
			result = FloatPoint2D new()
		else {
			object := this _shapes[0]
			result = object region leftTop
			for (i in 1 .. this _shapes count) {
				object := this _shapes[i]
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
			object := this _shapes[0]
			result = object region rightBottom
			for (i in 1 .. this _shapes count) {
				object := this _shapes[i]
				result = result maximum(object region rightBottom)
			}
		}
		result
	}
}
