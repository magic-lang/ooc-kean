/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base

FloatVector2DCircularBuffer: class {
	_buffer: FloatVector2D[]
	_bufferPos := 0
	_length := 0
	_hasSum := false
	_sum := FloatVector2D new()
	count ::= this _length
	isFilled ::= this _length == this _buffer length
	mean ::= this sum / this count
	sum: FloatVector2D { get {
		if (!this _hasSum) {
			result := FloatVector2D new()
			for (i in 0 .. this count)
				result += this _buffer[i]
			(this _sum, this _hasSum) = (result, true)
		}
		this _sum
	}}
	variance: Float { get {
		(result, mean) := (0.0f, this mean)
		for (i in 0 .. this count)
			result += (this _buffer[i] - mean) scalarProduct(this _buffer[i] - mean)
		result / this count
	}}
	stdev ::= this variance sqrt()
	init: func (capacity: Int) {
		this _buffer = FloatVector2D[capacity] new()
	}
	free: override func {
		this _buffer free()
		super()
	}
	reset: func { (this _bufferPos, this _length, this _hasSum) = (0, 0, false) }
	add: func (vector: FloatVector2D) {
		this _buffer[this _bufferPos] = vector
		this _length = this _length maximum(this _bufferPos + 1)
		this _bufferPos = this _bufferPos < this _buffer length - 1 ? this _bufferPos + 1 : 0
		this _hasSum = false
	}
	covariance: func (other: This) -> Float {
		version(safe) {
			raise(this count != other count, "Lists must be of same size.")
			raise(this _bufferPos != other _bufferPos, "Lists must have been added the same number of elements.")
		}
		(result, thisMean, otherMean, count) := (0.0f, this mean, other mean, this count minimum(other count))
		for (i in 0 .. count)
			result += (this _buffer[i] - thisMean) scalarProduct(other _buffer[i] - otherMean)
		result / count
	}
	correlation: func (other: This) -> Float { this covariance(other) / other stdev / this stdev }
	linregSlope: func (other: This) -> Float { this covariance(other) / other variance }
}

FloatVector2DCircularBufferPair: class {
	_first: FloatVector2DCircularBuffer
	_second: FloatVector2DCircularBuffer
	first ::= this _first
	second ::= this _second
	count ::= this _first count
	isFilled ::= this _first isFilled
	covariance ::= this _first covariance(this _second)
	correlation ::= this _first correlation(this _second)
	linregSlope ::= this _first linregSlope(this _second)
	linregSlopeInv ::= this _second linregSlope(this _first)
	init: func (capacity: Int) {
		(this _first, this _second) = (FloatVector2DCircularBuffer new(capacity), FloatVector2DCircularBuffer new(capacity))
	}
	free: override func {
		(this _first, this _second) free()
		super()
	}
	reset: func { (this _first, this _second) reset() }
	add: func (vectorA, vectorB: FloatVector2D) {
		this _first add(vectorA)
		this _second add(vectorB)
	}
}
