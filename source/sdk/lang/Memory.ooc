include string // Memory routines in C are actually in string.h
version(windows) { include malloc }
else { include alloca }

// GC_MALLOC zeroes the memory, so in the non-gc version, we prefer to use calloc
// to the expense of some performance. Don't use malloc instead - existing ooc code
// is written assuming that gc_malloc zeroes the memory.
gc_malloc: func (size: SizeT) -> Pointer { gc_calloc(1, size) }
gc_malloc_atomic: extern(malloc) func (size: SizeT) -> Pointer
gc_strdup: extern(strdup) func (str: CString) -> CString
gc_realloc: extern(realloc) func (ptr: Pointer, size: SizeT) -> Pointer
gc_calloc: extern(calloc) func (nmemb: SizeT, size: SizeT) -> Pointer
gc_free: extern(free) func (ptr: Pointer)

//TODO Remove the above declarations once they're no longer used - only use the following:
malloc: extern func (SizeT) -> Pointer
calloc: extern func (SizeT, SizeT) -> Pointer
memset: extern func (Pointer, Int, SizeT) -> Pointer
memcmp: extern func (Pointer, Pointer, SizeT) -> Int
memmove: extern func (Pointer, Pointer, SizeT)
memcpy: extern func (Pointer, Pointer, SizeT)
free: extern func (Pointer)
alloca: extern func (SizeT) -> Pointer

// note: sizeof is intentionally not here. sizeof(Int) will be translated
// to sizeof(Int_class()), and thus will always give the same value for
// all types. 'Int size' should be used instead, which will be translated
// to 'Int_class()->size'
