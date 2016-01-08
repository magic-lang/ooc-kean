import native/[ThreadLocalUnix, ThreadLocalWin32]

ThreadLocal: abstract class <T> {
	set: abstract func (value: T)
	get: abstract func -> T
	hasValue: abstract func -> Bool
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
}
