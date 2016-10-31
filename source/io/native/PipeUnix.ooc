/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
include sys/types, sys/stat
import ../Pipe

version(unix || apple) {
_FileDescriptor: cover from Int {
	write: extern (write) func (Pointer, Int) -> Int
	read: extern (read) func (Pointer, Int) -> Int
	close: extern (close) func -> Int
}

PipeUnix: class extends Pipe {
	readFD, writeFD: _FileDescriptor

	init: func ~twos {
		fds := [-1, -1] as Int*
		Debug error(pipe(fds) < 0, "Couldn't create pipes")
		this readFD = fds[0]
		this writeFD = fds[1]
	}
	free: override func {
		this close('r') . close('w')
		super()
	}
	read: override func ~cstring (buf: CString, len: Int) -> Int {
		howMuch := this readFD read(buf, len)
		if (howMuch <= 0) {
			if (errno == EAGAIN)
				howMuch = 0
			else {
				this eof = true
				howMuch = -1
			}
		}
		howMuch
	}
	write: override func (data: Pointer, len: Int) -> Int {
		this writeFD write(data, len)
	}
	close: override func (end: Char) -> Int {
		fd := this _getFD(end)
		fd == 0 ? 0 : fd close()
	}
	setNonBlocking: func (end: Char) {
		fd := this _getFD(end)
		if (fd != 0) {
			flags := fcntl(fd, F_GETFL, 0)
			flags |= O_NONBLOCK
			if (fcntl(fd, F_SETFL, flags) == -1)
				Debug error("can't change pipe to non-blocking mode")
		}
	}
	setBlocking: func (end: Char) {
		fd := this _getFD(end)
		if (fd != 0) {
			flags := fcntl(fd, F_GETFL, 0)
			flags &= ~O_NONBLOCK
			if (fcntl(fd, F_SETFL, flags) == -1)
				Debug error("can't change pipe to blocking mode")
		}
	}
	_getFD: func (end: Char) -> _FileDescriptor {
		match end {
			case 'r' => this readFD
			case 'w' => this writeFD
			case => 0 as _FileDescriptor
		}
	}
}
}
