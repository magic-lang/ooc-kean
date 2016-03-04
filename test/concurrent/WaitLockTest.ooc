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
	init: func {
		super("WithLock")
		this add("_testWithMutexOwnership", This _testWithMutexOwnership)
		this add("_testWithoutMutexOwnership", This _testWithoutMutexOwnership)
		this add("_testWakeWithFailingCondition", This _testWakeWithFailingCondition)
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
		mutex free()
	}
	_testWakeWithFailingCondition: static func {
		timesTriggered := 0
		timesTriggeredRef := timesTriggered&
		waitLock := WaitLock new()
		waitingThread := Thread new(||
			waitLock lockWhen(||
				timesTriggeredRef@ = timesTriggeredRef@ + 1
				false
			)
			waitLock unlock()
			expect(false)
		)
		testThread := Thread new(||

			while (true) {
				waitLock lock()
				if(timesTriggeredRef@ >= 1)
					break
				waitLock unlock()
				Thread yield()
			}
			expect(timesTriggeredRef@ == 1)
			waitLock unlock()

			waitLock wake()
			expect(!waitingThread wait(0.05))
			waitLock lock()
			expect(timesTriggeredRef@ == 2)
			waitLock unlock()
		)
		testThread start()
		waitingThread start()
		expect(testThread wait(0.1))
		testThread free()
		waitingThread cancel()
		expect(waitingThread wait(0.1))
		waitingThread free()
		waitLock free()
	}
	_testWakeWithPassingCondition: static func {
		timesTriggered := 0
		timesTriggeredRef := timesTriggered&
		waitLock := WaitLock new()
		waitingThread := Thread new(||
			waitLock lockWhen(||
				timesTriggeredRef@ = timesTriggeredRef@ + 1
				timesTriggeredRef@ == 2
			)
			waitLock unlock()
		)
		testThread := Thread new(||
			while (true) {
				waitLock lock()
				if(timesTriggeredRef@ >= 1)
					break
				waitLock unlock()
				Thread yield()
			}
			expect(timesTriggeredRef@ == 1)
			waitLock unlock()
			waitLock wake()
			while (true) {
				waitLock lock()
				if(timesTriggeredRef@ >= 2)
					break
				waitLock unlock()
				Thread yield()
			}
			expect(timesTriggeredRef@ == 2)
			waitLock unlock()
			while(!waitingThread wait(0.05))
				Thread yield()
		)
		testThread start()
		waitingThread start()
		expect(testThread wait(0.1))
		testThread free()
		expect(!waitingThread alive())
		waitingThread free()
		waitLock free()
	}
}

WaitLockTest new() run() . free()
