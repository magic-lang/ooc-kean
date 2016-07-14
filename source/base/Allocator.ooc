/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Owner

AbstractAllocator: abstract class {
	_owner: Owner
	free: func ~withCriteria (owner: Owner) {
		if (owner == this _owner)
			this free()
	}
	allocate: abstract func (size: SizeT) -> Void*
	deallocate: abstract func (pointer: Void*)
}

MallocAllocator: class extends AbstractAllocator {
	init: func (owner := Owner Receiver) { this _owner = owner }
	allocate: override func (size: SizeT) -> Void* { malloc(size) }
	deallocate: override func (pointer: Void*) { memfree(pointer) }
}
