/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version (linux) {
include pthread | (_XOPEN_SOURCE=500, _POSIX_C_SOURCE=200809L)

PTHREAD_MUTEX_RECURSIVE: extern (PTHREAD_MUTEX_RECURSIVE_NP) Int

PThread: cover from pthread_t
PThreadCond: cover from pthread_cond_t
PThreadCondAttr: cover from pthread_condattr_t
PThreadMutex: cover from pthread_mutex_t
PThreadMutexAttr: cover from pthread_mutexattr_t

pthread_cond_init: extern func (cond: PThreadCond*, attr: PThreadCondAttr*) -> Int
pthread_cond_signal: extern func (cond: PThreadCond*) -> Int
pthread_cond_broadcast: extern func (cond: PThreadCond*) -> Int
pthread_cond_wait: extern func (cond: PThreadCond*, mutex: PThreadMutex*) -> Int
pthread_cond_destroy: extern func (cond: PThreadCond*) -> Int

pthread_mutex_timedlock: extern func (PThreadMutex*, TimeSpec*) -> Int
pthread_mutex_lock: extern func (PThreadMutex*)
pthread_mutex_unlock: extern func (PThreadMutex*)
pthread_mutex_init: extern func (PThreadMutex*, PThreadMutexAttr*)
pthread_mutex_destroy: extern func (PThreadMutex*)
pthread_mutexattr_init: extern func (PThreadMutexAttr*)
pthread_mutexattr_settype: extern func (PThreadMutexAttr*, Int)

pthread_create: extern func (threadPointer: PThread*, attributePointer, startRoutine, userArgument: Pointer) -> Int
pthread_join: extern func (thread: PThread, retval: Pointer*) -> Int
pthread_kill: extern func (thread: PThread, signal: Int) -> Int
pthread_self: extern func -> PThread
pthread_cancel: extern func (thread: PThread) -> Int
pthread_equal: extern func (thread0, thread1: PThread) -> Int
pthread_detach: extern func (thread: PThread) -> Int
}
