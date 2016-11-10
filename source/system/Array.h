#ifndef OOC_ARRAY_H_
#define OOC_ARRAY_H_

#define array_malloc(size) calloc(1, (size))
#define array_free free

#include <stdint.h>

#define _lang_array__Array_new(type, size) ((_lang_array__Array) { size, array_malloc((size) * sizeof(type)) });

#if defined(safe)
#define _lang_array__Array_get(array, index, type) ( \
    ((type*) array.data)[(index < 0 || index >= array.length) ? kean_exception_outOfBoundsException_throw(index, array.length), -1 : index])
#define _lang_array__Array_set(array, index, type, value) \
    (((type*) array.data)[(index < 0 || index >= array.length) ? kean_exception_outOfBoundsException_throw(index, array.length), -1 : index] = value)
#else
#define _lang_array__Array_get(array, index, type) ( \
    ((type*) array.data)[index])
#define _lang_array__Array_set(array, index, type, value) \
    (((type*) array.data)[index] = value)
#endif

#define _lang_array__Array_free(array) { array_free(array.data); }

typedef struct {
    size_t length;
    void* data;
} _lang_array__Array;

#endif
