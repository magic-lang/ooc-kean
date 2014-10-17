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

use ooc-collections

testDictionary := Dictionary new()
newDictionary: Dictionary
intPointer: Object
intPointer = 5&

intPointer2: Object
intPointer2 = 55&


testDictionary _insert(intPointer, 0)



newDictionary = testDictionary add(1, intPointer)

if (newDictionary _dictionaryList[1] == intPointer)
	"equal" println()


newDictionary  = testDictionary clone()

if (newDictionary _dictionaryList[1] != intPointer)
	"NOTequal" println()

newDictionary = testDictionary add(1, intPointer)
mergedDictionary: Dictionary
mergedDictionary = testDictionary merge(newDictionary)

if (mergedDictionary _dictionaryList[1] == intPointer)
	"equal again" println()

obj: Object
newDictionary = testDictionary add(3, intPointer2)



if (newDictionary _dictionaryList[3] == intPointer2)
	"equal when added 55" println()
obj = newDictionary get(3)
if (obj == intPointer2)
	"obj is equal" println()


newDictionary remove(3)
if (newDictionary _dictionaryList[3] != intPointer2 && newDictionary _dictionaryList[3] == null)
	"Removed" println()
