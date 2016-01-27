import native/[ThreadUnix, ThreadWin32]

Thread: abstract class {
	_code: Func

	start: abstract func -> Bool

	wait: abstract func -> Bool

	wait: abstract func ~timed (seconds: Double) -> Bool

	cancel: abstract func -> Bool

	alive: abstract func -> Bool
	new: static func (._code) -> This {
		version (unix || apple) {
			return ThreadUnix new(_code) as This
		}
		version (windows) {
			return ThreadWin32 new(_code) as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}
	currentThread: static func -> This {
		version (unix || apple) {
			return ThreadUnix _currentThread()
		}
		version (windows) {
			return ThreadWin32 _currentThread()
		}
		null
	}
	currentThreadId: static func -> Long {
		version (unix || apple) {
			return pthread_self() as Long
		}
		version (windows) {
			return GetCurrentThread() as Long
		}
		0L
	}
	equals: static func (threadId1, threadId2: Long) -> Bool {
		result: Bool
		version (unix || apple)
			result = pthread_equal(threadId1 as PThread, threadId2 as PThread) != 0
		else
			result = threadId1 == threadId2
		result
	}

	yield: static func -> Bool {
		version (unix || apple) {
			return ThreadUnix _yield()
		}
		version (windows) {
			return ThreadWin32 _yield()
		}
		false
	}
}
