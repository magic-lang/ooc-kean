CharBufferIterator: class <T> extends BackIterator<T> {
	i := 0
	str: CharBuffer

	init: func ~withStr (=str)

	hasNext?: override func -> Bool {
		i < str size
	}

	next: override func -> T {
		c := (str data + i)@
		i += 1
		c
	}

	hasPrev?: override func -> Bool {
		i > 0
	}

	prev: override func -> T {
		i -= 1
		(str data + i)@
	}

	remove: override func -> Bool { false } // this could be implemented!
}
