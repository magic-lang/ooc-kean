use ooc-base
use ooc-unit
import threading/Thread

ThreadPoolTest: class extends Fixture {
	init: func {
		super("ThreadPool")
		this add("threaded_noresult", func {
			pool := ThreadPool new()
			loopLength := 100_000_000
			promise1 := pool getPromise(func { for (i in 0 .. loopLength) { } } )
			promise2 := pool getPromise(func { for (i in 0 .. loopLength) { } } )
			promise3 := pool getPromise(func { for (i in 0 .. loopLength) { } } )
			promise4 := pool getPromise(func { for (i in 0 .. loopLength) { } } )
			promise5 := pool getPromise(func { for (i in 0 .. loopLength) { } } )
			promise4 cancel()
			expect(promise1 wait())
			expect(promise2 wait())
			expect(promise3 wait())
			expect(promise4 wait(), is false)
			expect(promise5 wait(), is true)
			promise1 free()
			promise2 free()
			promise3 free()
			promise4 free()
			promise5 free()
			pool free()
		})
		this add("threaded_result", func {
			pool := ThreadPool new()
			promise := pool getFuture(func { for (i in 0 .. 100_000_000) { } Text new(c"pass", 4) } )
			promise2 := pool getFuture(func { for (i in 0 .. 100_000_000) { } "pass" } )
			promise3 := pool getFuture(func { for (i in 0 .. 100_000_000) { } 123_456_789 } )
			result := promise wait(Text new(c"fail", 4))
			result2 := promise2 wait("fail")
			result3 := promise3 wait(0)
			expect(result == "pass")
			expect(result2 == "pass")
			expect(result3 == 123_456_789)
			promise free()
			promise2 free()
			promise3 free()
			result free()
			result2 free()
			pool free()
		})
		this add("threaded_result_cancel", func {
			pool := ThreadPool new()
			promise := pool getFuture(func { for (i in 0 .. 100_000_000) { } "finished" } )
			promise cancel()
			result := promise wait("cancelled")
			expect(result == "cancelled")
			promise free()
			result free()
			pool free()
		})
	}
}

ThreadPoolTest new() run()
