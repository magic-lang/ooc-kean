/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include fcntl

version(!android) {
	include sys/fcntl
}

F_SETFL: extern Int
F_GETFL: extern Int
O_NONBLOCK: extern Int
EAGAIN: extern Int

fcntl: extern func (Int, Int, Int) -> Int
