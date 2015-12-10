use ooc-base
import DisplayWindow
import EventLoop

GuiApplication: class extends Application {
	_window: DisplayWindow
	_eventLoop: EventLoop
	window ::= this _window
	init: func (argc: Int, argv: CString*, windowSize: IntVector2D, windowName: String) {
		super(argc, argv)
		this _window = DisplayWindow create(windowSize, windowName)
		this _eventLoop = EventLoop create()
	}
	free: override func {
		if (this _window)
			this _window free()
		if (this _eventLoop)
			this _eventLoop free()
		super()
	}
	processEvents: override func {
		this _eventLoop processEvents(this _window)
	}
}
