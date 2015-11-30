import os/unistd

version(windows) {
	// for GetSystemInfo, GetComputerNameEx.
	// 0x500 is the minimum required version, otherwise it won't link
	include windows | (_WIN32_WINNT=0x0500)

	SystemInfo: cover from SYSTEM_INFO {
		numberOfProcessors: extern (dwNumberOfProcessors) UInt32
	}
	GetSystemInfo: extern func (SystemInfo*)

	// This should use values from headers, but they seem to be missing it in MinGW
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

	GetComputerNameEx: extern func (COMPUTER_NAME_FORMAT, CString, UInt32*)
}

// Linux, OSX 10.4+
version(linux || apple) {
	include unistd // for sysconf
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
			// Linux, OSX 10.4+
			result = sysconf(_SC_NPROCESSORS_ONLN)
		}
		result
	}
	hostname: static func -> String {
		result: String
		version (windows) {
			bufSize: UInt32 = 0
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, null, bufSize&)
			hostname := Buffer new(bufSize)
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, hostname data as Pointer, bufSize&)
			hostname sizeFromData()
			result = hostname toString()
		}
		version (linux || apple) {
			BUF_SIZE = 255 : SizeT
			hostname := Buffer new(BUF_SIZE + 1) // we alloc one byte more so we're always zero terminated
			// according to docs, if the hostname is longer than the buffer,
			// the result will be truncated and zero termination is not guaranteed
			result := gethostname(hostname data as Pointer, BUF_SIZE)
			if (result != 0) Exception new("System host name longer than 256 characters!!") throw()
			hostname sizeFromData()
			result = hostname toString()
		}
		result
	}
}
