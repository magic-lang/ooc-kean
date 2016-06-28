#ifndef OOC_ATOMIC_WRAPPER_H
#define OOC_ATOMIC_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdatomic.h>
#include <stdbool.h>

extern void atomic_init_int(volatile atomic_int*, int);
extern void atomic_store_int(volatile atomic_int*, int);
extern int atomic_load_int(const volatile atomic_int*);
extern int atomic_exchange_int(volatile atomic_int*, int);
extern int atomic_fetch_add_int(volatile atomic_int*, int);
extern int atomic_fetch_sub_int(volatile atomic_int*, int);

extern void atomic_init_bool(volatile atomic_bool*, bool);
extern void atomic_store_bool(volatile atomic_bool*, bool);
extern bool atomic_load_bool(const volatile atomic_bool*);
extern bool atomic_exchange_bool(volatile atomic_bool*, bool);
extern bool atomic_fetch_and_bool(volatile atomic_bool*, bool);
extern bool atomic_fetch_or_bool(volatile atomic_bool*, bool);
extern bool atomic_fetch_xor_bool(volatile atomic_bool*, bool);

#ifdef __cplusplus
}
#endif

#endif
