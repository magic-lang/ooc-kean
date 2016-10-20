/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include string // Memory routines in C are actually in string.h
version(windows) { include malloc }
else { include alloca }

// Note: Original SDK ooc code assumes allocated memory is zeroed (calloc)
// Consider using Buffer instead of calling these functions directly
// note: sizeof is intentionally not here. Use `Int size` instead of `sizeof(Int)`
malloc: extern func (SizeT) -> Pointer
calloc: extern func (SizeT, SizeT) -> Pointer
realloc: extern func (Pointer, SizeT) -> Pointer
memset: extern func (Pointer, Int, SizeT) -> Pointer
memcmp: extern func (Pointer, Pointer, SizeT) -> Int
memmove: extern func (Pointer, Pointer, SizeT)
memcpy: extern func (Pointer, Pointer, SizeT)
memfree: extern (free) func (Pointer)
alloca: extern func (SizeT) -> Pointer

// Used for executing any/all cleanup (free~all) functions before program exit
// Default priority is 0 and will be executed first, then 1, 2, 3... etc.
GlobalCleanup: class {
	_functionPointers: static VectorList<Closure> = null
	_priorities: static VectorList<Int> = null
	_maxPriority := static 1
	register: static func (pointer: Func, priority := 0) {
		if (This _functionPointers == null) {
			This _functionPointers = VectorList<Closure> new()
			This _priorities = VectorList<Int> new()
		}
		This _functionPointers add(pointer as Closure)
		This _priorities add(priority)
		if (priority > This _maxPriority)
			This _maxPriority = priority
	}
	run: static func {
		if (This _functionPointers != null) {
			priority := 0
			while (!This _functionPointers empty && priority <= This _maxPriority) {
				index := This _functionPointers count - 1
				while (index >= 0) {
					if (This _priorities[index] == priority) {
						This _priorities removeAt(index)
						next := This _functionPointers remove(index)
						(next as Func)()
						(next) free()
					}
					index -= 1
				}
				priority += 1
			}
			This clear()
		}
	}
	clear: static func {
		if (This _functionPointers != null) {
			(This _functionPointers, This _priorities) free()
			(This _functionPointers, This _priorities) = (null, null)
		}
	}
}
