/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use tests
use unit

main: func {
	result := Fixture testsFailed
	Fixture printFailures()
	if (result == 0)
		GlobalCleanup run()
	exit(result ? 1 : 0)
}
