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

use ooc-base
import Timer


testfunction: func {

	println("Test")
	t_test := Timer new()
	t_test startTimer()
	for (i in 0..10000) {

	}
	t_test stopTimer("testfunction")

}

y: Double
t := Timer new()
t  startTimer()

for (i in 0..10) {

}

t stopTimer("1")

t startTimer()

for (i in 0..100000000) {

}

t stopTimer("2")


t startTimer()

for (i in 0..10000) {

}

t stopTimer("3")

testfunction()

t startTimer()

for (i in 0..1000000000) {

}

t stopTimer("4")

t startTimer()

for (i in 0..100) {

}

t stopTimer("5")


t startTimer()

for (i in 0..50) {

}

t stopTimer("6")



t startTimer()

for (i in 0..8) {

}

t stopTimer("7")




t printTimeList()
