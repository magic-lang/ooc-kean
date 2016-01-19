use base
use ooc-geometry
import include/x11
import ../[EventLoop, DisplayWindow, GuiEvent]
import UnixWindow

version((unix || apple) && !android) {
X11EventLoop: class extends EventLoop {
	init: func
	processEvents: override func (receiver: DisplayWindow) {
		xWindow := (receiver as UnixWindowBase) _xWindow
		while (XPending(xWindow display)) {
			event: XEventOoc
			guiEvent: MouseEvent
			XNextEvent(xWindow display, event&)
			if (event type == ButtonPress)
				receiver _onMousePress(guiEvent = MouseEvent new(IntPoint2D new(event xkey x, event xkey y)))
			if (event type == ButtonRelease)
				receiver _onMouseRelease(guiEvent = MouseEvent new(IntPoint2D new(event xkey x, event xkey y)))
			if (guiEvent)
				guiEvent free()
		}
	}
}
}
