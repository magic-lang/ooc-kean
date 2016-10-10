/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent
use unit

TestClass: class {
	intVal := 0
	init: func { this intVal = 99 }
	increase: func { this intVal += 1 }
}

PromiseTest: class extends Fixture {
	counter := func {
		for (i in 0 .. 50_000_000) { }
	}
	quickcounter := func {
		for (i in 0 .. 10) { }
	}

	init: func {
		super("Promise")
		this add("noresult", func {
			promise := Promise start(this quickcounter)
			promise2 := Promise start(this counter)
			promise3 := Promise start(this counter)
			promise4 := Promise start(this counter)
			promise5 := Promise start(this counter)
			promise2 cancel()
			expect(promise wait())
			expect(promise2 wait(), is false)
			expect(promise3 wait(), is true)
			expect(promise4 wait())
			expect(promise5 wait())
			(this counter as Closure) free()
			(this quickcounter as Closure) free()
			(promise, promise2, promise3, promise4, promise5) free()
		})
		this add("Future", func {
			future := Future start(String, func { for (i in 0 .. 50_000_000) { } "job1" })
			future2 := Future start(TestClass, func { for (i in 0 .. 50_000_000) { } TestClass new() })
			future3 := Future start(String, func { for (i in 0 .. 50_000_000) { } "job3" })
			future4 := Future start(String, func { for (i in 0 .. 50_000_000) { } "job4" })
			future5 := Future start(Int, func { for (i in 0 .. 50_000) { } 42 })
			future cancel()
			compare := "cancelled"
			result2 := future2 wait~default(null)
			result := future wait(compare)
			result3 := future3 wait(compare)
			result4 := future4 wait(compare)
			result5 := future5 wait~default(10)
			future3 cancel()
			expect(result == "cancelled")
			expect(result2 intVal == 99)
			expect(result3 == "job3")
			expect(result4 == "job4")
			expect(result5 == 42)
			(result, result2, result3, result4, compare, future, future2, future3, future4, future5) free()
		})
		this add("Wait with timeout", func {
			promise := Promise start(this counter)
			promise2 := Promise start(this counter)
			future := Future start(String, func { for (i in 0 .. 50_000_000) { } "job1" })
			promise wait(TimeSpan milliseconds(10))
			future wait(TimeSpan milliseconds(10))
			promise cancel()
			future cancel()
			expect(promise2 wait(TimeSpan seconds(10)), is true)
			promise2 cancel()
			expect(promise wait(), is false)
			expect(future wait(), is false)
			expect(promise2 wait(), is true)
			result := future wait("cancel")
			expect(result == "cancel")
			(result, promise, promise2, future) free()
		})
		this add("nonblocking free", func {
			promise2 := Promise start(this counter)
			promise := Promise start(this counter)
			promise free()
			promise2 wait() . free()
			promise2 = Promise start(this counter)
			promise2 wait() . free()
		})
		this add("many promises", func {
			list := VectorList<Promise> new()
			list add(Promise start(this counter)) . add(Promise start(this counter)) . add(Promise start(this counter))
			expect(Promise wait(list))
			list free()
		})
		this add("ClosurePromise", func {
			closurePromise := ClosurePromise new(|time|
				promise := Promise start(this counter)
				result := promise wait(time)
				promise free()
				result
			)
			expect(closurePromise wait(), is true)
			closurePromise free()
		})
		this add("ConditionPromise", func {
			promise := ConditionPromise new()
			counter := 0
			worker := WorkerThread new()
			expect(counter, is equal to(0))
			worker add(||
				Time sleepMilli(5)
				counter = 1
				promise signal()
			)
			expect(promise wait(), is true)
			expect(counter, is equal to(1))
			worker free()
			promise free()
		})
	}
}

PromiseTest new() run() . free()
