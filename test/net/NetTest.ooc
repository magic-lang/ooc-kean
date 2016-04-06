/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use net
use concurrent

version (!windows) {
NetTest: class extends Fixture {
	ip := "0.0.0.0"
	init: func {
		super("Net")
		this add("TCP Socket Client Server", func {
			tcpClientThread := Thread new(func {
				ipaddress := IP4Address new(this ip)
				clientMessageNumber := 0
				clientSocket := TCPSocket new(SocketAddress new(ipaddress, 8000))
				clientSocket connect()
				clientReceivedData: Int
				clientSocket out write(clientMessageNumber as Char)
				while (clientMessageNumber < 10) {
					clientReceivedData = clientSocket in read() as Int
					expect(clientReceivedData, is equal to(clientMessageNumber))
					if(clientReceivedData == clientMessageNumber) {
						clientMessageNumber = clientMessageNumber + 1
						clientSocket out write(clientMessageNumber as Char)
					}
				}
				ipaddress free()
				clientSocket close()
				clientSocket readerWriter free()
			})
			serverSocket := ServerSocket new(this ip, 8000) . listen()
			tcpClientThread start()
			connection := serverSocket accept()
			serverReceivedData: Int
			serverMessageNumber := 0
			while (serverMessageNumber < 10) {
				serverReceivedData = connection in read() as Int
				expect(serverReceivedData, is equal to(serverMessageNumber))
				connection out write(serverMessageNumber as Char)
				serverMessageNumber = serverMessageNumber + 1
			}
			expect(serverReceivedData, is equal to(9))
			(connection, serverSocket) close()
			(connection, serverSocket) free()
			tcpClientThread wait()
			(tcpClientThread _code as Closure) free()
			tcpClientThread free()
		})
		this add("UDP Socket Client Readlines", func {
			udpClientThread := Thread new(func {
				ipaddress := IP4Address new(this ip)
				clientSocket := UDPSocket new(SocketAddress new(ipaddress, 5000))
				correct := "udp is fun"
				for (_ in 0 .. 5)
					clientSocket send(correct)
				(ipaddress, correct, clientSocket) free()
			})
			ip := IP4Address new(this ip)
			serverSocket := UDPSocket new(SocketAddress new(ip, 5000)) . bind()
			udpClientThread start()
			expected := "udp is fun"
			for (_ in 0 .. 5) {
				buffer := serverSocket receive(128)
				bufferString := buffer toString()
				expect(bufferString, is equal to(expected))
				bufferString free()
			}

			udpClientThread wait()
			(udpClientThread _code as Closure) free()
			(udpClientThread, expected, ip) free()
			serverSocket close() . free()
		})
	}
	free: override func {
		this ip free()
		super()
	}
}

NetTest new() run() . free()
}
