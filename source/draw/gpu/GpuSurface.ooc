use ooc-math
use ooc-draw

import GpuContext

GpuSurface: abstract class {
	clearColor: ColorBgra { get set }
	viewport: IntBox2D { get set }
	_size: IntSize2D
	_projection: FloatTransform2D
	_context: GpuContext
	init: func (=_size, =_context, =_projection) {
		this clearColor = ColorBgra new(0, 0, 0, 0)
		this viewport = IntBox2D new(this _size)
	}
	// Postcondition: Returns the transform to apply directly to a quad for rendering with compensation for aspect ratio.
	getFinalTransform: static func (imageSize: IntSize2D, transform: FloatTransform2D) -> FloatTransform2D {
		toReference := FloatTransform2D createScaling(imageSize width / 2.0f, imageSize height / 2.0f)
		toNormalized := FloatTransform2D createScaling(2.0f / imageSize width, 2.0f / imageSize height)
		toNormalized * transform * toReference
	}
}
