/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

SeekMode: enum {
	SET // seek to position `offset` in the file
	CUR // seek relative to the current read point
	END // seek relative to the end of data
}

Reader: abstract class {
	// Position in the stream. Not supported by all reader types
	marker: Long

	read: abstract func (chars: CString, offset: Int, count: Int) -> SizeT
	read: abstract func ~char -> Char
	read: func ~buffer (buffer: CharBuffer) -> SizeT {
		count := this read(buffer data, 0, buffer capacity)
		buffer size = count
		count
	}
	readAll: func -> String {
		in := CharBuffer new(4096)
		out := CharBuffer new(4096)
		while (this hasNext()) {
			readBytes := this read(in)
			out append(in, readBytes)
		}
		in free()
		out toString()
	}
	readUntil: func (end: Char) -> String {
		sb := CharBuffer new(1024)
		while (this hasNext()) {
			c := this read()
			if (c == end || (!this hasNext() && c == 8))
				break
			sb append(c)
		}
		sb toString()
	}
	readWhile: func ~filter (filter: Func(Char) -> Bool) -> String {
		sb := CharBuffer new(1024)
		while (this hasNext()) {
			c := this read()
			if (!filter(c)) {
				this rewind(1)
				break
			}
			sb append(c)
		}
		sb toString()
	}
	skipUntil: func (end: Char) {
		while (this hasNext()) {
			c := this read()
			if (c == end)
				break
		}
	}
	skipUntil: func ~str (end: String) {
		stop := false
		while (this hasNext() && !stop) {
			c := this read()
			i := 0
			while (c == end[i] && !stop) {
				c = this read()
				i += 1
				if (i >= end size)
					stop = true
			}
		}
	}
	skipWhile: func (unwanted: Char) {
		while (this hasNext()) {
			c := this read()
			if (c != unwanted) {
				this rewind(1)
				break
			}
		}
	}
	skipWhile: func ~filter (filter: Func(Char) -> Bool) {
		while (this hasNext()) {
			c := this read()
			if (!filter(c)) {
				this rewind(1)
				break
			}
		}
	}
	readLine: func -> String {
		line := this readUntil('\n')
		result := line trimRight('\r')
		line free()
		result
	}
	eachLine: func (f: Func(String) -> Bool) -> Bool {
		result := true
		while (this hasNext()) {
			if (!f(this readLine())) {
				result = false
				break
			}
		}
		result
	}
	peek: func -> Char {
		c := this read()
		this rewind(1)
		c
	}
	skipLine: func { this skipUntil('\n') }
	hasNext: abstract func -> Bool
	mark: abstract func -> Long
	rewind: func (offset: Int) -> Bool { this seek(-offset, SeekMode CUR) }
	seek: abstract func (offset: Long, mode: SeekMode) -> Bool
	reset: func (marker: Long) { this seek(marker, SeekMode SET) }
	skip: func (offset: Int) { this seek(offset, SeekMode CUR) }
}
