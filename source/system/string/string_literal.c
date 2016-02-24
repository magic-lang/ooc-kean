#include "string_literal.h"
#include <assert.h>
#include <ooc/system/String-fwd.h>

static String__String** _literals = 0;
static size_t _literalsCount = 0;
static size_t _literalsCapacity = 0;

void string_literal_new(void* ptr) {
	assert(ptr);
	if (_literalsCount >= _literalsCapacity) {
		const size_t newCapacity = _literalsCapacity + 32;
		_literals = realloc(_literals, newCapacity * sizeof(String__String*));
		assert(_literals);
		_literalsCapacity = newCapacity;
	}
	_literals[_literalsCount++] = (String__String*)ptr;
}
void string_literal_free(void* ptr) {
	size_t i;
	assert(ptr);
	String__String* string = (String__String*)ptr;
	for (i=0 ; i<_literalsCount ; ++i) {
		if (_literals[i] == string) {
			_literals[i] = 0;
			break;
		}
	}
}
void string_literal_free_all() {
	if (_literals) {
		size_t i;
		for (i=0 ; i<_literalsCount ; ++i) {
			if (_literals[i]) {
				String__String_free(_literals[i]);
			}
		}
		free(_literals);
		_literalsCapacity = 0;
		_literalsCount = 0;
		_literals = 0;
	}
}
