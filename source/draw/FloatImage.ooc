use geometry

FloatImage : class {
	// x = column
	// y = row
	_size: IntVector2D
	_pointer: Float*
	size ::= _size
	pointer ::= this _pointer
	init: func ~IntVector2D (=_size)
	init: func ~WidthAndHeight (width, height: Int) {
		this _size = IntVector2D new(width, height)
		this _pointer = gc_malloc(width * height * Float instanceSize)
	}

	free: override func {
		gc_free(this _pointer)
		super()
	}
	operator [] (x, y: Int) -> Float {
		version(safe) {
			if (x > _size x || y > _size y || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in get")
		}
		(this _pointer + (x + this _size x * y))@ as Float
	}

	operator []= (x, y: Int, value: Float) {
		version(safe) {
			if (x > _size x || y > _size y || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in set")
		}
		(this _pointer + (x + this _size x * y))@ = value
	}
}
