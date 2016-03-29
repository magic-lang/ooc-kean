/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdio | (_POSIX_SOURCE)

stdout, stderr, stdin: extern FStream

println: func ~withCStr (str: Char*) {
	fputs(str, stdout)
	println()
}

println: func ~withStr (str: String) {
	println(str toCString())
}

println: func {
	fputc('\n', stdout)
}

// input/output
open: extern func (Char*, Int, ...) -> Int
fdopen: extern func (Int, Char*) -> FStream
mkstemp: extern func (Char*) -> Int
mktemp: extern func (Char*) -> CString

printf: extern func (Char*, ...) -> Int

fprintf: extern func (FStream, Char*, ...) -> Int
sprintf: extern func (Char*, Char*, ...) -> Int
snprintf: extern func (Char*, Int, Char*, ...) -> Int

vsnprintf: extern func (Char*, Int, Char*, VaList) -> Int

fread: extern func (ptr: Pointer, size: SizeT, nmemb: SizeT, stream: FStream) -> SizeT
fwrite: extern func (ptr: Pointer, size: SizeT, nmemb: SizeT, stream: FStream) -> SizeT
feof: extern func (stream: FStream) -> Int

fopen: extern func (Char*, Char*) -> FStream
fclose: extern func (file: FILE*) -> Int
fflush: extern func (file: FILE*)

fputc: extern func (Char, FStream)
fputs: extern func (Char*, FStream)

scanf: extern func (format: Char*, ...) -> Int
fscanf: extern func (stream: FStream, format: Char*, ...) -> Int
sscanf: extern func (str, format: Char*, ...) -> Int

fgets: extern func (str: Char*, length: SizeT, stream: FStream) -> Char*
fgetc: extern func (stream: FStream) -> Int

SEEK_CUR, SEEK_SET, SEEK_END: extern Int
fseek: extern func (stream: FStream, offset: Long, origin: Int) -> Int
ftell: extern func (stream: FStream) -> Long

ferror: extern func (stream: FStream) -> Int

FILE: extern cover

EOF: extern Int

EAGAIN, EWOULDBLOCK, EBADF, EDESTADDRREQ, EFAULT, EFBIG, EINTR, EINVAL, EIO, ENOSPC, EPIPE: extern Int

/**
 * Low-level interface with the C I/O API.
 *
 * FileWriter and FileReader use this cover to implement their functionality,
 * so that for non-C backends, it will be easier to reimplement them
 */
FStream: cover from FILE* {
	NON_BLOCKING: extern (O_NONBLOCK) static Int
	READ_ONLY: extern (O_RDONLY) static Int
	WRITE_ONLY: extern (O_WRONLY) static Int

	/**
	 * Open a file with the given mode
	 *
	 * "r" = for reading
	 * "w" = for writing
	 * "r+" = for reading and writing
	 *
	 * suffix "a" = appending
	 * suffix "b" = binary mode
	 * suffix "t" = text mode (warning: tell/seek are unreliable in text mode under mingw32)
	 */
	open: static func (filename, mode: String) -> This {
		fopen(filename, mode)
	}

	open: static func ~withFlags (filename, mode: String, flags: Int) -> This {
		fd := open(filename, flags)
		fd >= 0 ? fdopen(fd, mode) : null
	}

	/**
	 * Close this file descriptor
	 */
	close: extern (fclose) func -> Int

	/**
	 * @return the file descriptor associated to this File
	 */
	no: extern (fileno) func -> Int

	/**
	 * Tests the error indicator for the stream
	 *
	 * @return a non-zero value if the error indicator is set
	 */
	error: extern (ferror) func -> Int

	/**
	 * Tests the end-of-file indicator for the stream
	 *
	 * @return true if the end-of-file indicator was set, ie. if a read
	 * was attempted and the end of the file was reached.
	 *
	 * It's important to understand that if you're *just* at the end of
	 * the file, and you call eof?() it will return false. Then if you
	 * try to read it will read 0 bytes, and *then* eof?() will return true.
	 *
	 * That's how C I/O works.
	 */
	eof: func -> Bool {
		feof(this) != 0
	}

	/**
	 * Sets the position of the marker in this stream to the given offset.
	 *
	 * @param origin One of
	 *   - SEEK_CUR offset is relative to current stream position, ie. -1 goes one byte back
	 *   - SEEK_SET offset is relative to the beginning of the stream
	 *   - SEEK_END offset is relative to the end of the stream
	 *
	 * @return 0 if successful. Note that some streams aren't seekable.
	 * Local files usually are, though :)
	 */
	seek: func (offset: Long, origin: Int) -> Int {
		fseek(this, offset, origin)
	}

	/**
	 * @return the position of the marker in this stream
	 */
	tell: extern (ftell) func -> Long

	/**
	 * Flush the buffers associated to this file descriptor.
	 *
	 * I/O operations are usually buffered to increase performance, ie.
	 * they're not immediately applied, but put in a buffer and when the
	 * buffer is full it is flushed, ie. applied. This makes sure all
	 * operations are applied.
	 */
	flush: extern (fflush) func

	/**
	 * Read at most `bytesToRead` bytes into `dest`.
	 *
	 * @param dest Pointer to a memory block large enough to hold up to
	 * `bytesToRead` bytes.
	 * @param bytesToRead Maximum number of bytes to be read. It might
	 * read exactly `bytesToRead` bytes, or less, or even none.
	 *
	 * @return The number of bytes read.
	 */
	read: func (dest: Pointer, bytesToRead: SizeT) -> SizeT {
		fread(dest, 1, bytesToRead, this)
	}

	readChar: func -> Char {
		c := '\0'
		count := fread(c&, 1, 1, this)
		if (count != 1 && this error()) {
			Exception new("Trying to read a char at the end of a file!") throw()
		}
		c
	}

	readLine: func ~defaults -> String {
		this readLine(1023)
	}

	readLine: func (chunk: Int) -> String {
		length := 1023
		buf := CharBuffer new (length)

		// while it's not '\n' it means not all the line has been read
		while (true) {
			c := fgetc(this)
			if (c == EOF) break
			if (c == '\n') break
			buf append((c & 0xFF) as Char)
			if (!this hasNext()) break
		}

		buf toString()
	}

	/**
	 * @return the size of this file descriptor, in bytes, if it can be
	 * estimated.
	 */
	getSize: func -> SSizeT {
		result: SSizeT = 0
		prev := this tell()
		if (prev >= 0 && seek(0, SEEK_END) != -1) {
			result = this tell() as SizeT
			if (seek(prev, SEEK_SET) == -1)
				result = 0
		}
		result
	}

	/**
	 * @see eof?()
	 */
	hasNext: func -> Bool {
		feof(this) == 0
	}

	/**
	 * Writes one byte to this stream
	 */
	write: func ~chr (chr: Char) {
		fputc(chr, this)
	}

	/**
	 * Write a string to this stream.
	 *
	 * @param str The string to write
	 */
	write: func ~str (str: String) {
		fputs(str _buffer data, this)
	}

	/**
	 * Write part of a string to this stream, up to length
	 *
	 * @param str The string to write
	 * @param length The number of bytes to write, must be <= str's length.
	 */
	write: func ~withLength (str: String, length: SizeT) -> SizeT {
		write(str _buffer data, 0, length)
	}

	/**
	 * Write part of a string to this stream, up to length, beginning from offset
	 *
	 * @param str
	 * offset + length must be <= strlen(str)
	 */
	write: func ~precise (str: Char*, offset: SizeT, length: SizeT) -> SizeT {
		fwrite(str + offset, 1, length, this)
	}
}
