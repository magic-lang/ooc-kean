use ooc-math
use ooc-draw
use ooc-base
use ooc-unit
import math
import structs/Stack

MemTest: class extends Fixture {
	init: func {
		super("MemTest [TODO: Not implemented as a fixture!]")
	}
}

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
			obj as This
		} else {
			pool pop()
		}
	}

	free: func {
		pool push(this)
	}
}
