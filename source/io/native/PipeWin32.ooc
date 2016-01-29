/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Pipe
import os/win32

version(windows) {
PipeWin32: class extends Pipe {
	readFD = 0, writeFD = 0 : Handle
	init: func ~twos {
		saAttr: SecurityAttributes

		// Set the bInheritHandle flag so pipe handles are inherited.
		saAttr length = SecurityAttributes size
		saAttr inheritHandle = true
		saAttr securityDescriptor = null

		/* Try to open a new pipe */
		if (!CreatePipe(readFD&, writeFD&, saAttr&, 0)) {
			WindowsException new(This, GetLastError(), "Failed to create pipe") throw()
		}
	}
	read: override func ~cstring (buf: CString, len: Int) -> Int {
		bytesRead: ULong
		result := -1
		success := ReadFile(readFD, buf, len, bytesRead&, null)

		// normal read
		if (success)
			result = bytesRead

		// no data
		if (GetLastError() == ERROR_NO_DATA)
			result = 0

		// reached eof
		eof = true
		result
	}
	write: override func (data: Pointer, len: Int) -> Int {
		bytesWritten: ULong

		// will either block (in blocking mode) or always return with true (in
		// non-blocking mode) regardless of how many bytes were written.
		success := WriteFile(writeFD, data, len as Long, bytesWritten&, null)

		if (!success) {
			WindowsException new(This, GetLastError(), "Failed to write to pipe") throw()
		}

		bytesWritten
	}
	// 'r' = close in reading, 'w' = close in writing
	close: override func (end: Char) -> Int {
		fd := _getFD(end)
		fd && CloseHandle(fd) ? 1 : 0
	}
	close: override func ~both {
		CloseHandle(readFD)
		CloseHandle(writeFD)
	}
	setNonBlocking: func (end: Char) {
		fd := _getFD(end)
		if (fd)
			_setFDState(readFD, PIPE_WAIT)
	}
	setBlocking: func (end: Char) {
		fd := _getFD(end)
		if (fd)
			_setFDState(readFD, PIPE_WAIT)
	}
	_getFD: func (end: Char) -> Handle {
		match end {
			case 'r' => readFD
			case 'w' => writeFD
			case => null as Handle
		}
	}
	_setFDState: func (handle: Handle, flags: ULong) {
		SetNamedPipeHandleState(handle, flags&, null, null)
	}
}

include windows

CreatePipe: extern func (readPipe: Handle*, writePipe: Handle*, lpPipeAttributes: Pointer, nSize: Long) -> Bool
ReadFile: extern func (hFile: Handle, buffer: Pointer, numberOfBytesToRead: Long, numberOfBytesRead: Long*, lpOverlapped: Pointer) -> Bool
WriteFile: extern func (hFile: Handle, buffer: Pointer, numberOfBytesToWrite: Long, numberOfBytesWritten: Long*, lpOverlapped: Pointer) -> Bool
CloseHandle: extern func (handle: Handle) -> Bool
SetNamedPipeHandleState: extern func (handle: Handle, mode: Long*, maxCollectionCount: Long*, collectDataTimeout: Long*)

PIPE_WAIT, PIPE_NOWAIT: extern ULong
ERROR_NO_DATA: extern Long

SecurityAttributes: cover from SECURITY_ATTRIBUTES {
	length: extern (nLength) Int
	inheritHandle: extern (bInheritHandle) Bool
	securityDescriptor: extern (lpSecurityDescriptor) Pointer
}
}
