use ooc-base
use ooc-unit

ReferenceCounterTest: class extends Fixture {
	init: func {
		super("ReferenceCounterTest [TODO: Not implemented as a fixture!]")
	}
}

Thing: class {
	init: func
}

t := Thing new()
r := ReferenceCounter new(t)
r update(-1)
