/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

FloatRandomGenerator: abstract class {
	permanentSeed: static UInt = 0
	next: abstract func -> Float
	next: func ~withCount (count: Int) -> Float[] {
		result := Float[count] new()
		for (i in 0 .. count)
			result[i] = this next()
		result
	}
}

version (deterministic)
	FloatRandomGenerator permanentSeed = 73U

FloatUniformRandomGenerator: class extends FloatRandomGenerator {
	_state: UInt
	_min, _max, _rangeCoefficient: Float
	minimum ::= this _min
	maximum ::= this _max
	init: func (seed: UInt = Time microtime() as UInt) {
		this _state = This permanentSeed != 0 ? This permanentSeed : seed
		this setRange(0.0f, 1.0f)
	}
	init: func ~withParameters (min, max: Float, seed: UInt = Time microtime() as UInt) {
		this _state = This permanentSeed != 0 ? This permanentSeed : seed
		this setRange(min, max)
	}
	setRange: func (=_min, =_max) {
		this _rangeCoefficient = (1.0f / UInt maximumValue as Float) * (this _max - this _min)
	}
	setSeed: func (=_state)
	next: override func -> Float {
		//Based on www.irrelevantconclusion.com/2012/02/pretty-fast-random-floats-on-ps3/
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
	_secondValue: Float
	_hasSecondValue := false
	init: func {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f)
	}
	init: func ~withSeed (seed: UInt) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f, seed)
	}
	init: func ~withParameters (=_mu, =_sigma, seed: UInt = Time microtime() as UInt) {
		this _backend = FloatUniformRandomGenerator new(Float minimumValue, 1.0f, seed)
	}
	init: func ~withBackend (=_backend)
	init: func ~withBackendAndParameters (=_mu, =_sigma, =_backend)
	free: override func {
		this _backend free()
		super()
	}
	setRange: func (=_mu, =_sigma) {
		this _hasSecondValue = false
	}
	setSeed: func (state: UInt) {
		this _backend setSeed(state)
	}
	next: override func -> Float {
		result: Float
		if (this _hasSecondValue) {
			result = this _secondValue
			this _hasSecondValue = false
		} else {
			// Box-Muller transform: https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
			scale := (-2.0f * (this _backend next()) log()) sqrt()
			trigValue := (2.0f * Float pi * (this _backend next()))
			value := scale * trigValue cos()
			secondValue := scale * trigValue sin()
			result = value * this _sigma + this _mu
			this _secondValue = secondValue * this _sigma + this _mu
			this _hasSecondValue = true
		}
		result
	}
}
