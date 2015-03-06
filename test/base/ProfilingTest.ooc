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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
import DebugPrint

DebugPrint initialize(func (message: String) {println(message)})
DebugPrint _level = DebugLevels Everything as Int


testfunction: func {
	profiling_test := Profiling new("testfunction", 2)
	profiling_test start()
	for (i in 0..10000) {}
	profiling_test stop()
}

testfunction2: func {
	profiling_test := Profiling new("testfunction2", 1)
	profiling_test start()
	for (i in 0..1000) {}
	profiling_test stop()
}

Profiling printResults()
profiling := Profiling new("main", 1)

profiling  start()
for (i in 0..10) {}
profiling stop()

profiling start()
for (i in 0..100_000_000) {}
profiling stop()

profiling start()
for (i in 0..10000) {}
profiling stop()

testfunction()
Profiling resetAll()
Profiling printResults()

/*
profiling start()
for (i in 0..1_000_000_000) {}
profiling stop()

profiling start()
for (i in 0..100) {}
profiling stop()

profiling start()
for (i in 0..50) {}
profiling stop()

profiling start()
for (i in 0..8) {}
profiling stop()
testfunction2()

DebugPrint print("first print",0)
DebugPrint print("second print", 1)
DebugPrint print("third print", 2)
DebugPrint printProfilingData()*/
