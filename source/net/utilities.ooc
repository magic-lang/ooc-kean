/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

/*
	Not sure if this is the best method, but it avoids inter-dependencies
	between UDPSocket and ServerSocket.
*/
import berkeley, translation, Socket, Address, Exceptions

/**
	Is the IP provided valid as either IPv6 or IPv4? (Returns type, from AddressFamily)
*/
ipType: func (ip: String) -> Int {
	atColons := ip split(":")
	atPeriods := ip split(".")
	if (atColons count >= 2)
		AddressFamily IP6 // 2 or more colons, assume IPv6
	else if (atPeriods count == 4 && atColons count == 1)
		AddressFamily IP4 // No colons, 4 sections separated by 3 periods, assume IPv4
	else
		AddressFamily UNSPEC // Who knows what was given, return UNSPEC
}

/**
	Is the IP provided valid as either IPv6 or IPv4? (Does not return which)
*/
validIp: func (ip: String) -> Bool {
	ipType(ip) != AddressFamily UNSPEC
}

getSocketAddress: func (ip: String, port: Int) -> SocketAddress {
	ai: InAddr
	type := ipType(ip)
	match (Inet pton(type, ip toCString(), ai&)) {
		case -1 =>
			// TODO: Check errno, it should be set to EAFNOSUPPORT
			NetError new("Invalid address family (%s)" format(ip)) throw()
		case 0 =>
			NetError new("Invalid network address (%s)" format(ip)) throw()
	}
	addr := SocketAddressIP4 new(ai, port)
	addr
}

getSocketAddress6: func (ip: String, port: Int) -> SocketAddress {
	ai: In6Addr
	type := ipType(ip)
	match (Inet pton(type, ip toCString(), ai&)) {
		case -1 =>
			// TODO: Check errno, it should be set to EAFNOSUPPORT
			NetError new("Invalid address family.") throw()
		case 0 =>
			NetError new("Invalid network address.") throw()
	}
	addr := SocketAddressIP6 new(ai, port)
	addr
}
