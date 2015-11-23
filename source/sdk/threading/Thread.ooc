import native/[ThreadUnix, ThreadWin32]

Thread: abstract class {
	_code: Func

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

	start: abstract func -> Bool

	wait: abstract func -> Bool

	wait: abstract func ~timed (seconds: Double) -> Bool

	cancel: abstract func -> Bool

	alive?: abstract func -> Bool

	currentThread: static func -> This {
		version (unix || apple) {
			return ThreadUnix _currentThread()
		}
		version (windows) {
			return ThreadWin32 _currentThread()
		}
		null
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
