/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

TimerTest: class extends Fixture {
	wallTimer := WallTimer new()
	cpuTimer := CpuTimer new()

	init: func {
		super("WallTimer")
		this add("basic use of WallTimer", func {
			fast := this wallTimerTestFunction(1_000)
			slow := this wallTimerTestFunction(10_000_000)
			expect(slow > fast, is true)
		})
		this add("basic use of CpuTimer", func {
			fast := this cpuTimerTestFunction(1_000)
			slow := this cpuTimerTestFunction(10_000_000)
			expect(slow > fast, is true)
		})
	}
	wallTimerTestFunction: func (loopLength: Int) -> Double {
		sum := 0
		this wallTimer start()
		for (i in 0 .. loopLength) { sum = (sum + i) % 10 }
		this wallTimer stop()
	}
	cpuTimerTestFunction: func (loopLength: Int) -> Double {
		sum := 0
		this cpuTimer start()
		for (i in 0 .. loopLength) { sum = (sum + i) % 10 }
		this cpuTimer stop()
	}
	free: override func {
		this wallTimer free()
		this cpuTimer free()
		super()
	}
}

TimerTest new() run() . free()
