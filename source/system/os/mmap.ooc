/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version (linux || apple) {
	include sys/mman

	PROT_EXEC: extern Int
	PROT_WRITE: extern Int
	PROT_READ: extern Int
	PROT_NONE: extern Int

	MAP_FIXED: extern Int
	MAP_SHARED: extern Int
	MAP_PRIVATE: extern Int
	MAP_DENYWRITE: extern Int
	MAP_EXECUTABLE: extern Int
	MAP_NORESERVE: extern Int
	MAP_LOCKED: extern Int
	MAP_GROWSDOWN: extern Int
	MAP_ANONYMOUS: extern Int
	MAP_ANON: extern Int
	MAP_FILE: extern Int
	MAP_32BIT: extern Int
	MAP_POPULATE: extern Int
	MAP_NONBLOCK: extern Int

	MAP_FAILED: extern Pointer

	MADV_NORMAL: extern Int
	MADV_SEQUENTIAL: extern Int
	MADV_RANDOM: extern Int
	MADV_WILLNEED: extern Int
	MADV_DONTNEED: extern Int

	MS_ASYNC: extern Int
	MS_SYNC: extern Int
	MS_INVALIDATE: extern Int

	mmap: extern func (start: Pointer, length: SizeT, prot: Int, flags: Int, fd: Int, offset: Int) -> Pointer
	munmap: extern func (start: Pointer, length: SizeT) -> Int
	mprotect: extern func (addr: Pointer, length: SizeT, prot: Int) -> Int
	madvise: extern func (addr: Pointer, length: SizeT, advice: Int) -> Int
	mincore: extern func (addr: Pointer, length: SizeT, vec: Char*) -> Int
	minherit: extern func (addr: Pointer, length: SizeT, inherit: Int) -> Int
	msync: extern func (addr: Pointer, length: SizeT, flags: Int) -> Int
	mlock: extern func (addr: Pointer, length: SizeT) -> Int
	munlock: extern func (addr: Pointer, length: SizeT) -> Int
}

version (windows) {
	include windows

	VirtualProtect: extern func (Pointer, SizeT, Long /* DWORD */, Long* /* PDWORD */) -> Bool

	PAGE_EXECUTE,
	PAGE_EXECUTE_READ,
	PAGE_EXECUTE_READWRITE,
	PAGE_EXECUTE_WRITECOPY,
	PAGE_NOACCESS,
	PAGE_READONLY,
	PAGE_READWRITE,
	PAGE_WRITECOPY : extern Long
}
