/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import berkeley, Socket, TCPSocket, Address, DNS, utilities

/**
	A server based socket interface.
*/
ServerSocket: class extends Socket {
	backlog: Int

	init: func ~server {
		super(AddressFamily IP4, SocketType STREAM, 0)
	}

	/**
		Initialize the socket.

		100 seems to be a good backlog setting to not be as badly affected by SYN floods.
		See http://tangentsoft.net/wskfaq/advanced.html#backlog for details

		:param ip: The IP, for now it can NOT be a hostname (TODO: This is a bug! Fix it!)
		:param port: The port, for example 8080, or 80.
		:param bl: The backlog, defaults to 100
		:param enabled: If true, call listen(), otherwise do not
	*/
	init: func ~ipPortBacklogAndListen (ip := "0.0.0.0", port: Int, bl := 100, enabled := false) {
		backlog = bl
		resolved := DNS resolveOne(ip)
		ip = resolved toString()
		resolved free()
		type = ipType(ip)
		super(type, SocketType STREAM, 0)
		this bind(ip, port)
		if (enabled)
			this listen()
		ip free()
	}

	/**
		Bind a local port to the socket.
	*/
	bind: func (port: Int) {
		addr := SocketAddress new(IP4Address new(), port)
		this bind(addr)
	}

	/**
		Bind a local address and port to the socket.
	*/
	bind: func ~withIp (ip: String, port: Int) {
		addr: SocketAddress
		type := ipType(ip)
		if (validIp(ip)) {
			match (type) {
				case AddressFamily IP4 =>
					addr = getSocketAddress(ip, port)
				case AddressFamily IP6 =>
					addr = getSocketAddress6(ip, port)
			}
			if (addr)
				this bind(addr)
		} else
			raise("Address must be a valid IPv4 or IPv6 IP.")
	}

	/**
		Bind a local address to the socket.
	*/
	bind: func ~withAddr (addr: SocketAddress) {
		if (bind(descriptor, addr addr(), addr length()) == -1)
			raise("SocketError bind")
		addr free()
	}

	/**
		Places the socket into a listening state.
	*/
	listen: func (backlog: Int) -> Bool {
		ret := listen(descriptor, backlog)
		if (ret == -1)
			raise("SocketError listen")
		this listening = (ret == 0)
		this listening
	}

	/**
		Places the socket into a listening state, using backlog variable.
	*/
	listen: func ~nobacklog -> Bool {
		this listen(this backlog)
		this listening
	}

	/**
		Accept an incoming connection and returns it.

		This method will normally block if no connection is
		available immediately.
	*/
	accept: func -> TCPReaderWriterPair {
		addr: SockAddr
		addrSize: UInt = SockAddr size
		conn := accept(descriptor, addr&, addrSize&)
		if (conn == -1)
			raise("Failed to accept an incoming connection.")
		sock := TCPSocket new(SocketAddress newFromSock(addr&, addrSize), conn)
		TCPReaderWriterPair new(sock)
	}

	/**
		Run f() in a loop that calls accept()

		This method will block.
	*/
	accept: func ~withClosure (f: Func (TCPReaderWriterPair) -> Bool) {
		if (!this listening)
			this listen()

		while (true) {
			conn := accept()
			if (!conn)
				break
			ret := f(conn)
			version (windows) {
				shutdown(conn sock descriptor, SD_BOTH)
			} else {
				shutdown(conn sock descriptor, SHUT_RDWR)
			}
			conn close()
			if (ret)
				break // Break out of the loop if one of conn or ret is 0 or null
		}
	}
}
