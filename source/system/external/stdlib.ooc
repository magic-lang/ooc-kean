/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version (linux) {
	include stdlib | (__USE_BSD)
} else {
	include stdlib
}

EXIT_SUCCESS: extern Int
EXIT_FAILURE: extern Int

exit: extern func (Int)
atexit: extern func (Pointer)
abort: extern func
getenv: extern func (path: CString) -> CString

version (!windows) {
	setenv: extern func (key, value: CString, overwrite: Bool) -> Int
	unsetenv: extern func (key: CString) -> Int
} else {
	putenv: extern func (str: CString) -> Int
}
