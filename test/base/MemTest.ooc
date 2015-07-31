use ooc-math
use ooc-draw
use ooc-base
import math
import structs/Stack

Foo: class {
	bar := Bar new()
	init: func
	dispose: func {
//		this bar dispose()
		gc_free(this)
	}
}

Bar: class {
	x: Int
	init: func
	dispose: func { gc_free(this) }
}

while (false) {
	foo := Foo new()
	foo dispose()
//	gc_free(hog)
}

Dog: class {
	pool := static Stack<This> new()

	new: static func -> This {
		if (pool empty?()) {
			obj := This alloc()
			obj __defaults__()
			obj as Dog
		} else {
			pool pop()
		}
	}

	free: func {
		pool push(this)
	}
}
