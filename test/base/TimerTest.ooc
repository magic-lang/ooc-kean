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
	timer := Timer new()
	clockTimer := ClockTimer new()

	init: func {
		super("Timer")
		this add("basic use of Timer", func {
			fast := this timerTestFunction(1_000)
			slow := this timerTestFunction(10_000_000)
			expect(slow > fast, is true)
		})
		this add("basic use of ClockTimer", func {
			fast := this clockTimerTestFunction(1_000)
			slow := this clockTimerTestFunction(10_000_000)
			expect(slow > fast, is true)
		})
	}

	timerTestFunction: func (loopLength: Int) -> Double {
		sum := 0
		this timer start()
		for (i in 0 .. loopLength) { sum = (sum + i) % 10 }
		this timer stop()
	}

	clockTimerTestFunction: func (loopLength: Int) -> Double {
		sum := 0
		this clockTimer start()
		for (i in 0 .. loopLength) { sum = (sum + i) % 10 }
		this clockTimer stop()
	}
}

TimerTest new() run() . free()
