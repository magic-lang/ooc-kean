/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdlib

EXIT_SUCCESS: extern Int
EXIT_FAILURE: extern Int

exit: extern func (Int)
atexit: extern func (Pointer)
abort: extern func
