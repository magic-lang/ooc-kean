/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(windows) {
	include windows | (_WIN32_WINNT=0x0500)

	SystemInfo: cover from SYSTEM_INFO {
		numberOfProcessors: extern (dwNumberOfProcessors) UInt
	}

	COMPUTER_NAME_FORMAT: enum {
		NET_BIOS = 0
		DNS_HOSTNAME
		DNS_DOMAIN
		DNS_FULLY_QUALIFIED
		PHYSICAL_NET_BIOS
		PHYSICAL_DNS_HOSTNAME
		PHYSICAL_DNS_DOMAIN
		PHYSICAL_DNS_FULLY_QUALIFIED
		MAX
	}

	GetSystemInfo: extern func (SystemInfo*)
	GetComputerNameEx: extern func (COMPUTER_NAME_FORMAT, CString, UInt*)
}

version(linux || apple) {
	include unistd
	sysconf: extern func (Int) -> Long
	_SC_NPROCESSORS_ONLN: extern Int
}

System: class {
	numProcessors: static func -> Int {
		result := 1
		version(windows) {
			sysinfo: SystemInfo
			GetSystemInfo(sysinfo&)
			result = sysinfo numberOfProcessors
		}
		version(linux || apple) {
			result = sysconf(_SC_NPROCESSORS_ONLN)
		}
		result
	}
	hostname: static func -> String {
		result: String = null
		version (windows) {
			bufSize: UInt = 0
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, null, bufSize&)
			hostname := CharBuffer new(bufSize)
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, hostname data as Pointer, bufSize&)
			hostname sizeFromData()
			result = hostname toString()
		}
		version (linux || apple) {
			BUF_SIZE: SizeT = 255
			hostname := CharBuffer new(BUF_SIZE + 1)
			value := gethostname(hostname data as Pointer, BUF_SIZE)
			if (value != 0)
				Exception new("System host name longer than 256 characters!!") throw()
			hostname sizeFromData()
			result = hostname toString()
		}
		result
	}
}
