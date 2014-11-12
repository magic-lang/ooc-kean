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
import Logging

DebugPrinting printFunctionPointer = func (message: String) {println(message)}

testfunction: func {
	log_test := Logging new("testfunction", 2)
	log_test start()
	for (i in 0..10000) {}
	log_test stop()
}

testfunction2: func {
	log_test := Logging new("testfunction2", 1)
	log_test start()
	for (i in 0..1000) {}
	log_test stop()
}


log := Logging new("main", 1)

log  start()
for (i in 0..10) {}
log stop()

log start()
for (i in 0..100000000) {}
log stop()

log start()
for (i in 0..10000) {}
log stop()

testfunction()

log start()
for (i in 0..1000000000) {}
log stop()

log start()
for (i in 0..100) {}
log stop()

log start()
for (i in 0..50) {}
log stop()

log start()
for (i in 0..8) {}
log stop()

testfunction2()

println("-----------")
Logging printLog(0)
println("-----------")
Logging printLog(1)
println("-----------")
Logging printLog(2)
println("-----------")



Logging saveLog(1, "firstlog.txt")
Logging saveLog(2, "newlog.txt")
Logging saveLog(0)
