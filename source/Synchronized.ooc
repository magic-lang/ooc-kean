import threading/Thread

Synchronized: abstract class {
	_lock: Mutex
//	init: func (_lock: Mutex) { this lock = lock }
//	init: func ~def { This new(Mutex new()) }
//	lock: func {
//		this _lock lock()
//	}
//	lock: func ~function <T> (function: Func -> T) -> T {
//		result: T
//		this lock()
//		try {
//			result = function()
//			this unlock()
//		}
//		catch(e: Exception)
//		{
//			this unlock()
//			e throw()
//		}
//		result
//	}
//	lock: func ~action(action: Func) {
//		this lock()
//		try {
//			action()
//			this unlock()
//		}
//		catch(e: Exception)
//		{
//			this unlock()
//			e throw()
//		}
//	}
//	unlock: func {
//		this _lock unlock()
//	}
}
