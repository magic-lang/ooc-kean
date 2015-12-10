use ooc-base
import DisplayWindow
import x11/X11EventLoop

EventLoop: abstract class {
	init: func
	processEvents: abstract func (receiver: DisplayWindow)
	create: static func -> This {
		result: This
		version(unix || apple)
			result = X11EventLoop new()
		else
			raise("EventLoop not implemented on this platform!")
		result
	}
}
