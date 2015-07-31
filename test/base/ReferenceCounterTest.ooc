use ooc-base

Thing: class {
	init: func
}

t := Thing new()
r := ReferenceCounter new(t)
r update(-1)
