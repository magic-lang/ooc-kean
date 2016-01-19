use base
use ooc-concurrent
use ooc-unit
import threading/Thread

//TODO Reimplement these tests once the problems with BlockedQueue have been fixed
/*ThreadPoolTest: class extends Fixture {
	init: func {
		super("ThreadPool")
		this add("threaded_noresult", func {
			pool := ThreadPool new()
			loopLength := 50_000_000
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
			loopLength := 1_000_000
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
			future := pool getFuture(func { for (i in 0 .. 50_000_000) { } Text new(c"pass", 4) } )
			future2 := pool getFuture(func { for (i in 0 .. 50_000_000) { } t"pass" } )
			future3 := pool getFuture(func { for (i in 0 .. 50_000_000) { } 123_456_789 } )
			result := future wait(Text new(c"fail", 4))
			result2 := future2 wait(t"fail")
			result3 := future3 wait(0)
			expect(result == t"pass")
			expect(result2 == t"pass")
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
			future := pool getFuture(func { for (i in 0 .. 50_000_000) { } t"pass" } )
			future cancel()
			comparison := t"fail"
			result := future wait(comparison)
			expect(result == comparison)
		})
		this add("wait with timeout", func {
			pool := ThreadPool new(2)
			promise := pool getPromise(func { for (i in 0 .. 50_000_000) { } } )
			promise2 := pool getPromise(func { for (i in 0 .. 100_000_000) { } } )
			future := pool getFuture(func { for (i in 0 .. 100_000_000) { } t"pass" } )
			future2 := pool getFuture(func { for (i in 0 .. 100_000_000) { } t"pass" } )
			expect(promise wait(0.01) == false)
			expect(future wait(0.01) == false)
			expect(promise wait() == true)
			expect(future wait() == true)
			expect(promise2 wait(10.00) == true)
			expect(future2 wait(10.00) == true)
			promise free()
			promise2 free()
			future free()
			future2 free()
			pool free()
		})
	}
}

ThreadPoolTest new() run() . free()*/
"ThreadPool [TODO: Temporarily suspended]" println()
