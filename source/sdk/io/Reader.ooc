/**
 * The reader interface provides a medium-indendant way to read characters
 * from a source, e.g. a file, a string, an URL, etc.
 */
Reader: abstract class {
	/** Position in the stream. Not supported by all reader types */
	marker: Long

	/**
	   Read 'count' bytes and store them in 'chars' with offset 'offset'
	   :return: The number of bytes read
	 */
	read: abstract func (chars: CString, offset: Int, count: Int) -> SizeT

	/**
	 * Read a single character, and return int
	 */
	read: abstract func ~char -> Char

	/**
	 * Read a bufferfull at most, and return the number of bytes read
	 */
	read: func ~buffer (buffer: Buffer) -> SizeT {
		count := read(buffer data, 0, buffer capacity)
		buffer size = count
		count
	}

	/**
	 * Read till the end of stream, return result as a string.
	 */
	readAll: func -> String {
		in := Buffer new(4096)
		out := Buffer new(4096)
		while (hasNext?()) {
			readBytes := read(in)
			out append(in, readBytes)
		}
		out toString()
	}

	/**
	   Read the stream until character `end` is reached, and return
	   the result

	   Note that the `end` character is consumed, e.g. the stream isn't
	   rewinded once `end` has been read.
	 */
	readUntil: func (end: Char) -> String {
		sb := Buffer new(1024) // let's be pragmatic
		while (hasNext?()) {
			c := read()
			// FIXME this behaviour would lead to errors when reading a binary file
			// for some reason, some files end with the ASCII character 8, ie. BackSpace.
			// we definitely don't want that to end up in the String.
			if (c == end || (!hasNext?() && c == 8)) {
				break
			}
			sb append(c)
		}
		return sb toString()
	}

	readWhile: func ~filter (filter: Func(Char) -> Bool) -> String {
		sb := Buffer new(1024) // let's be pragmatic
		while (hasNext?()) {
			c := read()
			if (!filter(c)) {
				rewind(1)
				break
			}
			sb append(c)
		}
		return sb toString()
	}

	/**
	   Read the stream until character `end` is reached.

	   Acts as readUntil(), but doesn't return the result. This saves a
	   buffer allocation.

	   Note that the `end` character is consumed, e.g. the stream isn't
	   rewinded once `end` has been read.
	 */
	skipUntil: func (end: Char) {
		while (hasNext?()) {
			c := read()
			if (c == end) break
		}
	}

	skipUntil: func ~str (end: String) {
		while (hasNext?()) {
			c := read()
			i := 0
			while (c == end[i]) {
				c = read()
				i += 1
				if (i >= end size) return // caught it!
			}
		}
	}

	/**
	   Read as many `unwanted` chars as
	 */
	skipWhile: func (unwanted: Char) {
		while (hasNext?()) {
			c := read()
			if (c != unwanted) {
				rewind(1)
				break
			}
		}
	}

	skipWhile: func ~filter (filter: Func(Char) -> Bool) {
		while (hasNext?()) {
			c := read()
			if (!filter(c)) {
				rewind(1)
				break
			}
		}
	}

	/**
	   Read a single line and return it.

	   More specifically, read until a '\n', trim any '\r' character
	   and return the result
	 */
	readLine: func -> String {
		line := readUntil('\n')
		result := line trimRight('\r')
		line free()
		result
	}

	/**
	   Skip a single line.

	   More specifically, skip until a '\n' character is reached.
	   The final '\n' is consumed, ie. the stream isn't rewinded.
	 */
	skipLine: func {
		skipUntil('\n')
	}

	/**
	   Read every line, and call `f` on it until `f` returns false
	   or we have reached the end of the file.

	   :return: true if we have reached the end of the file, false
	   if we were cancelled by `f` returning false.
	 */
	eachLine: func (f: Func(String) -> Bool) -> Bool {
		while (hasNext?()) {
			if (!f(readLine())) return false
		}
		true
	}

	/**
	   Attempts to read one character and then rewind the stream
	   by one.

	   If the underlying reader doesn't support rewinding, this may
	   result in a runtime exception.
	 */
	peek: func -> Char {
		c := read()
		rewind(1)
		c
	}

	/**
	   :return: true if there's some more data to be read, false if
	   we're at end-of-file.

	   Note that it doesn't guarantee that any data is *ready* to be read.
	   calling read() just after hasNext?() has returned true may well
	   return 0, depending on which kind of reader you're dealing with.
	 */
	hasNext?: abstract func -> Bool

	/**
	   Set the mark of this stream to the current position,
	   and return it as a long.
	 */
	mark: abstract func -> Long

	/**
	   Attempt to rewind this stream by the given offset.
	 */
	rewind: func (offset: Int) -> Bool {
		seek(-offset, SeekMode CUR)
	}

	/**
	 * Seeks to offset relative to whence
	 *
	 * Might throw an exception if the stream is not seekable
	 *
	 * :return: true on success
	 */
	seek: abstract func (offset: Long, mode: SeekMode) -> Bool

	/**
	   Attempt to reset the stream to the given mark
	 */
	reset: func (marker: Long) {
		seek(marker, SeekMode SET)
	}

	/**
	   Skip the given number of bytes.
	   If `offset` is negative, we will attempt to rewind the stream
	 */
	skip: func (offset: Int) {
		seek(offset, SeekMode CUR)
	}

	/**
	   Close this reader and free the associated system resources, if any.
	 */
	close: abstract func
}

SeekMode: enum {
	/** seek to position `offset` in the file */
	SET

	/** seek relative to the current read point */
	CUR

	/** seek relative to the end of data */
	END
}

SeekingNotSupported: class extends Exception {
	init: func (.origin) {
		super(origin, "Seeking is not supported for this source")
	}
}
