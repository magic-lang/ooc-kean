use ooc-base
import threading/Thread
import os/Time
use ooc-unit

PromiseTest: class extends Fixture {
	init: func {
		super("Promise")
		this add("noresult", func {
			promise := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise2 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise3 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise4 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise5 := Promise start(func { for (i in 0 .. 100_000_000) { } } )
			promise3 cancel()
			expect(promise wait())
			expect(promise2 wait())
			expect(promise3 wait() == false)
			expect(promise4 wait())
			expect(promise5 wait())
			promise free()
			promise2 free()
			promise3 free()
			promise4 free()
			promise5 free()
		})
		this add("result", func {
			promise := ResultPromise start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job1") } )
			promise2 := ResultPromise start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job2") } )
			promise3 := ResultPromise start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job3") } )
			promise4 := ResultPromise start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job4") } )
			promise cancel()
			compare := Text new("cancelled")
			result2 := promise2 wait(compare)
			result := promise wait(compare)
			result3 := promise3 wait(compare)
			result4 := promise4 wait(compare)
			promise3 cancel()
			expect(result == "cancelled")
			expect(result2 == "job2")
			expect(result3 == "job3")
			expect(result4 == "job4")
			promise free()
			promise2 free()
		})
	}
}

PromiseTest new() run()
