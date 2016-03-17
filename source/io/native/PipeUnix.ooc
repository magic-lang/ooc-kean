/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include sys/types, sys/stat
include fcntl
import ../Pipe

version(unix || apple) {
F_SETFL, F_GETFL: extern Int
O_NONBLOCK: extern Int
EAGAIN: extern Int

fcntl: extern func (_FileDescriptor, Int, Int) -> Int

_FileDescriptor: cover from Int {
	write: extern (write) func (Pointer, Int) -> Int
	read: extern (read) func (Pointer, Int) -> Int
	close: extern (close) func -> Int
}

PipeUnix: class extends Pipe {
	readFD, writeFD: _FileDescriptor

	init: func ~twos {
		fds := [-1, -1] as Int*
		raise(pipe(fds) < 0, "Couldn't create pipes")
		readFD = fds[0]
		writeFD = fds[1]
	}
	read: override func ~cstring (buf: CString, len: Int) -> Int {
		howMuch := readFD read(buf, len)
		if (howMuch <= 0) {
			if (errno == EAGAIN)
				howMuch = 0
			else {
				eof = true
				howMuch = -1
			}
		}
		howMuch
	}
	write: override func (data: Pointer, len: Int) -> Int {
		writeFD write(data, len)
	}
	close: override func (end: Char) -> Int {
		fd := _getFD(end)
		fd == 0 ? 0 : fd close()
	}
	close: override func ~both {
		readFD close()
		writeFD close()
	}
	setNonBlocking: func (end: Char) {
		fd := _getFD(end)
		if (fd != 0) {
			flags := fcntl(fd, F_GETFL, 0)
			flags |= O_NONBLOCK
			if (fcntl(fd, F_SETFL, flags) == -1)
				raise("can't change pipe to non-blocking mode")
		}
	}
	setBlocking: func (end: Char) {
		fd := _getFD(end)
		if (fd != 0) {
			flags := fcntl(fd, F_GETFL, 0)
			flags &= ~O_NONBLOCK
			if (fcntl(fd, F_SETFL, flags) == -1)
				raise("can't change pipe to blocking mode")
		}
	}
	_getFD: func (end: Char) -> _FileDescriptor {
		match end {
			case 'r' => readFD
			case 'w' => writeFD
			case => 0 as _FileDescriptor
		}
	}
}
}
