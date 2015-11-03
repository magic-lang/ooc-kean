import Socket, Address, DNS, Exceptions
import io/[Reader, Writer]
import berkeley into socket

/**
	A stream based socket interface.
 */
TCPSocket: class extends Socket {
	remote: SocketAddress
	readerWriter: TCPReaderWriterPair

	/**
	  Getter for accessing `readerWriter in`
	*/
	in: TCPSocketReader {
		get {
			readerWriter in
		}
	}

	/**
	  Getter for accessing `readerWriter out`
	*/
	out: TCPSocketWriter {
		get {
			readerWriter out
		}
	}

	/**
	   Create a new socket to a given remote address

	   :param remote: The address of the host to eventually connect to.
	 */
	init: func ~addr (=remote) {
		super(remote family(), SocketType STREAM, 0)
	}

	/**
	   Create a new socket to a given remote address with a specific
	   file descriptor.

	   :param remote: The address of the host to eventually connect to.
	 */
	init: func ~addrDescriptor (=remote, .descriptor) {
		super(remote family(), SocketType STREAM, 0, descriptor)
	}

	/**
	   Create a new socket to a given hostname and port number

	   :param host: The hostname, for example 'localhost', or 'www.example.org'
	   :param port: The port, for example 8080, or 80.
	 */
	init: func ~hostAndPort (host: String, port: Int) {
		init(host, port, AddressFamily UNSPEC)
	}

	/**
	   Create a new socket to a given hostname, port number and specific family

	   :param host: The hostname, for example 'localhost', or 'www.example.org'
	   :param port: The port, for example 8080, or 80.
	   :param family: The port, for example AddressFamily IP4.
	 */
	init: func ~family (host: String, port: Int, family: Int) {
		ip := DNS resolveOne(host, SocketType STREAM, family)
		init(SocketAddress new(ip, port))
	}

	/**
	   Attempt to connect this socket to the remote host.

	   :throws: A SocketError if something went wrong
	 */
	connect: func {
		if (socket connect(descriptor, remote addr(), remote length()) == -1) {
			SocketError new() throw()
		}

		readerWriter = TCPReaderWriterPair new(this)

		connected? = true
	}

	/**
	   Attempt to connect this socket to the remote host, then runs f(),
	   passing a TCPReaderWriterPair.

	   :throws: A SocketError if something went wrong
	 */
	connect: func ~withClosure (f: func (TCPReaderWriterPair) -> Bool) {
		if (!connected?)
			connect()

		f(readerWriter)
	}

	/**
	   :return: A reader that reads data from this socket
	 */
	reader: func -> TCPSocketReader {
		return TCPSocketReader new(this)
	}

	/**
	   :return: A writer that writes data to this socket
	 */
	writer: func -> TCPSocketWriter {
		return TCPSocketWriter new(this)
	}

	/**
	   Send data through this socket
	   :param data: The data to be sent
	   :param length: The length of the data to be sent
	   :param flags: Send flags
	   :param resend: Attempt to resend any data left unsent

	   :return: The number of bytes sent
	 */
	send: func ~withLength (data: Char*, length: SizeT, flags: Int, resend: Bool) -> Int {
		bytesSent := socket send(descriptor, data, length, flags)

		if (resend)
			while (bytesSent < length && bytesSent != -1) {
				dataSubstring := data as Char* + bytesSent
				bytesSent += socket send(descriptor, dataSubstring, length - bytesSent, flags)
			}

		if (bytesSent == -1)
			SocketError new() throw()

		return bytesSent
	}

	/**
	   Send a string through this socket
	   :param data: The string to be sent
	   :param flags: Send flags
	   :param resend: Attempt to resend any data left unsent

	   :return: The number of bytes sent
	 */
	send: func ~withFlags (data: String, flags: Int, resend: Bool) -> Int {
		send(data toCString(), data size, flags, resend)
	}

	/**
	   Send a string through this socket
	   :param data: The string to be sent
	   :param resend: Attempt to resend any data left unsent

	   :return: The number of bytes sent
	 */
	send: func ~withResend (data: String, resend: Bool) -> Int { send(data, 0, resend) }

	/**
	   Send a string through this socket with resend attempted for unsent data
	   :param data: The string to be sent

	   :return: The number of bytes sent
	 */
	send: func (data: String) -> Int { send(data, true) }

	/**
	   Send a byte through this socket
	   :param byte: The byte to send
	   :param flags: Send flags
	 */
	sendByte: func ~withFlags (byte: Char, flags: Int) {
		send(byte&, Char size, flags, true)
	}

	/**
	   Send a byte through this socket
	   :param byte: The byte to send
	 */
	sendByte: func (byte: Char) { sendByte(byte, 0) }

	/**
	   Receive bytes from this socket
	   :param buffer: Where to store the received bytes
	   :param length: Size of the given buffer
	   :param flags: Receive flags

	   :return: Number of received bytes
	 */
	receive: func ~withFlags (chars: Char*, length: SizeT, flags: Int) -> Int {
		bytesRecv := socket recv(descriptor, chars, length, flags)
		if (bytesRecv == -1) {
			connected? = false
			SocketError new() throw()
		}
		/* hasData? is true if there's data left (aka, if bytesRecv != 0),
		 * and false otherwise
		 */
		hasData? = (bytesRecv != 0)
		return bytesRecv
	}

	/**
		Receive bytes from this socket
		:param buffer: Where to store the received bytes
		:param length: Size of the given buffer

		:return: Number of received bytes
	*/
	receive: func (buffer: Buffer, length: SizeT) -> Int {
		assert (length <= buffer capacity)
		ret := receive(buffer data, length, 0)
		buffer setLength(ret)
		ret
	}

	/**
	   Receive a byte from this socket
	   :param flags: Receive flags

	   :return: The byte read
	 */
	receiveByte: func ~withFlags (flags: Int) -> Char {
		c: Char
		receive(c&, 1, flags)
		return c
	}

	/**
	   Receive a byte from this socket

	   :return: The byte read
	 */
	receiveByte: func -> Char { receiveByte(0) }
}

