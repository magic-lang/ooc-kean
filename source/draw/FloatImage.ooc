import math, math
use ooc-math
FloatImage : class {
	// x = column
	// y = row
	_size: IntSize2D
	size ::= _size
	_pointer: Float*
	pointer ::= this _pointer
	init: func ~IntSize2D (=_size)
	init: func ~WidthAndHeight (width, height: Int) {
		this _size = IntSize2D new(width, height)
		this _pointer = gc_malloc(width * height * Float instanceSize)
	}

	operator [] (x, y: Int) -> Float {
		version(safe) {
			if (x > _size width || y > _size height || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in get")
		}
		(this _pointer + (x + this _size width * y))@ as Float
	}

	operator []= (x, y: Int, value: Float) {
		version(safe) {
			if (x > _size width || y > _size height || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in set")
		}
		(this _pointer + (x + this _size width * y))@ = value
	}
	free: override func {
		gc_free(this _pointer)
		super()
	}
}
