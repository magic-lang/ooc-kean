use ooc-base
use ooc-unit

PromiseTest: class extends Fixture {
	counter := func {
		for (i in 0 .. 100_000_000) { }
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
			promise2 cancel()
			expect(promise wait())
			expect(promise2 wait(), is equal to(false))
			expect(promise3 wait(), is equal to(true))
			expect(promise4 wait())
			(counter as Closure) dispose()
			(quickcounter as Closure) dispose()
			promise free()
			promise2 free()
			promise3 free()
			promise4 free()
		})
		this add("result", func {
			future := Future start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job1") } )
			future2 := Future start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job2") } )
			future3 := Future start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job3") } )
			future4 := Future start(Text, func { for (i in 0 .. 100_000_000) { } Text new("job4") } )
			future cancel()
			compare := Text new("cancelled")
			result2 := future2 wait(compare)
			result := future wait(compare)
			result3 := future3 wait(compare)
			result4 := future4 wait(compare)
			future3 cancel()
			expect(result == "cancelled")
			expect(result2 == "job2")
			expect(result3 == "job3")
			expect(result4 == "job4")
			result free()
			result2 free()
			result3 free()
			result4 free()
			future free()
			future2 free()
			future3 free()
			future4 free()
		})
	}
}

PromiseTest new() run()
