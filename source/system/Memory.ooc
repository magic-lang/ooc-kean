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
malloc: extern func (SizeT) -> Pointer
calloc: extern func (SizeT, SizeT) -> Pointer
realloc: extern func (Pointer, SizeT) -> Pointer
memset: extern func (Pointer, Int, SizeT) -> Pointer
memcmp: extern func (Pointer, Pointer, SizeT) -> Int
memmove: extern func (Pointer, Pointer, SizeT)
memcpy: extern func (Pointer, Pointer, SizeT)
memfree: extern (free) func (Pointer)
alloca: extern func (SizeT) -> Pointer

// note: sizeof is intentionally not here. sizeof(Int) will be translated
// to sizeof(Int_class()), and thus will always give the same value for
// all types. 'Int size' should be used instead, which will be translated
// to 'Int_class()->size'

// This one is still here because rock is hard-coded to use it
gc_malloc: func (size: SizeT) -> Pointer { calloc(1, size) }
