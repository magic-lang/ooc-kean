#include "atomic.h"

void atomic_init_int(volatile atomic_int* object, int value) {
	atomic_init(object, value);
}

void atomic_store_int(volatile atomic_int* object, int value) {
	atomic_store(object, value);
}

int atomic_load_int(const volatile atomic_int* object) {
	return atomic_load(object);
}

int atomic_exchange_int(volatile atomic_int* object, int value) {
	return atomic_exchange(object, value);
}

int atomic_fetch_add_int(volatile atomic_int* object, int value) {
	return atomic_fetch_add(object, value);
}

int atomic_fetch_sub_int(volatile atomic_int* object, int value) {
	return atomic_fetch_sub(object, value);
}

void atomic_init_bool(volatile atomic_bool* object, bool value) {
	atomic_init(object, value);
}

void atomic_store_bool(volatile atomic_bool* object, bool value) {
	atomic_store(object, value);
}

bool atomic_load_bool(const volatile atomic_bool* object) {
	return atomic_load(object);
}

bool atomic_exchange_bool(volatile atomic_bool* object, bool value) {
	return atomic_exchange(object, value);
}

bool atomic_fetch_and_bool(volatile atomic_bool* object, bool value) {
	return atomic_fetch_and(object, value);
}

bool atomic_fetch_or_bool(volatile atomic_bool* object, bool value) {
	return atomic_fetch_or(object, value);
}

bool atomic_fetch_xor_bool(volatile atomic_bool* object, bool value) {
	return atomic_fetch_xor(object, value);
}
