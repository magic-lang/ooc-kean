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

use ooc-math
import math
import os/Time

IntUniformRandomGenerator: class {
	_state, _min, _max, _range: Int
	init: func (seed := Time microtime()) {
		this _min = 0
		this _max = 32767
		this _state = seed
		this _range = this _max - this _min + 1
	}
	init: func ~withParameters (=_min, =_max, seed := Time microtime()) {
		this _state = seed
		this _range = this _max - this _min + 1
	}
	_generate: func -> Int {
		this _state = 214013 * this _state + 2531011
		(this _state >> 16) & 0x7FFF
	}
	next: func ~fast -> Int {
		value := this _generate()
		this _min + (value % this _range)
	}
	next: func -> Int {
		valuea := this _generate()
		valueb := this _generate()
		valuec := this _generate()
		result := (valuea as Int << 16) | (valueb as Int << 1) | (valuec & 1)
		this _min + (result % this _range)
	}
	next: func ~withCount (count: Int) -> Int[] {
		result := Int[count] new()
		for (i in 0 .. count)
			result[i] = this next()
		result
	}
}

IntGaussianRandomGenerator: class {
	_mu := 0.0f
	_sigma := 1.0f
	_hasSecond := false
	_secondValue : Float
	_backend: FloatUniformRandomGenerator
	init: func {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f - Float minimumValue)
	}
	free: func {
		this _backend free()
	}
	init: func ~withSeed (seed: Int) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f - Float minimumValue, seed)
	}
	init: func ~withParameters (=_mu, =_sigma, seed := Time microtime()) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f - Float minimumValue, seed)
	}
	init: func ~withUniformBackend (=_backend)
	init: func ~withUniformBackendAndParameters (=_mu, =_sigma, =_backend)
	next: func -> Int {
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
		result as Int
	}
	next: func ~withCount (count: Int) -> Int[] {
		result := Int[count] new()
		for (i in 0 .. count)
			result[i] = this next()
		result
	}
}
