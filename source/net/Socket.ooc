use sdk-net
import berkeley, Exceptions

/**
	Common base for all socket types.
*/
Socket: abstract class {
	descriptor: Int
	family, type, protocol: Int
	connected? := false
	listening? := false
	hasData? := false

	init: func ~sock (=family, =type, =protocol) {
		descriptor = socket(family, type, protocol)
		if (descriptor == -1) {
			SocketError new(class, "Failed to create socket") throw()
		}
	}
	init: func ~descriptor (=family, =type, =protocol, =descriptor)

	close: func {
		result : Int

		version(windows) {
			result = closesocket(descriptor)
		}
		version (!windows) {
			result = close(descriptor)
		}

		if (result == -1) {
			SocketError new(class, "Failed to close socket") throw()
		}

		connected? = false
	}

	ioctl: func (request: Int, arg: Pointer) {
		version (windows) {
			SocketError new(class, "ioctl unsupported on Windows") throw()
		}

		version (!windows) {
			rt := ioctl(descriptor, request, arg)
			if (rt != 0) {
				SocketError new(class, "ioctl failed") throw()
			}
		}
	}

	/**
	 Returns the number of bytes currently waiting to be consumed. This function is
	 NON BLOCKING and therefore don't rely on it for halting execution while data is
	 received. You may want to look at 'wait()'
	*/
	available: func -> Int {
		result: Int
		ioctl(FIONREAD, result&)
		return result
	}

	/**
	 Waits on the socket for data to be received or a timeout. If sucessful the return value
	 is the number of bytes waiting to be consumed.

	 :param timeoutSec: The timeout in seconds before wait is returned without data available.
	 :param timeoutuSec: The timeout in micro seconds before wait is returned without data available.
	 :throws: A TimeoutError if the wait times out before data becomes available
	*/
	wait: func (timeoutSec, timeoutuSec: Int) -> Int {
		timeout : TimeVal
		timeout tv_sec = timeoutSec
		timeout tv_usec = timeoutuSec

		descriptors : FdSet
		descriptors zero()
		descriptors set(descriptor)

		select(descriptor + 1, descriptors&, null, null, timeout&)

		if (!descriptors set?(descriptor))
			TimeoutError new("Wait on socket timedout.") throw()

		return available()
	}

	/**
	Waits on the socket for data to be received or a timeout. If sucessful the return value
	is the number of bytes waiting to be consumed.

	:param timeoutSec: The timeout in seconds before wait is returned without data available.
	:throws: A TimeoutError if the wait times out before data becomes available
	*/
	wait: func ~justSeconds (timeoutSec: Int) -> Int {
		return wait(timeoutSec, 0)
	}

	/**
	 Sets the socket to non-blocking mode
	*/
	setNonBlocking: func -> Int {
	result := 0

	version (windows) {
		SocketError new(class, "setNonBlocking unsupported on Win32") throw()
	}

	version (!windows) {
		flags := currentFlags()

		result = fcntl(descriptor, SocketControls SET_SOCKET_FLAGS, flags | SocketControls NON_BLOCKING)
	}

	if (result < 0) {
		SocketError new(class, "Could not set socket to non-blocking") throw()
	}

	return result
	}

	/**
	 Sets the socket to blocking mode
	*/
	setBlocking: func -> Int {
	result := 0

	version (windows) {
		SocketError new(class, "setBlocking unsupported on Win32") throw()
	}

	version (!windows) {
		flags := currentFlags()

		result = fcntl(descriptor, SocketControls SET_SOCKET_FLAGS, flags & ~(SocketControls NON_BLOCKING))
	}

	if (result < 0) {
		SocketError new(class, "Could not set socket to blocking") throw()
	}

	return result
	}

	/**
	 Retrieves the current socket flags from the underlying socket
	*/
	currentFlags: func -> Int {
	flags: Int = 0

	version (windows) {
		SocketError new(class, "currentFlags not supported on Win32")
	}

	version (!windows) {
		flags = fcntl(descriptor, SocketControls GET_SOCKET_FLAGS, 0)
		if (flags < 0) {
			SocketError new(class, "fcntl to get current flags failed") throw()
		}
	}

	return flags
	}

	/**
	Enable/disable the reuse of the same address
	*/
	setReuseAddr: func (reuse: Bool) {
		option := reuse ? 1 : 0
		setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, option&, option class size)
	}
}

AddressFamily: cover {
	UNSPEC: extern (AF_UNSPEC) static Int
	IP4: extern (AF_INET) static Int
	IP6: extern (AF_INET6) static Int
}

SocketType: cover {
	STREAM: extern (SOCK_STREAM) static Int
	DATAGRAM: extern (SOCK_DGRAM) static Int
}

SocketMsgFlags: cover {
	OOB: extern (MSG_OOB) static Int
	DONTROUTE: extern (MSG_DONTROUTE) static Int
	DONTWAIT: extern (MSG_DONTWAIT) static Int
	NOSIGNAL: extern (MSG_NOSIGNAL) static Int
	PEEK: extern (MSG_PEEK) static Int
	WAITALL: extern (MSG_WAITALL) static Int
}

SocketShutdownOptions: cover {
	NO_MORE_RECIEVES: extern (SHUT_RD) static Int
	NO_MORE_SENDS: extern (SHUT_WR) static Int
	NO_MORE_SENDS_OR_RECIEVES: extern (SHUT_RDWR) static Int
}

version (!windows) {
	SocketControls: cover {
		SET_SOCKET_FLAGS: extern (F_SETFL) static Int
		GET_SOCKET_FLAGS: extern (F_GETFL) static Int
		NON_BLOCKING: extern (O_NONBLOCK) static Int
		ASYNCHRONOUS: extern (O_ASYNC) static Int // this probably shoulden't be implemented as it's badly supported
	}
}
