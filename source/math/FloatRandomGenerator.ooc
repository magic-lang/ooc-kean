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
	_state: Int
	_min := 0.0f
	_max := 1.0f
	init: func {
		this _state = Time microtime()
	}
	init: func ~withSeed (seed: Int) {
		this _state = seed
	}
	init: func ~withParameters (=_min, =_max, seed := Time microtime()) {
		this _state = seed
	}
	next: func -> Float {
		this _state = 214013 * this _state + 2531011
		value := ((((this _state >> 16) & 0x7fff) % 10000) as Float) / 10000.0f
		Float linearInterpolation(this _min, this _max, value)
	}
}

FloatGaussianRandomGenerator: class extends FloatRandomGenerator {
	_backend: FloatUniformRandomGenerator
	_mu := 0.0f
	_sigma := 1.0f
	init: func {
		this _backend = FloatUniformRandomGenerator new()
	}
	init: func ~withSeed (seed: Int) {
		this _backend = FloatUniformRandomGenerator new(seed)
	}
	init: func ~withParameters (=_mu, =_sigma, seed := Time microtime()) {
		this _backend = FloatUniformRandomGenerator new(seed)
	}
	init: func ~withBackend (=_backend)
	init: func ~withBackendAndParameters (=_mu, =_sigma, =_backend)
	free: override func {
		this _backend free()
		super()
	}
	next: func -> Float {
		first := this _backend next()
		if (first == 0.0f)
			first = Float minimumValue
		second := this _backend next()
		value := (-2.0f * first log()) sqrt() * (2.0f * Float pi * second) cos()
		value * this _sigma + this _mu
	}
}
