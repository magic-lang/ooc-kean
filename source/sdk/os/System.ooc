import os/unistd

version(windows) {
	include windows | (_WIN32_WINNT=0x0500)

	SystemInfo: cover from SYSTEM_INFO {
		numberOfProcessors: extern (dwNumberOfProcessors) UInt
	}

	GetSystemInfo: extern func (SystemInfo*)

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
		result: String
		version (windows) {
			bufSize: UInt = 0
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, null, bufSize&)
			hostname := CharBuffer new(bufSize)
			GetComputerNameEx(COMPUTER_NAME_FORMAT DNS_HOSTNAME, hostname data as Pointer, bufSize&)
			hostname sizeFromData()
			result = hostname toString()
		}
		version (linux || apple) {
			BUF_SIZE = 255 : SizeT
			hostname := CharBuffer new(BUF_SIZE + 1)
			result := gethostname(hostname data as Pointer, BUF_SIZE)
			if (result != 0)
				Exception new("System host name longer than 256 characters!!") throw()
			hostname sizeFromData()
			result = hostname toString()
		}
		result
	}
}
