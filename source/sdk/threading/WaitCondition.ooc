import native/[ConditionUnix, ConditionWin32]
import Mutex

WaitCondition: abstract class {
	wait: abstract func (mutex: Mutex) -> Bool
	signal: abstract func -> Bool
	broadcast: abstract func -> Bool
	new: static func -> This {
		result: This = null
		version (unix || apple)
			result = ConditionUnix new() as This
		version (windows)
			result = ConditionWin32 new() as This
		if (result == null)
			Exception new(This, "Unsupported platform!\n") throw()
		result
	}
}
