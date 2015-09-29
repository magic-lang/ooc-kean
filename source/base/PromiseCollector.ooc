use ooc-base
use ooc-collections

PromiseCollector: class {
	_backend : VectorList<Promise>
	init: func {
		this _backend = VectorList<Promise> new()
	}
	free: func {
		this _backend free()
		super()
	}
	add: func (promise: Promise) {
		this _backend add(promise)
	}
	wait: func (haltOnCancel := false) -> Bool {
		status := true
		for (i in 0 .. this _backend count) {
			status = status && this _backend[i] wait()
			if (!status && haltOnCancel)
				break
		}
		status
	}
	clear: func {
		this _backend clear()
	}
	operator + (promise: Promise) -> This {
		this add(promise)
		this
	}
	operator + (other: This) -> This {
		this _backend append(other _backend)
		this
	}
	operator += (element: Promise) {
		this add(element)
	}
	operator += (other: This) {
		this _backend append(other _backend)
	}
}
