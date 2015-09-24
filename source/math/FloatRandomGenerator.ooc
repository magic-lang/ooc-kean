//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
import math
import os/Time

FloatRandomGenerator: abstract class {
	next: abstract func -> Float
	next: func ~withCount (count: Int) -> Float[] {
		result := Float[count] new()
		for (i in 0 .. count)
			result[i] = this next()
		result
	}
}

FloatUniformRandomGenerator: class extends FloatRandomGenerator {
	_state: UInt
	_min, _max, _rangeCoefficient: Float
	minimum ::= this _min
	maximum ::= this _max
	init: func {
		this _state = Time microtime()
		this updateRange(0.0f, 1.0f)
	}
	init: func ~withSeed (seed: Int) {
		this _state = seed
		this updateRange(0.0f, 1.0f)
	}
	init: func ~withParameters (min, max: Float, seed := Time microtime()) {
		this _state = seed
		this updateRange(min, max)
	}
	updateRange: func (=_min, =_max) {
		this _rangeCoefficient = (1.0f / 4294967295.0f) * (this _max - this _min)
	}
	next: func -> Float {
		this _state ^= (this _state << 5)
		this _state ^= (this _state >> 13)
		this _state ^= (this _state << 6)
		this _min + (this _state as Float) * (this _rangeCoefficient)
	}
}

FloatGaussianRandomGenerator: class extends FloatRandomGenerator {
	_backend: FloatUniformRandomGenerator
	_mu := 0.0f
	_sigma := 1.0f
	_secondValue : Float
	_hasSecond := false
	init: func {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f)
	}
	init: func ~withSeed (seed: Int) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f, seed)
	}
	init: func ~withParameters (=_mu, =_sigma, seed := Time microtime()) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f, seed)
	}
	init: func ~withBackend (=_backend)
	init: func ~withBackendAndParameters (=_mu, =_sigma, =_backend)
	free: override func {
		this _backend free()
		super()
	}
	setRange: func (=_mu, =_sigma) {
		_hasSecond = false
	}
	next: func -> Float {
		result : Float
		if (this _hasSecond) {
			result = this _secondValue
			this _hasSecond = false
		}
		else {
			scale := (-2.0f * (this _backend next()) log()) sqrt()
			trigValue := (2.0f * Float pi * (this _backend next()))
			value := scale * trigValue cos()
			secondValue := scale * trigValue sin()
			result = value * this _sigma + this _mu
			this _secondValue = secondValue * this _sigma + this _mu
			this _hasSecond = true
		}
		result
	}
}
