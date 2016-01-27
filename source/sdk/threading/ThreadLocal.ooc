import native/[ThreadLocalUnix, ThreadLocalWin32]

ThreadLocal: abstract class <T> {
	set: abstract func (value: T)
	get: abstract func -> T
	hasValue: abstract func -> Bool
	new: static func <T> -> This<T> {
		result: This<T> = null
		version (unix || apple)
			result = ThreadLocalUnix<T> new() as This
		version (windows)
			result = ThreadLocalWin32<T> new() as This
		if (result == null)
			Exception new(This, "Unsupported platform!\n") throw()
		result
	}

	new: static func ~withVal <T> (val: T) -> This <T> {
		instance := This<T> new()
		instance set(val)
		instance
	}
}
