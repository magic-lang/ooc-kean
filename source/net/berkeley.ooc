include stdio
include sys/types
include unistd | (__USE_BSD)

version (windows) {
	include winsock2
	// Needs Windows XP or later for getnameinfo and getaddrinfo.
	include ws2tcpip | (_WIN32_WINNT=0x0501)
} else {
	include sys/socket
	include sys/ioctl
	include sys/poll
	include sys/select
	include arpa/inet
	include netdb | (__USE_POSIX)
	include sys/fcntl
}

/**
	Low level binding to Berkeley sockets API.
*/

SockAddr: cover from struct sockaddr {
	sa_family: extern UShort // address family, AF_xxx
	sa_data: extern Char* // 14 bytes of protocol address
}

SockAddrIn: cover from struct sockaddr_in {
	sin_family: extern Short // e.g. AF_INET
	sin_port: extern UShort // e.g. htons(3490)
	sin_addr: extern InAddr // see struct in_addr, below
	sin_zero: extern Char* // 8 bytes, zero this if you want to
}

InAddr: cover from struct in_addr {
	s_addr: extern ULong // load with inet_aton()
}

SockAddrIn6: cover from struct sockaddr_in6 {
	sin6_family: extern UInt16
	sin6_port: extern UInt16
	sin6_flowinfo: extern UInt32
	sin6_addr: extern In6Addr
	sin6_scope_id: extern UInt32
}

In6Addr: cover from struct in6_addr {
	s6_addr: extern UChar* // 16 bytes
}

AddrInfo: cover from struct addrinfo {
	ai_flags: extern Int
	ai_family: extern Int
	ai_socktype: extern Int
	ai_protocol: extern Int

	ai_addrlen: extern UInt
	ai_canonname: extern Char*
	ai_addr: extern SockAddr*
	ai_next: extern This *
}

HostEntry: cover from struct hostent {
	h_name: extern CString // official name of the host
	h_aliases: extern CString* // alt names
	h_addr_type: extern Int // host type; AF_INET or AF_INET6 (IPv6)
	h_length: extern Int // length in bytes of each address
	h_addr_list: extern Char** // list of addresses for the host
}

version (!windows) {
	PollFd: cover from struct pollfd {
	fd: extern Int
	events: extern Short
	revents: extern Short
	}
}

FdSet: cover from fd_set {
	_set: extern (FD_SET) static func (fd: Int, fdset: This *)
	_set?: extern (FD_ISSET) static func (fd: Int, fdset: This *) -> Bool
	_clr: extern (FD_CLR) static func (fd: Int, fdset: This *)
	_zero: extern (FD_ZERO) static func (fdset: This *)

	set: func@(fd: Int) { _set(fd, this &) }
	set?: func@(fd: Int) -> Bool { _set?(fd, this &) }
	clr: func@(fd: Int) { _clr(fd, this &) }
	zero: func@ { _zero(this &) }
}

TimeVal: cover from struct timeval {
	tv_sec: extern Long
	tv_usec: extern Long
}

INADDR_ANY: extern ULong
INADDR_NONE: extern ULong
AI_CANONNAME: extern Int

version (windows) {
	SHUT_RD: extern Int
	SHUT_WR: extern Int
	SHUT_RDWR: extern Int
}

version (!windows) {
	SD_RECEIVE: extern Int
	SD_SEND: extern Int
	SD_BOTH: extern Int
}

SOL_SOCKET: extern Int

SO_REUSEADDR: extern Int

version (!windows) {
	poll: extern func (ufds: PollFd*, nfds: UInt, timeout: Int) -> Int
}

