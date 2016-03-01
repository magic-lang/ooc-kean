/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
import os/System
import berkeley, Address, Socket

/**
   Allows DNS lookups and reserve lookups
 */
DNS: class {
	/**
		Perform DNS lookup using the hostname.
		Returns information about the host that was found.
	*/
	resolve: static func (hostname: String) -> HostInfo {
		resolve(hostname, 0, 0)
	}
	resolve: static func ~filter (hostname: String, socketType: Int, socketFamily: Int) -> HostInfo {
		hints: AddrInfo
		info: AddrInfo*
		memset(hints&, 0, hints class size)
		hints ai_flags = AI_CANONNAME
		hints ai_family = socketFamily
		hints ai_socktype = socketType
		if ((rv := getaddrinfo(hostname, null, hints&, info&)) != 0)
			raise(gai_strerror(rv as Int) as CString toString())
		HostInfo new(info)
	}

	/**
		Perform DNS lookup using the hostname.
		Returns the first IPAddress found for the host.
	*/
	resolveOne: static func (host: String) -> IPAddress {
		info := resolve(host)
		info addresses()[0]
	}
	resolveOne: static func ~filter (host: String, socketType: Int, socketFamily: Int) -> IPAddress {
		info := resolve(host, socketType, socketFamily)
		info addresses()[0]
	}

	/**
		Perform a reverse DNS lookup by using the host's address.
		Returns the hostname of the specified address.
	*/
	reverse: static func (ip: IPAddress) -> String {
		reverse(SocketAddress new(ip, 0))
	}
	reverse: static func ~withSockAddr (sockaddr: SocketAddress) -> String {
		hostname := CharBuffer new(1024)
		if ((rv := getnameinfo(sockaddr addr(), sockaddr length(), hostname toCString(), 1024, null, 0, 0)) != 0)
			raise(gai_strerror(rv as Int) as CString toString())
		hostname sizeFromData()
		hostname toString()
	}

	hostname: static func -> String { System hostname() }
	localhost: static func -> HostInfo { resolve(hostname()) }
}

/**
   Information about an host, ie. its name and different addresses
 */
HostInfo: class {
	name: String
	addresses: LinkedList<IPAddress>

	/**
	   Create a new HostInfo from an AddrInfo chain.

	   You shouldn't have to call this function yourself, but rather
	   get a HostInfo instance from calls to the DNS class.
	 */
	init: func (addrinfo: AddrInfo*) {
		addresses = LinkedList<IPAddress> new()
		name = addrinfo@ ai_canonname as CString toString()
		info := addrinfo
		while (info) {
			if (info@ ai_addrlen && info@ ai_addr) {
				match (info@ ai_family) {
					case AddressFamily IP4 =>
						sockaddrin := info@ ai_addr as SockAddrIn*
						addresses add(IP4Address new(sockaddrin@ sin_addr))
				}
			}
			info = info@ ai_next
		}
		if (addrinfo)
			freeaddrinfo(addrinfo)
	}

	/**
		Returns a list of IPAddress associated with this host.
	*/
	addresses: func -> LinkedList<IPAddress> { this addresses }

	free: override func {
		this addresses free()
		super()
	}
}
