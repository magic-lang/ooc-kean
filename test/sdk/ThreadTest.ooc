use ooc-unit
use ooc-base
import threading/Thread
import os/Time

ThreadTest: class extends Fixture {
	init: func {
		super("Thread")
		this add("starting thread", This _testStartingThread)
		this add("canceling thread", This _testCancelation)
	}
	_testStartingThread: static func {
		threadStarted := Cell<Int> new(0)
		job := func {
			threadStarted set(1)
		}
		thread := Thread new(|| job())
		expect(threadStarted get() == 0)
		expect(thread start())
		expect(thread wait())
		expect(threadStarted get() == 1)
		thread free()
	}
	_testCancelation: static func {
		expectedValue := 1_000
		value := Cell<Int> new(0)
		mutex := Mutex new()
		startedCondition := WaitCondition new()
		job := func {
			startedCondition broadcast()
			mutex unlock()
			while (value get() < expectedValue) {
				value set(value get() + 1)
				Thread yield()
				Time sleepMilli(1)
			}
		}
		thread := Thread new(|| job())
		expect(thread start())
		thread wait()
		expect(value get() == expectedValue)
		thread free()
		value set(0)
		thread = Thread new(|| job())
		expect(thread start())
		mutex lock()
		startedCondition wait(mutex)
		expect(thread cancel())
		expect(thread wait())
		expect(value get() < expectedValue)
		thread free()
		startedCondition free()
	}
}

ThreadTest new() run()
