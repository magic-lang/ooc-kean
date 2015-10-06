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
		this add("threaded_sequential", func {
			pool := ThreadPool new(1)
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
			future := pool getFuture(func { for (i in 0 .. 100_000_000) { } Text new(c"pass", 4) } )
			future2 := pool getFuture(func { for (i in 0 .. 100_000_000) { } "pass" } )
			future3 := pool getFuture(func { for (i in 0 .. 100_000_000) { } 123_456_789 } )
			result := future wait(Text new(c"fail", 4))
			result2 := future2 wait("fail")
			result3 := future3 wait(0)
			expect(result == "pass")
			expect(result2 == "pass")
			expect(result3 == 123_456_789)
			future free()
			future2 free()
			future3 free()
			result free()
			result2 free()
			pool free()
		})
		this add("threaded_result_cancel", func {
			pool := ThreadPool new()
			future := pool getFuture(func { for (i in 0 .. 100_000_000) { } "pass" } )
			future cancel()
			comparison := "fail"
			result := future wait(comparison)
			expect(result == comparison)
		})
	}
}

ThreadPoolTest new() run()
