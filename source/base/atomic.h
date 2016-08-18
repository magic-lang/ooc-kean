#ifndef OOC_ATOMIC_WRAPPER_H
#define OOC_ATOMIC_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdatomic.h>
#include <stdbool.h>

extern void atomic_init_int(atomic_int*, int);
extern void atomic_store_int(atomic_int*, int);
extern int atomic_load_int(atomic_int*);
extern int atomic_exchange_int(atomic_int*, int);
extern int atomic_fetch_add_int(atomic_int*, int);
extern int atomic_fetch_sub_int(atomic_int*, int);

extern void atomic_init_bool(atomic_bool*, bool);
extern void atomic_store_bool(atomic_bool*, bool);
extern bool atomic_load_bool(atomic_bool*);
extern bool atomic_exchange_bool(atomic_bool*, bool);
extern bool atomic_fetch_and_bool(atomic_bool*, bool);
extern bool atomic_fetch_or_bool(atomic_bool*, bool);
extern bool atomic_fetch_xor_bool(atomic_bool*, bool);

#ifdef __cplusplus
}
#endif

#endif
