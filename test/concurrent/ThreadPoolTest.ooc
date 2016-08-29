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

ThreadPoolTest: class extends Fixture {
	init: func {
		super("ThreadPool")
		this add("threaded_noresult", func {
			pool := ThreadPool new()
			loopLength := 50_000_000
			promise1 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise2 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise3 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise4 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise5 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise4 cancel()
			expect(promise1 wait())
			expect(promise2 wait())
			expect(promise3 wait())
			expect(promise4 wait(), is false)
			expect(promise5 wait(), is true)
			(promise1, promise2, promise3, promise4, promise5, pool) free()
		})
		this add("threaded_sequential", func {
			pool := ThreadPool new(1)
			loopLength := 1_000_000
			promise1 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise2 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise3 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise4 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise5 := pool getPromise(func { for (i in 0 .. loopLength) { } })
			promise4 cancel()
			expect(promise1 wait())
			expect(promise2 wait())
			expect(promise3 wait())
			expect(promise4 wait(), is false)
			expect(promise5 wait(), is true)
			(promise1, promise2, promise3, promise4, promise5, pool) free()
		})
		this add("threaded_result", func {
			pool := ThreadPool new()
			future := pool getFuture(func { for (i in 0 .. 50_000_000) { } "pass" })
			future2 := pool getFuture(func { for (i in 0 .. 50_000_000) { } "pass" })
			future3 := pool getFuture(func { for (i in 0 .. 50_000_000) { } 123_456_789 })
			result := future wait("fail")
			result2 := future2 wait("fail")
			result3 := future3 wait(0)
			expect(result == "pass")
			expect(result2 == "pass")
			expect(result3 == 123_456_789)
			(future, future2, future3, result, result2, pool) free()
		})
		this add("threaded_result_cancel", func {
			pool := ThreadPool new()
			future := pool getFuture(func { for (i in 0 .. 5_000_000) { } "pass" })
			future cancel()
			comparison := "fail"
			result := future wait(comparison)
			expect(result == comparison)
			Time sleepMilli(1000)
			(future, pool) free()
		})
		this add("wait with timeout", func {
			pool := ThreadPool new(2)
			promise := pool getPromise(func { for (i in 0 .. 50_000_000) { } })
			promise2 := pool getPromise(func { for (i in 0 .. 100_000_000) { } })
			future := pool getFuture(func { for (i in 0 .. 100_000_000) { } "pass" })
			future2 := pool getFuture(func { for (i in 0 .. 100_000_000) { } "pass" })
			expect(promise wait(TimeSpan milliseconds(10)), is false)
			expect(future wait(TimeSpan milliseconds(10)), is false)
			expect(promise wait(), is true)
			expect(future wait(), is true)
			expect(promise2 wait(TimeSpan seconds(10)), is true)
			expect(future2 wait(TimeSpan seconds(10)), is true)
			(promise, promise2, future, future2, pool) free()
		})
	}
}

ThreadPoolTest new() run() . free()
