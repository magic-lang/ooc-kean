/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Owner: enum {
	Receiver
	Stack
	Static
	Sender
	Unknown

	isOwned: func -> Bool {
		this == Owner Sender || this == Owner Receiver
	}
	toString: func -> String {
		match (this) {
			case Owner Receiver => "Receiver"
			case Owner Stack => "Stack"
			case Owner Static => "Static"
			case Owner Sender => "Sender"
			case Owner Unknown => "Unknown"
			case => "Invalid enum type in Owner"
		}
	}
}
