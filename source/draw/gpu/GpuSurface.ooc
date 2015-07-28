use ooc-math
use ooc-draw
use ooc-collections

import GpuContext

GpuSurface: abstract class {
	clearColor: ColorBgra { get set }
	viewport: IntBox2D { get set }
	_size: IntSize2D
	size ::= this _size
	_context: GpuContext
	projection: FloatTransform3D { get set }
	focalLength: Float { get set }
	nearPlane: Float { get set }
	farPlane: Float { get set }
	map: GpuMap { get set }
	init: func (=_size, =_context) { this reset() }
	reset: virtual func {
		this clearColor = ColorBgra new(0, 0, 0, 0)
		this viewport = IntBox2D new(this size)
		this focalLength = 3000.0f
		this nearPlane = 1.0f
		this farPlane = 10000.0f
		this projection = FloatTransform3D new(2.0f * this focalLength / this size width, 0.0f, 0.0f, 0.0f, 0.0f, 2.0f * this focalLength / this size height, 0.0f, 0.0f, 0.0f, 0.0f, -(this farPlane + this nearPlane) / (this farPlane - this nearPlane), -1.0f, 0.0f, 0.0f, -2.0f * this farPlane * this nearPlane / (this farPlane - this nearPlane), 0.0f)
	}
	_bind: virtual func
	_unbind: virtual func
	clear: abstract func
	draw: func ~general (action: Func) {
		this _bind()
		this _context setViewport(this viewport)
		action()
		this context drawQuad()
		this _unbind()
	}
	draw: abstract func (image: Image)
	drawLines: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawLines(pointList, this projection) }) }
	drawBox: virtual func (box: FloatBox2D) { this draw(func { this _context drawBox(box, this projection) }) }
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawPoints(pointList, this projection) }) }
}
