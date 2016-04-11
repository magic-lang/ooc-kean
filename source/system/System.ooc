/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
			bufferSize: SizeT = 255
			hostname := CharBuffer new(bufferSize + 1)
			value := gethostname(hostname data as Pointer, bufferSize)
			raise(value != 0, "System host name longer than 256 characters!!")
			hostname sizeFromData()
			result = hostname toString()
		}
		result
	}
}
