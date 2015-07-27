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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

import TimeSpan

DateTime: cover {
	/* Number of 100 ns intervals since 00.00 1/1/1 */
	_ticks: UInt64
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func ~fromYearMonthDay (year : Int, month: Int, day: Int) {}
	init: func ~fromHourMinuteSec (hour : Int, minute : Int, second : Int){
		if ( isHourValid(hour,minute,second) ){
			this _ticks = TimeSpan timeToTicks(hour,minute,second)
		} else {
			raise ("invalid input specified for constructor(hour,minute,second)")
		}
	}
	isLeapYear: static func (year: Int) -> Bool { (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0) }
	kean_base_dateTime_getTicks: unmangled func -> UInt64 { this _ticks }
	new: unmangled(kean_base_dateTime_new) static func ~API (ticks: UInt64) -> This { This new(ticks) }

	TicksPerMillisecond : static const Int = 1000
	TicksPerSecond : static const Int = TicksPerMillisecond*1000
	/* number of days in year ( non-leap ) */
	DaysInYear : static const Int = 365

	/* validate argument ranges for hour/minutes/seconds vaules */
	isHourValid : static func (hour : Int, minute : Int, second : Int) -> Bool {
		(hour>=0 && hour < 24 && minute >=0 && minute < 60 && second >=0 && second < 60)
	}

}
