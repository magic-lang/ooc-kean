#include "string_literal.h"
#include <assert.h>
#include <ooc/system/String-fwd.h>
#include <ooc/system/Mutex.h>

#if defined(__WIN32__) || defined(__WIN64__)
	typedef Handle mutex_t;
	#define MUTEX_INIT NULL
	static void mutex_lock(mutex_t* m) {
		if (*m == NULL) {
			HANDLE mutex = CreateMutex(NULL, FALSE, NULL);
			if (InterlockedCompareExchangePointer(m, mutex, NULL) != NULL)
				CloseHandle(mutex);
		}
		WaitForSingleObject(*m, INFINITE);
	}
	static void mutex_unlock(mutex_t* m){ ReleaseMutex(*m); }
	static void mutex_free(mutex_t* m){ CloseHandle(*m); }
#else
	typedef pthread_mutex_t mutex_t;
	#define MUTEX_INIT PTHREAD_MUTEX_INITIALIZER
	static void mutex_lock(mutex_t* m) { pthread_mutex_lock(m); }
	static void mutex_unlock(mutex_t* m){ pthread_mutex_unlock(m); }
	static void mutex_free(mutex_t*  m){ pthread_mutex_destroy(m); }
#endif

mutex_t _literalsMutex = MUTEX_INIT;
static String__String** _literals = 0;
static size_t _literalsCount = 0;
static size_t _literalsCapacity = 0;

void string_literal_new(void* ptr) {
	assert(ptr);
	mutex_lock(&_literalsMutex);
	if (_literalsCount >= _literalsCapacity) {
		const size_t newCapacity = _literalsCapacity + 32;
		_literals = realloc(_literals, newCapacity * sizeof(String__String*));
		assert(_literals);
		_literalsCapacity = newCapacity;
	}
	_literals[_literalsCount++] = (String__String*)ptr;
	mutex_unlock(&_literalsMutex);
}
void string_literal_free(void* ptr) {
	size_t i;
	assert(ptr);
	String__String* string = (String__String*)ptr;
	mutex_lock(&_literalsMutex);
	for (i=0 ; i<_literalsCount ; ++i) {
		if (_literals[i] == string) {
			_literals[i] = 0;
			break;
		}
	}
	mutex_unlock(&_literalsMutex);
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
		mutex_free(&_literalsMutex);
	}
}
