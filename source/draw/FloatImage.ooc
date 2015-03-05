import math, math
use ooc-math
FloatImage : class {
	// x = column
	// y = row
  _size: IntSize2D
	size ::= _size
	_imagePointer: Float*
	init: func ~IntSize2D (=_size)
	init: func ~WidthAndHeight (width: Int, height: Int) {
		this _size = IntSize2D new(width, height)
		this _imagePointer = gc_malloc(width * height * Float instanceSize)
	}
  operator [] (x, y: Int) -> Float { (this _imagePointer + ( x + this _size width * y))@ as Float }
  operator []= (x, y: Int, value: Float) { (this _imagePointer + ( x  + this _size width * y))@ = value}
}
