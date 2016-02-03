/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Promise
import ThreadPool

WorkerThread: class extends ThreadPool {
	init: func { super(1) }
	wait: func (action: Func) { this getPromise(action) wait() . free() }
	wait: func ~all { this wait(||) }
}
