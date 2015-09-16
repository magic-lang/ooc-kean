use ooc-base
use ooc-unit
use ooc-math
import math
import os/Time

PromiseTest: class extends Fixture {
	init: func {
		super("Promise")
		this add("basic", func {
      p := ThreadedPromise< Cell<Int> > new(func() -> Cell<Int> {
        Time sleepSec (1)
        Cell<Int> new (42)
      })
      p2 := ThreadedPromise< Cell<Int> > new(func() -> Cell<Int> {
        Time sleepSec (2)
        Cell<Int> new (-5)
      })

      r := p wait()
      expect (r[Int] == 42)
      r2 := p2 wait()
      expect (r2[Int] == -5)
		})
	}
}

PromiseTest new() run()
