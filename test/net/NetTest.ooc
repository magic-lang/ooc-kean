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

NetTest: class extends Fixture {
	init: func {
		super("Net")
		this add("TCP Socket Client Server", func {
			tcpClientThread := Thread new(func {
				clientIpText := t"0.0.0.0"
				ip := IP4Address new(clientIpText toString())
				clientMessageNumber := 0
				clientSocket := TCPSocket new(SocketAddress new(ip, 8000))
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
				clientSocket close()
			})
			ipText := t"0.0.0.0"
			serverSocket := ServerSocket new(ipText toString(), 8000) . listen()
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
			tcpClientThread wait() . free()
		})
		this add("UDP Socket Client Readlines", func {
			udpClientThread := Thread new(func {
				ipText := t"0.0.0.0"
				ip := IP4Address new(ipText toString())
				clientSocket := UDPSocket new(SocketAddress new(ip, 5000))
				correct := t"udp is fun"
				for (_ in 0 .. 5) {
					clientSocket send(correct toString())
				}
				correct free()
			})
			serverIpText := t"0.0.0.0"
			ip := IP4Address new(serverIpText toString())
			serverSocket := UDPSocket new(SocketAddress new(ip, 5000)) . bind()
			udpClientThread start()
			expected := t"udp is fun"
			for (_ in 0 .. 5) {
				buffer := serverSocket receive(128)
				expect(buffer toString(), is equal to(expected toString()))
			}
	
			udpClientThread wait() . free()
			expected free()
			serverSocket close()
		})
	}
}

NetTest new() run() . free()
