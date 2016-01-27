use unit
use base
import threading/[Thread, Mutex, WaitCondition]

ThreadTest: class extends Fixture {
	init: func {
		super("Thread")
		this add("starting thread", This _testStartingThread)
		version (!windows) { this add("canceling thread", This _testCancelation) }
		this add("thread id", This _testThreadId)
	}
	_testStartingThread: static func {
		threadStarted := Cell<Int> new(0)
		job := func {
			threadStarted set(1)
		}
		thread := Thread new(job)
		expect(threadStarted get(), is equal to(0))
		expect(thread start())
		expect(thread wait())
		expect(threadStarted get(), is equal to(1))
		thread free()
		(job as Closure) free()
		threadStarted free()
	}
	_testCancelation: static func {
		expectedValue := 1_000
		value := Cell<Int> new(0)
		mutex := Mutex new()
		startedCondition := WaitCondition new()
		job := func {
			mutex lock()
			startedCondition broadcast()
			mutex unlock()
			while (value get() < expectedValue) {
				value set(value get() + 1)
				Thread yield()
				Time sleepMilli(1)
			}
		}
		thread := Thread new(job)
		expect(thread start())
		thread wait()
		expect(value get(), is equal to(expectedValue))
		thread free()
		value set(0)
		thread = Thread new(job)
		mutex lock()
		expect(thread start())
		startedCondition wait(mutex)
		expect(thread cancel())
		expect(thread wait())
		expect(value get() < expectedValue)
		thread free()
		startedCondition free()
		mutex free()
		value free()
		(job as Closure) free()
	}
	_testThreadId: static func {
		myId := Thread currentThreadId()
		otherId := Cell<Long> new(0L)
		job := func {
			otherId set(Thread currentThreadId())
		}
		thread := Thread new(job)
		expect(thread start())
		expect(thread wait())
		thread free()
		expect(Thread equals(myId, otherId get()) == false)
		otherId free()
		(job as Closure) free()
		expect(Thread equals(myId, Thread currentThreadId()))
	}
}

ThreadTest new() run() . free()
