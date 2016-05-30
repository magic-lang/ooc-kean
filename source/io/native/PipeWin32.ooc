/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Pipe

version(windows) {
PipeWin32: class extends Pipe {
	readFD: Handle = 0
	writeFD: Handle = 0

	init: func ~twos {
		saAttr: SecurityAttributes

		// Set the bInheritHandle flag so pipe handles are inherited.
		saAttr length = SecurityAttributes size
		saAttr inheritHandle = true
		saAttr securityDescriptor = null

		if (!CreatePipe(this readFD&, this writeFD&, saAttr&, 0))
			WindowsException new(This, GetLastError(), "Failed to create pipe") throw()
	}
	free: override func {
		this close('r') . close('w')
		super()
	}
	read: override func ~cstring (buf: CString, len: Int) -> Int {
		bytesRead: ULong
		result := -1
		success := ReadFile(this readFD, buf, len, bytesRead&, null)
		if (success)
			result = bytesRead
		if (GetLastError() == ERROR_NO_DATA)
			result = 0
		this eof = true
		result
	}
	write: override func (data: Pointer, len: Int) -> Int {
		bytesWritten: ULong

		// will either block (in blocking mode) or always return with true (in
		// non-blocking mode) regardless of how many bytes were written.
		success := WriteFile(this writeFD, data, len as Long, bytesWritten&, null)

		if (!success)
			WindowsException new(This, GetLastError(), "Failed to write to pipe") throw()

		bytesWritten
	}
	close: override func (end: Char) -> Int {
		fd := this _getFD(end)
		fd && CloseHandle(fd) ? 1 : 0
	}
	setNonBlocking: func (end: Char) {
		fd := this _getFD(end)
		if (fd)
			this _setFDState(this readFD, PIPE_WAIT)
	}
	setBlocking: func (end: Char) {
		fd := this _getFD(end)
		if (fd)
			this _setFDState(this readFD, PIPE_WAIT)
	}
	_getFD: func (end: Char) -> Handle {
		match end {
			case 'r' => this readFD
			case 'w' => this writeFD
			case => null as Handle
		}
	}
	_setFDState: func (handle: Handle, flags: ULong) {
		SetNamedPipeHandleState(handle, flags&, null, null)
	}
}
}