socket: extern func (family, type, protocol: Int) -> Int
accept: extern func (descriptor: Int, address: SockAddr*, addressLength: UInt*) -> Int
bind: extern func (descriptor: Int, myAddress: SockAddr*, addressLength: UInt) -> Int
connect: extern func (descriptor: Int, serverAddress: SockAddr*, addressLength: UInt) -> Int
close: extern func (descriptor: Int) -> Int
closesocket: extern func (descriptor: Int) -> Int // windows version of close()
shutdown: extern func (descriptor, how: Int) -> Int
listen: extern func (descriptor, numberOfBacklogConnections: Int) -> Int
recv: extern func (descriptor: Int, buffer: Pointer, maxBufferLength: SizeT, flags: Int) -> Int
recvFrom: extern (recvfrom) func (descriptor: Int, buffer: Pointer, maxBufferLength: SizeT, flags: Int, senderAddress: SockAddr*, senderAddressLength: UInt*) -> Int
send: extern func (descriptor: Int, message: Pointer, messageLength: SizeT, flags: Int) -> Int
sendTo: extern (sendto) func (descriptor: Int, message: Pointer, messageLength: SizeT, flags: Int, recieverAddress: SockAddr*, receiverAddressLength: UInt) -> Int
select: extern func (numfds: Int, readfds: FdSet*, writefds: FdSet*, exceptfds: FdSet*, timeout: TimeVal*) -> Int
getsockopt: extern func (s: Int, level: Int, optname: Int, optval: Pointer, optlen: UInt) -> Int
setsockopt: extern func (s: Int, level: Int, optname: Int, optval: Pointer, optlen: UInt) -> Int
getaddrinfo: extern func (domain_name_or_ip: CString, service_name_or_port: CString, hints: AddrInfo*, service_information: AddrInfo**) -> Int
getnameinfo: extern func (serviceInformation: SockAddr*, serviceInformationLength: UInt32, hostName: CString, hostNameLength: SizeT, serviceName: CString, serviceNameLength: UInt32, flags: Int) -> Int
freeaddrinfo: extern func (serviceInformation: AddrInfo*)
gai_strerror: extern func (errorCode: Int) -> const Char*
gethostbyname: extern func (domainName: CString) -> HostEntry*
gethostbyaddr: extern func (pointerToAddress: CString, addressLength: Int, type: Int) -> HostEntry*
getpeername: extern func (descriptor: Int, address: SockAddr*, len: UInt) -> Int
htonl: extern func (hostlong: UInt32) -> UInt32
htons: extern func (hostshort: UInt16) -> UInt16
ntohl: extern func (netlong: UInt32) -> UInt32
ntohs: extern func (netshort: UInt16) -> UInt16
fcntl: extern func (descriptor, command, argument: Int) -> Int

// getnameinfo constants
NI_NAMEREQD: extern Int
NI_DGRAM: extern Int
NI_NOFQDN: extern Int
NI_NUMERICHOST: extern Int
NI_NUMERICSERV: extern Int

// getaddrinfo constants
AI_NUMERICHOST: extern Int
AI_PASSIVE: extern Int
AI_CANONNAME: extern Int
AI_ADDRCONFIG: extern Int
AI_V4MAPPED: extern Int
AI_ALL: extern Int
AI_IDN: extern Int
AI_CANONIDN: extern Int
AI_IDN_ALLOW_UNASSIGNED: extern Int
AI_IDN_USE_STD3_ASCII_RULES: extern Int

// The following are deprecated
inet_ntoa: extern func (address: InAddr) -> CString
inet_aton: extern func (ipAddress: CString, inp: InAddr*) -> Int
inet_addr: extern func (ipAddress: CString) -> ULong
// end deprecated

version (!windows) {
	inet_ntop: extern func (addressFamily: Int, address: Pointer, destination: CString, destinationSize: UInt) -> CString
	inet_pton: extern func (addressFamily: Int, address: CString, destination: Pointer) -> Int
	ioctl: extern func (d: Int, request: Int, arg: Pointer) -> Int
}

FIONREAD: extern Int

// winsock needs WSAStartup to be called to work.
version (windows) {
import native/win32/types
WSADATA: extern cover

WSAStartup: extern func (versionRequested: WORD, wsaData: Pointer) -> Int

initWinsock: func {
	data: This
	ret := WSAStartup(MAKEWORD(2, 2), data&)

	if (ret != 0) {
		raise("Could not initialize winsock 2.2")
	}
}
initWinsock()
}
