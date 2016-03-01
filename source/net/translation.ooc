/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import berkeley, Socket, Address

Inet: class {
	ntop: static func (addressFamily: Int, address: Pointer, destination: CString, destinationSize: UInt) -> CString {
		result: CString
			// Using the built-in inet_ntop results in a gcc warning because return type is const char*, and rock does not support const
			// This implementaton is based on: https://github.com/pkulchenko/luasocket/blob/5a58786a39bbef7ed4805821cc921f1d40f12068/src/inet.c#L512
			match addressFamily {
				case AddressFamily IP4 =>
					in: SockAddrIn
					memset(in&, 0, SockAddrIn size)
					in sin_family = AddressFamily IP4
					getnameinfo(in& as SockAddr*, SockAddrIn size, destination,
					destinationSize, null, 0, NI_NUMERICHOST)
					result = destination
				case AddressFamily IP6 =>
					in: SockAddrIn6
					memset(in&, 0, SockAddrIn6 size)
					in sin6_family = AddressFamily IP6
					getnameinfo(in& as SockAddr*, SockAddrIn6 size, destination,
					destinationSize, null, 0, NI_NUMERICHOST)
					result = destination
				case =>
					result = null
			}
		result
	}

	pton: static func (addressFamily: Int, address: CString, destination: Pointer) -> Int {
		result: Int
		version (!windows) {
			result = inet_pton(addressFamily, address, destination)
		} else {
			// roll our own version, based on:
			// https://github.com/diegonehab/luasocket/blob/master/src/inet.c
			hints: AddrInfo
			res: AddrInfo*
			result = 1
			memset(hints&, 0, AddrInfo size)
			hints ai_family = addressFamily
			hints ai_flags = AI_NUMERICHOST
			if (getaddrinfo(address, null, hints&, res&) != 0) return -1
			match (addressFamily) {
				case AddressFamily IP4 =>
					in := res@ ai_addr as SockAddrIn*
					memcpy(destination, in@ sin_addr&, SockAddrIn size)
				case AddressFamily IP6 =>
					in := res@ ai_addr as SockAddrIn6*
					memcpy(destination, in@ sin6_addr&, SockAddrIn6 size)
				case =>
					result = -1
			}
			freeaddrinfo(res)
		}
		result
	}
}
