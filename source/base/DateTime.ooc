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
use ooc-math
import math
import os/Time
TimeSpan: cover {
  days: UInt
  hours: UInt
  minutes: UInt
  seconds: UInt

  init: func@ (days := 0, hours := 0, minutes := 0, seconds := 0) {
    this days = days
    this hours = hours
    this minutes = minutes
    this seconds = seconds
  }
}

DateTime: cover {
  _year: Int
  year: Int { get {this _year} }
  _month: Int
  month: Int { get {this _month} }
  _day: Int
  day: Int { get { this _day } }
  date: String { get {} }
  _hour: Int
  hour: Int { get { this _hour } }
  _minute: Int
  minute: Int { get { this _minute } }
  _second: Int
  second: Int { get { this _second } }

  now: String { get { Time dateTime() } }

  init: func@ (year := 2014, month := 1, day := 1, hour := 0, minute := 0, second := 0) {
    this _year = year
    this _month = month
    this _day = day
    this _hour = hour
    this _minute = minute
    this _second = second
  }
  isLeapYear: func (year: Int) -> Bool {
    result := false
    if(year % 100 == 0) {
      result = (year % 400 == 0)
    }
    else
      result = (year % 4 == 0)
    result
  }
  getDaysInMonth: func (month: Int, year: Int) -> Int {
    result := match (month) {
      case 1 => 31
      case 2 => isLeapYear(year) ? 29 : 28
      case 3 => 31
      case 4 => 30
      case 5 => 31
      case 6 => 30
      case 7 => 31
      case 8 => 31
      case 9 => 30
      case 10 => 31
      case 11 => 30
      case 12 => 31
      case => -1
    }
    if (result == -1)
    	raise("Invalid month: #{month}")
    result
  }
  operator + (timeSpan: TimeSpan) -> This {
    secondRemainder := (this _second + timeSpan seconds) % 60
    minuteOverflow := (this _second + timeSpan seconds) / 60
    this _second = secondRemainder
    this _minute += minuteOverflow
    minuteRemainder := (this _minute + timeSpan minutes) % 60
    hourOverflow := (this _minute + timeSpan minutes) / 60
    this _minute = minuteRemainder
    this _hour += hourOverflow
    hourRemainder := (this _hour + timeSpan hours) % 24
    dayOverflow := (this _hour + timeSpan hours) / 24
    this _hour = hourRemainder
    this _day += dayOverflow + timeSpan days

    while(this _day > this getDaysInMonth(this _month, this _year)) {
      this _day -= this getDaysInMonth(this _month, this _year)
      if(this _month == 12) {
        this _month = 1
        this _year += 1
      }
      else
        this _month += 1
    }
    this
  }
  operator - (timeSpan: TimeSpan) -> This {
    secondRemainder := (60 + (this _second - (timeSpan seconds % 60))) % 60
    minuteOverflow := Int maximum~two(0, (59 + timeSpan seconds - this _second) / 60)
    this _second = secondRemainder
    minuteRemainder := (60 + (this _minute - (timeSpan minutes % 60) - minuteOverflow)) % 60
    hourOverflow := Int maximum~two(0, (59 + minuteOverflow + timeSpan minutes - this _minute) / 60)
    this _minute = minuteRemainder
    hourRemainder := (24 + (this _hour - (timeSpan hours % 24) - hourOverflow)) % 24
    dayOverflow := Int maximum~two(0, (23 + hourOverflow + timeSpan hours - this _hour) / 24)
    this _hour = hourRemainder
    this _day -= (dayOverflow + timeSpan days)
    while(this _day < 1) {
      this _day += this getDaysInMonth(this _month, this _year)
      if(this _month == 1) {
        this _month = 12
        this _year -= 1
      }
      else
        this _month -= 1
    }
    this
  }
  operator == (other: This) -> Bool {
    this _year == other _year &&
    this _month == other _month &&
    this _day == other _day &&
    this _hour == other _hour &&
    this _minute == other _minute &&
    this _second == other _second
  }
  operator < (other: This) -> Bool {
    other > this
  }
  operator > (other: This) -> Bool {
    result := false
    if(this _year > other _year)
      result = true
    else if(this _year < other _year)
      result = false
    else if(this _month > other _month)
      result = true
    else if(this _month < other _month)
      result = false
    else if(this _day > other _day)
      result = true
    else if(this _day < other _day)
      result = false
    else if(this _hour > other _hour)
      result = true
    else if(this _hour < other _hour)
      result = false
    else if(this _minute > other _minute)
      result = true
    else if(this _minute < other _minute)
      result = false
    else if(this _second > other _second)
      result = true
    result
  }
  toString: func -> String {
    year := this _year toString()
    month := this _month < 10 ? "0" + this _month toString() : this _month toString()
    day := this _day < 10 ? "0" + this _day toString() : this _day toString()
    hour := this _hour < 10 ? "0" + this _hour toString() : this _hour toString()
    minute := this _minute < 10 ? "0" + this _minute toString() : this _minute toString()
    second := this _second < 10 ? "0" + this _second toString() : this _second toString()
    year + "/" + month + "/" + day  + " " + hour + ":" + minute + ":" + second
  }


}
