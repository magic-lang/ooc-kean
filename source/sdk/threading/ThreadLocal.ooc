import native/[ThreadLocalUnix, ThreadLocalWin32]

/**
 * A ThreadLocal is a variable whose data is not shared by all threads
 * (as it is for normal global variables), but each thread has got
 * its own storage.
 */
ThreadLocal: abstract class <T> {
	new: static func <T> -> This<T> {
		version (unix || apple) {
			return ThreadLocalUnix<T> new() as This
		}
		version (windows) {
			return ThreadLocalWin32<T> new() as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	new: static func ~withVal <T> (val: T) -> This <T> {
		instance := This<T> new()
		instance set(val)
		instance
	}

	set: abstract func (value: T)

	get: abstract func -> T

	hasValue?: abstract func -> Bool
}
