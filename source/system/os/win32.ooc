/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(windows) {
	include windows

	GetLastError: extern func -> Int

	ERROR_HANDLE_EOF: extern Int

	FormatMessage: extern func (dwFlags: DWORD, lpSource: Pointer, dwMessageId: DWORD, dwLanguageId: DWORD, lpBuffer: LPTSTR, nSize: DWORD, ...) -> DWORD

	FORMAT_MESSAGE_FROM_SYSTEM: extern Long
	FORMAT_MESSAGE_IGNORE_INSERTS: extern Long
	FORMAT_MESSAGE_ARGUMENT_ARRAY: extern Long

	GetWindowsErrorMessage: func (err: DWORD) -> String {
		BUF_SIZE := 256
		buf := CharBuffer new(BUF_SIZE)
		len: SSizeT = FormatMessage(
			FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY,
			null,
			err,
			0,
			buf data as CString,
			BUF_SIZE,
			null
		)
		buf setLength(len)

		// rip away trailing CR LF TAB SPACES etc.
		while ((len > 0) && (buf[len - 1] as Byte < 32)) len -= 1
		buf setLength(len)
		buf toString()
	}

	WindowsException: class extends Exception {
		init: func (.origin, err: Long) {
			super(origin, GetWindowsErrorMessage(err))
		}
		init: func ~withMsg (.origin, err: Long, message: String) {
			super(origin, "%s: %s" format(message, GetWindowsErrorMessage(err)))
		}
	}

	LocaleId: cover from LCID

	/*
	 * File handle
	 */
	Handle: cover from HANDLE
	INVALID_HANDLE_VALUE: extern Handle

	LargeInteger: cover from LARGE_INTEGER {
		lowPart: extern (LowPart) Long
		highPart: extern (HighPart) Long
		quadPart: extern (QuadPart) LLong
	}

	ULargeInteger: cover from ULARGE_INTEGER {
		lowPart: extern (LowPart) Long
		highPart: extern (HighPart) Long
		quadPart: extern (QuadPart) LLong
	}

	toLLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> LLong {
		li: LargeInteger
		li lowPart = lowPart
		li highPart = highPart
		li quadPart
	}

	toULLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> ULLong {
		li: ULargeInteger
		li lowPart = lowPart
		li highPart = highPart
		li quadPart
	}

	// FILETIME is a Long that stores the number of 100-nanoseconds intervals from January 1st, 1601
	FileTime: cover from FILETIME {
		lowDateTime: extern (dwLowDateTime) Long // DWORD
		highDateTime: extern (dwHighDateTime) Long // DWORD
	}

	/*
	 * source: http://frenk.wordpress.com/2009/12/14/convert-filetime-to-unix-timestamp/
	 * thanks, Francesco De Vittori from Lugano, Switzerland!
	 */
	toTimestamp: func ~fromFiletime (fileTime: FileTime) -> Long {
		// takes the last modified date
		date, adjust: LargeInteger
		date lowPart = fileTime lowDateTime
		date highPart = fileTime highDateTime

		// 100-nanoseconds = milliseconds * 10000
		adjust quadPart = 11644473600000 * 10000

		// removes the diff between 1970 and 1601
		date quadPart -= adjust quadPart

		// converts back from 100-nanoseconds to seconds
		date quadPart / 10000000
	}

	BYTE: extern cover from Byte
	WORD: extern cover from Int
	DWORD: extern cover from Long
	LPTSTR: extern cover from CString

	MAKEWORD: extern func (low, high: BYTE) -> WORD
}
