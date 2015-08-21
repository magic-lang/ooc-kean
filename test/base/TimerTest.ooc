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

Debug initialize(func (message: String) { println(message) })

testfunction: func {
	t_test := Timer new()
	t_test start()
	for (i in 0 .. 10000) { }
	t_test stop()
}

y: Double
t := Timer new()

t start()
for (i in 0 .. 10) { }
t stop()

t start()
for (i in 0 .. 100000000) { }
t stop()

t start()
for (i in 0 .. 10000) { }
t stop()

testfunction()

t start()
for (i in 0 .. 1000000000) { }
t stop()

t start()
for (i in 0 .. 100) { }
t stop()

t start()
for (i in 0 .. 50) { }
t stop()

t start()
for (i in 0 .. 8) { }
t stop()
