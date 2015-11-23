import native/[ConditionUnix, ConditionWin32]

WaitCondition: abstract class {
	new: static func -> This {
		version (unix || apple) {
			return ConditionUnix new() as This
		}
		version (windows) {
			return ConditionWin32 new() as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	wait: abstract func (mutex: Mutex) -> Bool

	signal: abstract func -> Bool

	broadcast: abstract func -> Bool
}