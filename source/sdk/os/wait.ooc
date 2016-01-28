/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(unix || apple) {
	include sys/wait
}

WEXITSTATUS: extern func (Int) -> Int
WIFEXITED: extern func (Int) -> Int
WIFSIGNALED: extern func (Int) -> Int
WTERMSIG: extern func (Int) -> Int

wait: extern func (Int*) -> Int
waitpid: extern func (Int, Int*, Int) -> Int
