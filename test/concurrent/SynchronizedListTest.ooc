/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent
use unit

applyIndex: static Int = 0
applyTestFunc := func (value: Int*) {
	expect(value@, is equal to(applyIndex + 1))
	applyIndex = applyIndex + 1
}

SynchronizedListTest: class extends Fixture {
	init: func {
		super("SynchronizedList")
		this add("single thread - add/remove", func {
			list := SynchronizedList<Int> new()
			for (value in 0 .. 1000) {
				list add(value)
				expect(list[list count - 1], is equal to(list count - 1))
			}
			expect(list count, is equal to(1000))
			for (value in 0 .. 100) {
				lastValue := list[list count - 1]
				removedValue := list remove()
				expect(lastValue, is equal to(removedValue))
			}
			expect(list count, is equal to(900))
			for (value in 0 .. 100) {
				lastValue := list[list count - 1]
				removedValue := list remove(list count - 1)
				expect(lastValue, is equal to(removedValue))
			}
			expect(list count, is equal to(800))
			for (value in 1 .. 800)
				list removeAt(list count - 1)
			expect(list count, is equal to(1))
			list free()
		})
		this add("single thread - append", func {
			list := SynchronizedList<Int> new()
			appendList := SynchronizedList<Int> new()
			list add(Int minimumValue) . add(0) . add(Int maximumValue)
			appendList add(Int minimumValue) . add(0) . add(Int maximumValue)
			list append(appendList)
			expect(list count, is equal to(6))
			expect(appendList count, is equal to(3))
			list free()
			appendList free()
		})
		this add("single thread - insert", func {
			list := SynchronizedList<Int> new()
			list add(0) . add(2) . add(4) . add(6) . add(8)
			list insert(1, 1) . insert(3, 3) . insert(5, 5) . insert(7, 7) . insert(9, 9)
			for (value in 0 .. 10)
				expect(list[value], is equal to(value))
			expect(list count, is equal to(10))
			list free()
		})
		this add("single thread - removeAt", func {
			list := SynchronizedList<Int> new()
			list add(0) . add(1) . add(2) . add(3) . add(4)
			for (value in 0 .. 5)
				expect(list[value], is equal to(value))
			expect(list count, is equal to(5))
			list free()
		})
		this add("Multi thread - clear", func {
			list := SynchronizedList<Int> new()
			expect(list count, is equal to(0))
			for (value in 0 .. 1000)
				list add(value)
			list clear()
			expect(list count, is equal to(0))
			list free()
		})
		this add("single thread - reverse", func {
			list := SynchronizedList<Int> new()
			for (value in 0 .. 1000)
				list add(value)
			reversedList := list reverse()
			for (value in 0 .. 1000) {
				expect(list[value], is equal to(value))
				expect(reversedList[999-value], is equal to(value))
			}
			expect(reversedList count, is equal to(1000))
			(list, reversedList) free()
		})
		this add("single thread - sort", func {
			list := SynchronizedList<Int> new()
			list add(Int minimumValue) . add(Int maximumValue) . add(0) . add(-10) . add(10)
			list sort(|first, second| first < second)
			for (value in 0 .. list count - 1)
				expect(list[value], is less than(list[value + 1]))
			list free()
		})
		this add("single thread - copy", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			copiedList := list copy()
			for (value in 0 .. list count) {
				expect(list[value], is equal to (copiedList[value]))
				incrementValue := copiedList[value]
				incrementValue += 1
				copiedList[value] = incrementValue
				expect(list[value], is equal to(copiedList[value] - 1))
			}
			(list, copiedList) free()
		})
		this add("single thread - modify", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			list modify(|value| value += 5)
			for (value in 0 .. list count)
				expect(list[value], is equal to(value))
			list free()
		})
		this add("single thread - apply", func {
			list := SynchronizedList<Int> new()
			list add(1) . add(2) . add(3)
			list apply(applyTestFunc)
			list free()
		})
		this add("single thread - map", func {
			list := SynchronizedList<Int> new()
			list add(0)
			list add(1)
			list add(2)
			newList := list map(|value| (value + 1) toString())
			expect(list count, is equal to(newList count))
			expect(newList[0], is equal to("1"))
			expect(newList[1], is equal to("2"))
			expect(newList[2], is equal to("3"))
			(list, newList) free()
		})
		this add("single thread - fold", func {
			list := SynchronizedList<Int> new()
			list add(1) . add(2) . add(3)
			sum := list fold(Int, |v1, v2| v1 + v2, 0)
			expect(sum, is equal to(6))
			list free()
		})
		this add("single thread - getFirstElement", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			result := list getFirstElements(2)
			expect(result count, is equal to(2))
			expect(result[0], is equal to(list[0]))
			expect(result[1], is equal to(list[1]))
			(result, list) free()
		})
		this add("single thread - getElements", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			indicesList := SynchronizedList<Int> new() . add(2) . add(4)
			result := list getElements(indicesList)
			expect(result count, is equal to(2))
			expect(result[0], is equal to(list[2]))
			expect(result[1], is equal to(list[4]))
			(indicesList, result, list) free()
		})
		this add("single thread - getSlice", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			range := list getSlice(1 .. 3)
			expect(range count, is equal to(3))
			expect(range[0], is equal to(list[1]))
			expect(range[1], is equal to(list[2]))
			expect(range[2], is equal to(list[3]))
			range free()
			interval := list getSlice(1, 3)
			expect(interval count, is equal to(3))
			expect(interval[0], is equal to(list[1]))
			expect(interval[1], is equal to(list[2]))
			expect(interval[2], is equal to(list[3]))
			(interval, list) free()
		})
		this add("single thread - getSliceInto", func {
			list := SynchronizedList<Float> new()
			list add(1.0f) . add(2.0f) . add(3.0f) . add(4.0f)
			sliceInto := VectorList<Float> new()
			list getSliceInto(Range new(1, 2), sliceInto)
			expect(sliceInto[0], is equal to(2.0f) within(0.00001f))
			expect(sliceInto[1], is equal to(3.0f) within(0.00001f))
			(list, sliceInto) free()
		})
		this add("single thread - operators", func {
			list := SynchronizedList<Int> new()
			list add(-5) . add(-4) . add(-3) . add(-2) . add(-1)
			oldValue := list[0]
			list[0] = -6
			expect(oldValue, is equal to(-5))
			expect(list[0], is equal to(-6))
			list free()
		})
		this add("single thread (class)", func {
			count := 10_000
			list := SynchronizedList<Cell<ULong>> new()
			for (value in 0 .. count) {
				list add(Cell<ULong> new(value))
				expect(list count, is equal to(value + 1))
				expect(list[value] get(), is equal to(value))
			}
			for (value in 0 .. count) {
				resultValue := list remove()
				expect(resultValue get(), is equal to (count - value - 1))
				resultValue free()
			}
			list free()
		})
		this add("single thread - iterator", func {
			list := SynchronizedList<Int> new()
			list add(8) . add(16) . add(32)
			iterator := list iterator()
			expect(iterator hasNext(), is true)
			for ((index, item) in iterator)
				expect(item, is equal to(list[index]))
			expect(iterator hasNext(), is false)
			secondIterator := list iterator()
			expect(secondIterator next(), is equal to(8))
			(secondIterator, iterator, list) free()
		})
		this add("removeAt~range", func {
			list := SynchronizedList<Int> new()
			list add(8) . add(16) . add(32) . add(64)
			list removeAt(0, 0)
			expect(list count, is equal to(4))
			expect(list empty, is false)
			list removeAt(1 .. 3)
			expect(list empty, is false)
			expect(list count, is equal to(2))
			expect(list[0], is equal to(8))
			expect(list[1], is equal to(64))
			list removeAt(0 .. 2)
			expect(list empty, is true)
			list free()
		})
		this add("single thread - search", This _testVectorListSearch)
		this add("multiple threads", This _testMultipleThreads)
		this add("multiple threads (class)", This _testMultipleThreadsWithClass)
	}
	_testVectorListSearch: static func {
		list := SynchronizedList<Int> new()
		matches := func (instance: Int*) -> Bool { 1 == instance@ }
		expect(list search(matches), is equal to(-1))
		for (i in 0 .. 10)
			list add(i)
		expect(list search(matches), is equal to(1))
		(matches as Closure) free()
		matches = func (instance: Int*) -> Bool { 9 == instance@ }
		expect(list search(matches), is equal to(9))
		(matches as Closure) free()
		matches = func (instance: Int*) -> Bool { 10 == instance@ }
		expect(list search(matches), is equal to(-1))
		(matches as Closure) free()
		list free()
	}
	_testMultipleThreads: static func {
		numberOfThreads := 8
		countPerThread := 3_000
		list := SynchronizedList<Int> new()
		threads := Thread[numberOfThreads] new()
		job := func {
			for (i in 0 .. countPerThread)
				list add(i)
		}
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job) . start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(list count, is equal to(numberOfThreads * countPerThread))
		(job as Closure) free()

		validResult := true
		globalMutex := Mutex new(MutexType Global)
		job = func {
			for (i in 0 .. countPerThread) {
				value := list remove(0)
				if (value < 0 || value >= countPerThread)
					globalMutex with(|| validResult = false)
			}
		}
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job) . start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(validResult, is true)
		expect(list count, is equal to(0))
		(job as Closure) free()
		globalMutex free()

		job = func {
			for (i in 0 .. countPerThread)
				list add(i) . remove(0)
		}
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job) . start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(list count, is equal to(0))
		(job as Closure) free()
		threads free()
		list free()
	}
	_testMultipleThreadsWithClass: static func {
		numberOfThreads := 8
		countPerThread := 3_000
		list := SynchronizedList<Cell<Int>> new()
		threads := Thread[numberOfThreads] new()
		job := func {
			for (i in 0 .. countPerThread)
				list add(Cell<Int> new(i))
		}
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job) . start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(list count, is equal to(numberOfThreads * countPerThread))
		(job as Closure) free()

		validResult := true
		globalMutex := Mutex new(MutexType Global)
		job = func {
			for (i in 0 .. countPerThread) {
				value := list remove(0)
				if (value get() < 0 || value get() >= countPerThread)
					globalMutex with(|| validResult = false)
				value free()
			}
		}
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job) . start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(validResult, is true)
		expect(list count, is equal to(0))
		(job as Closure) free()
		(threads, list, globalMutex) free()
	}
}

SynchronizedListTest new() run() . free()
