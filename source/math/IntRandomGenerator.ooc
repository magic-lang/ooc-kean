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
import os/Time

IntRandomGenerator: class {
	_backend: FloatRandomGenerator
	init: func ~withBackend (=_backend)
	free: override func {
		this _backend free()
		super()
	}
	next: func -> Int {
		this _backend next() as Int
	}
	next: func ~withCount (count: Int) -> Int[] {
		result := Int[count] new()
		for (i in 0 .. count)
			result[i] = this next()
		result
	}
}

IntUniformRandomGenerator: class extends IntRandomGenerator {
	init: func {
		super(FloatUniformRandomGenerator new(0, 100))
	}
	init: func ~withSeed (seed: Int) {
		super(FloatUniformRandomGenerator new(0, 100, seed))
	}
	init: func ~withParameters (min, max: Int, seed := Time microtime()) {
		super(FloatUniformRandomGenerator new(min, max, seed))
	}
}

IntGaussianRandomGenerator: class extends IntRandomGenerator {
	init: func {
		super(FloatGaussianRandomGenerator new(0.0f, 10.0f))
	}
	init: func ~withSeed (seed: Int) {
		super(FloatGaussianRandomGenerator new(0.0f, 10.0f, seed))
	}
	init: func ~withParameters (mu, sigma: Float, seed := Time microtime()) {
		super(FloatGaussianRandomGenerator new(mu, sigma, seed))
	}
	init: func ~withBackend (backend: FloatGaussianRandomGenerator) {
		super(backend)
	}
	init: func ~withUniformBackend (backend: FloatUniformRandomGenerator) {
		super(FloatGaussianRandomGenerator new~withBackendAndParameters(0.0f, 10.0f, backend))
	}
	init: func ~withUniformBackendAndParameters (mu, sigma: Float, backend: FloatUniformRandomGenerator) {
		super(FloatGaussianRandomGenerator new~withBackendAndParameters(mu, sigma, backend))
	}
}
