/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdatomic

memory_order_relaxed: extern Int
memory_order_consume: extern Int
memory_order_acquire: extern Int
memory_order_release: extern Int
memory_order_acq_rel: extern Int
memory_order_seq_cst: extern Int

atomic_int: extern cover

atomic_init: extern func (atomic_int*, Int)
atomic_store: extern func (atomic_int*, Int)
atomic_load: extern func (atomic_int*) -> Int
atomic_exchange: extern func (atomic_int*, Int) -> Int
atomic_fetch_add: extern func (atomic_int*, Int) -> Int
atomic_fetch_sub: extern func (atomic_int*, Int) -> Int
