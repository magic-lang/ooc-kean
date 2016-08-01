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
	allocate: abstract func (size: SizeT) -> Pointer
	deallocate: abstract func (pointer: Pointer)
}

MallocAllocator: class extends AbstractAllocator {
	init: func (owner := Owner Receiver) { this _owner = owner }
	allocate: override func (size: SizeT) -> Pointer { malloc(size) }
	deallocate: override func (pointer: Pointer) { memfree(pointer) }
}

Allocator: abstract class {
	_defaultAllocator: static AbstractAllocator = null
	mallocAllocator := static MallocAllocator new(Owner Sender)
	defaultAllocator: static func -> AbstractAllocator {
		This _defaultAllocator ?? mallocAllocator as AbstractAllocator
	}
	free: static func ~all {
		This mallocAllocator free(Owner Sender)
	}
}
