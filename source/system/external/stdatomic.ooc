/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include ./atomic

atomic_int: extern cover
atomic_bool: extern cover

atomic_init_int: extern func (atomic_int*, Int)
atomic_store_int: extern func (atomic_int*, Int)
atomic_load_int: extern func (atomic_int*) -> Int
atomic_exchange_int: extern func (atomic_int*, Int) -> Int
atomic_fetch_add_int: extern func (atomic_int*, Int) -> Int
atomic_fetch_sub_int: extern func (atomic_int*, Int) -> Int

atomic_init_bool: extern func (atomic_bool*, Bool)
atomic_store_bool: extern func (atomic_bool*, Bool)
atomic_load_bool: extern func (atomic_bool*) -> Bool
atomic_exchange_bool: extern func (atomic_bool*, Bool) -> Bool
atomic_fetch_and_bool: extern func (atomic_bool*, Bool) -> Bool
atomic_fetch_or_bool: extern func (atomic_bool*, Bool) -> Bool
atomic_fetch_xor_bool: extern func (atomic_bool*, Bool) -> Bool
