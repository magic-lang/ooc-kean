/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import backend/[GLFence, GLContext]

DisplayContext: abstract class {
	getDisplay: abstract func -> Pointer
	printExtensions: abstract func
	swapBuffers: abstract func
}
