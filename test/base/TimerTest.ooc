/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use base
use ooc-unit

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
