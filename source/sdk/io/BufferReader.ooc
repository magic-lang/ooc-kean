import io/Reader

/**
 * Implement the Reader interface for Buffer.
 */
BufferReader: class extends Reader {
	buffer: CharBuffer

	init: func ~withBuffer (=buffer)

	init: func ~withString (string: String) {
		this buffer = string _buffer
	}

	buffer: func -> CharBuffer {
		return buffer
	}

	close: override func {
		// nothing to close.
	}

	read: override func (dest: Char*, destOffset: Int, maxRead: Int) -> SizeT {
		if (marker >= buffer size) {
			Exception new(This, "Buffer overflow! Offset is larger than buffer size.") throw()
		}

		copySize := (marker + maxRead > buffer size ? buffer size - marker : maxRead)
		memcpy(dest, buffer data + marker, copySize)
		marker += copySize

		copySize
	}

	peek: func -> Char {
		buffer get(marker)
	}

	read: override func ~char -> Char {
		c := buffer get(marker)
		marker += 1
		c
	}

	hasNext?: override func -> Bool {
		return marker < buffer size
	}

	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		match mode {
			case SeekMode SET =>
				marker = offset
			case SeekMode CUR =>
				marker += offset
			case SeekMode END =>
				marker = buffer size + offset
		}
		_clampMarker()
		true
	}

	_clampMarker: func {
		if (marker < 0) {
			marker = 0
		}

		if (marker >= buffer size) {
			marker = buffer size - 1
		}
	}

	mark: override func -> Long {
		return marker
	}
}
