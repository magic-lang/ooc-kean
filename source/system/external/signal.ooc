/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version ((linux || apple) && !android) {
	include signal | (_POSIX_SOURCE)

	signal: extern func (sig: Int, f: Pointer) -> Pointer

	SIGHUP, SIGINT, SIGILL, SIGKILL, SIGTRAP, SIGABRT, SIGFPE, SIGBUS,
	SIGSEGV, SIGSYS, SIGPIPE, SIGALRM, SIGTERM: extern Int
} else {
	include signal
}
