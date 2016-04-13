/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use concurrent
use unit

WaitLockTest: class extends Fixture {
	timesTriggered: static Int = 0
	init: func {
		super("WaitLock")
		this add("_testWithMutexOwnership", This _testWithMutexOwnership)
		this add("_testWithoutMutexOwnership", This _testWithoutMutexOwnership)
		version (!windows && !android) { this add("_testWakeWithFailingCondition", This _testWakeWithFailingCondition) }
		this add("_testWakeWithPassingCondition", This _testWakeWithPassingCondition)
	}
	_testWithMutexOwnership: static func {
		waitLock := WaitLock new()
		waitLock free()
	}
	_testWithoutMutexOwnership: static func {
		mutex := Mutex new()
		waitLock := WaitLock new(mutex)
		waitLock free()
		expect(mutex, is notNull)
		mutex free()
	}
	_testWakeWithFailingCondition: static func {
		This timesTriggered = 0
		validResult := true
		globalMutex := Mutex new(MutexType Global)
		waitLock := WaitLock new()
		waitingThread := Thread new(||
			waitLock lockWhen(func -> Bool {
				This timesTriggered = This timesTriggered + 1
				false
			})
			waitLock unlock()
			expect(false) // Should be an unreachable statement
		)
		testThread := Thread new(||
			while (true) {
				waitLock lock()
				if (This timesTriggered >= 1)
					break
				waitLock unlock()
				Thread yield()
			}
			if (This timesTriggered != 1)
				globalMutex with(|| validResult = false)
			waitLock unlock()
			waitLock wake()
			result := waitingThread wait(0.05)
			if (result == true)
				globalMutex with(|| validResult = false)
			waitLock lock()
			if (This timesTriggered != 2)
				globalMutex with(|| validResult = false)
			waitLock unlock()
		)
		testThread start()
		waitingThread start()
		waitResult := testThread wait(1.0)
		expect(validResult, is true)
		expect(waitResult, is true)
		waitingThread cancel()
		expect(waitingThread wait(1.0), is true)
		(testThread, waitingThread, waitLock, globalMutex) free()
	}
	_testWakeWithPassingCondition: static func {
		This timesTriggered = 0
		waitLock := WaitLock new()
		waitingThread := Thread new(||
			waitLock lockWhen(func -> Bool {
				This timesTriggered = This timesTriggered + 1
				This timesTriggered == 2
			})
			waitLock unlock()
		)
		testThread := Thread new(||
			while (true) {
				waitLock lock()
				if (This timesTriggered >= 1)
					break
				waitLock unlock()
				Thread yield()
			}
			expect(This timesTriggered, is equal to(1))
			waitLock unlock()
			waitLock wake()
			while (true) {
				waitLock lock()
				if (This timesTriggered >= 2)
					break
				waitLock unlock()
				Thread yield()
			}
			expect(This timesTriggered, is equal to(2))
			waitLock unlock()
			while (!waitingThread wait(0.05))
				Thread yield()
		)
		testThread start()
		waitingThread start()
		expect(testThread wait(1.0), is true)
		expect(waitingThread alive(), is false)
		(testThread, waitingThread, waitLock) free()
	}
}

WaitLockTest new() run() . free()