TCPSocketReader: class extends Reader {
	source: TCPSocket

	init: func (=source) { marker = 0 }

	close: func {
		source close()
	}

	read: func (chars: Char*, offset: Int, count: Int) -> SizeT {
		skip(offset - marker)
		source receive(chars, count, 0)
	}

	read: func ~char -> Char {
		source receiveByte()
	}

	hasNext?: func -> Bool {
		source receiveByte(SocketMsgFlags PEEK)
		source hasData?
	}

	rewind: func (offset: Int) {
		SocketError new("Sockets do not support rewind") throw()
	}

	seek: func (offset: Long, mode: SeekMode) {
		SocketError new("Sockets do not support seek") throw()
	}

	mark: func -> Long { marker }

	reset: func (marker: Long) {
		SocketError new("Sockets do not support reset") throw()
	}
}

TCPSocketWriter: class extends Writer {
	dest: TCPSocket

	init: func (=dest)

	close: func { dest close() }

	write: func ~chr (chr: Char) {
		dest sendByte(chr)
	}

	write: func (chars: Char*, length: SizeT) -> SizeT {
		return dest send(chars, length, 0, true)
	}

	vwritef: func (fmt: String, list: VaList) {
		list2: VaList
		va_copy(list2, list)
		length := vsnprintf(null, 0, fmt toCString(), list2)
		va_end (list2)
		buffer := Buffer new (length)
		vsnprintf(buffer data, length + 1, fmt toCString(), list)
		buffer setLength(length)
		write(buffer toCString(), length)
	}
}

TCPReaderWriterPair: class { // I thought TCPSocketReaderWriterPair was a bit too long
	in: TCPSocketReader
	out: TCPSocketWriter
	sock: TCPSocket
	init: func (=sock) {
		in = sock reader()
		out = sock writer()
	}

	close: func {
		sock close()
	}
}
