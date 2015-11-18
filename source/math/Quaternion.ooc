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
use ooc-collections
import FloatPoint3D
import FloatVectorList
import FloatTransform3D
import FloatMatrix
import math

Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D
	precision: static Float = 1.0e-6f
	// q = w + xi + yj + zk
	w ::= this real
	x ::= this imaginary x
	y ::= this imaginary y
	z ::= this imaginary z

	// NOTE: The coordinates are represented differently in C# Kean:
	// x = this w
	// y = this x
	// z = this y
	// w = this z

	inverse ::= This new(this w / (this norm * this norm), -this x / (this norm * this norm), -this y / (this norm * this norm), -this z / (this norm * this norm))
	isValid ::= (this w == this w && this x == this x && this y == this y && this z == this z)
	isIdentity ::= (this w == 1.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	isNull ::= (this w == 0.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	norm ::= (this real squared() + (this imaginary norm) squared()) sqrt()
	normalized ::= (this / this norm) as This
	logarithmImaginaryNorm ::= ((this logarithm) imaginary) norm
	rotation ::= 2.0f * this logarithmImaginaryNorm
	conjugate ::= This new(this real, -(this imaginary))
	transform ::= this toFloatTransform3D()
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f) } }
	init: func@ (=real, =imaginary)
	init: func@ ~floats (w, x, y, z: Float) { this init(w, FloatPoint3D new(x, y, z)) }
	init: func@ ~default { this init(0, 0, 0, 0) }
	init: func@ ~floatArray (source: Float[]) { this init(source[0], source[1], source[2], source[3]) }
	init: func@ ~fromeFloatTransform3D (transform: FloatTransform3D) {
		// Farrell, Jay. A. Computation of the Quaternion from a Rotation Matrix.
		// http://www.ee.ucr.edu/~farrell/AidedNavigation/D_App_Quaternions/Rot2Quat.pdf
		r, s, w, x, y, z: Float
		trace := transform a + transform f + transform k
		if (trace > 0.0f) {
			r = (1.0f + trace) sqrt()
			s = 0.5f / r
			w = 0.5f * r
			x = (transform g - transform j) * s
			y = (transform i - transform c) * s
			z = (transform b - transform e) * s
		} else if (transform a > transform f && transform a > transform k) {
			r = (1.0f + transform a - transform f - transform k) sqrt()
			s = 0.5f / r
			w = (transform g - transform j) * s
			x = 0.5f * r
			y = (transform e + transform b) * s
			z = (transform i + transform c) * s
		} else if (transform f > transform k) {
			r = (1.0f - transform a + transform f - transform k) sqrt()
			s = 0.5f / r
			w = (transform i - transform c) * s
			x = (transform e + transform b) * s
			y = 0.5f * r
			z = (transform j + transform g) * s
		} else {
			r = (1.0f - transform a - transform f + transform k) sqrt()
			s = 0.5f / r
			w = (transform b - transform e) * s
			x = (transform i + transform c) * s
			y = (transform j + transform g) * s
			z = 0.5f * r
		}
		this init(w, x, y, z)
	}
	apply: func (vector: FloatPoint3D) -> FloatPoint3D {
		vectorQuaternion := This new(0.0f, vector)
		result := hamiltonProduct(hamiltonProduct(this, vectorQuaternion), this conjugate) //FIXME Should this be conjugate or inverse?
		FloatPoint3D new(result x, result y, result z)
	}
	createRotation: static func (angle: Float, direction: FloatPoint3D) -> This {
		halfAngle := angle / 2.0f
		point3DNorm := direction norm
		if (point3DNorm != 0.0f)
			direction /= point3DNorm
		This new(0.0f, halfAngle * direction) exponential
	}
	createRotationX: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(1.0f, 0.0f, 0.0f))
	}
	createRotationY: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(0.0f, 1.0f, 0.0f))
	}
	createRotationZ: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(0.0f, 0.0f, 1.0f))
	}
	hamiltonProduct: static func (left, right: This) -> This {
		(a1, b1, c1, d1) := (left w, left x, left y, left z)
		(a2, b2, c2, d2) := (right w, right x, right y, right z)
		w := a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2
		x := a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2
		y := a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2
		z := a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2
		This new(w, x, y, z)
	}
	distance: func (other: This) -> Float {
		(this - other) norm
	}
	rotationX: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < This precision)
				result = 0.0f
			else
				result = (2.0f * (this w * this x + this y * this z)) atan2(1.0f - 2.0f * (this x squared() + this y squared()))
			result
		}
	}
	rotationY: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < This precision)
				result = Float sign(value) * (Float pi / 2.0f)
			else
				result = ((2.0f * value) clamp(-1, 1)) asin()
			result
		}
	}
	rotationZ: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < This precision)
				result = 2.0f * (this z atan2(this w))
			else
				result = (2.0f * (this w * this z + this x * this y)) atan2(1.0f - 2.0f * (this y squared() + this z squared()))
			result
		}
	}
	direction: FloatPoint3D {
		get {
			quaternionLogarithm := this logarithm
			quaternionLogarithm imaginary / quaternionLogarithm imaginary norm
		}
	}
	logarithm: This {
		get {
			result: This
			norm := this norm
			point3DNorm := this imaginary norm
			if (point3DNorm != 0)
				result = This new(norm log(), (this imaginary / point3DNorm) * ((this real / norm) acos()))
			else
				result = This new(norm, FloatPoint3D new())
			result
		}
	}
	exponential: This {
		get {
			result: This
			point3DNorm := this imaginary norm
			exponentialReal := this real exp()
			if (point3DNorm != 0)
				result = This new(exponentialReal * point3DNorm cos(), exponentialReal * (this imaginary / point3DNorm) * point3DNorm sin())
			else
				result = This new(exponentialReal, FloatPoint3D new())
			result
		}
	}
	operator == (other: This) -> Bool {
		this w == other w && this x == other x && this y == other y && this z == other z
	}
	operator != (other: This) -> Bool {
		!(this == other)
	}
	operator + (other: This) -> This {
		This new(this real + other real, this imaginary + other imaginary)
	}
	operator - (other: This) -> This {
		this + (-other)
	}
	operator - -> This {
		This new(-this real, -this imaginary)
	}
	operator / (value: Float) -> This {
		This new(this w / value, this x / value, this y / value, this z / value)
	}
	operator * (value: Float) -> This {
		This new(this w * value, this x * value, this y * value, this z * value)
	}
	operator * (other: This) -> This {
		realResult := this real * other real - this imaginary scalarProduct(other imaginary)
		imaginaryResult := this real * other imaginary + this imaginary * other real + this imaginary vectorProduct(other imaginary)
		This new(realResult, imaginaryResult)
	}
	operator * (value: FloatPoint3D) -> FloatPoint3D {
		(this * This new(0.0f, value) * this conjugate) imaginary //FIXME Should this be conjugate or inverse?
	}
	operator as -> String { this toString() }
	dotProduct: func (other: This) -> Float {
		this w * other w + this x * other x + this y * other y + this z * other z
	}
	sphericalLinearInterpolation: func (other: This, factor: Float) -> This {
		cosAngle := this dotProduct(other)
		longPath := cosAngle < 0.0f
		angle := acos(Float absolute(cosAngle) as Float clamp(-1.0f, 1.0f))
		result: This
		if (angle < 1.0e-8f)
			result = this * (1 - factor) + other * factor
		else {
			thisFactor := sin((1 - factor) * angle) / sin(angle)
			otherFactor := sin(factor * angle) / sin(angle)
			if (longPath)
				otherFactor = -otherFactor
			result = this * thisFactor + other * otherFactor
		}
		result
	}
	toFloatTransform3D: func -> FloatTransform3D {
		length := this w * this w + this x * this x + this y * this y + this z * this z
		factor := length == 0.0f ? 0.0f : 2.0f / length
		FloatTransform3D new(
			1.0f - factor * (this y * this y + this z * this z),
			factor * (this x * this y + this z * this w),
			factor * (this x * this z - this y * this w),
			factor * (this x * this y - this w * this z),
			1.0f - factor * (this x * this x + this z * this z),
			factor * (this y * this z + this w * this x),
			factor * (this x * this z + this w * this y),
			factor * (this y * this z - this w * this x),
			1.0f - factor * (this x * this x + this y * this y),
			0.0f,
			0.0f,
			0.0f
		)
	}
	relativeFromVelocity: static func (angularVelocity: FloatPoint3D) -> This {
		result := This identity
		angle := sqrt(angularVelocity x * angularVelocity x + angularVelocity y * angularVelocity y + angularVelocity z * angularVelocity z)
		if (angle > 1.0e-8f) {
			result = This new(
				cos(angle / 2.0f),
				angularVelocity x * sin(angle / 2.0f) / angle,
				angularVelocity y * sin(angle / 2.0f) / angle,
				angularVelocity z * sin(angle / 2.0f) / angle
				)
		}
		result
	}
	weightedMean: static func (quaternions: VectorList<This>, weights: FloatVectorList) -> This {
		// Implementation of the QUEST algorithm. Original publication:
		// M.D. Shuster and S.D. Oh, "Three-Axis Attitude Determination from Vector Observations", 1981
		// [http://www.malcolmdshuster.com/Pub_1981a_J_TRIAD-QUEST_scan.pdf]
		// Equation symbol - variable name conversions:
		// B - attitudeProfile
		// q - result
		// S - matrixQuantityS
		// V - referenceVectors
		// W - observationVectors
		// Y - gibbsVector
		// Z - vectorQuantityZ
		// TODO: Fix singularity problem when the angle is close to PI, using sequential rotations
		(referenceVectors, observationVectors) := This _createVectorMeasurementsForQuest(quaternions)
		normalizedWeights := weights / weights sum

		attitudeProfile := FloatMatrix new(3, 3) take()
		for (currentVector in 0 .. referenceVectors width)
			attitudeProfile += normalizedWeights[currentVector / 3] / 3.0f * observationVectors getColumn(currentVector) * referenceVectors getColumn(currentVector) transpose()
		matrixQuantityS := (attitudeProfile + attitudeProfile transpose()) take()

		temporaryZ := FloatPoint3D new()
		for (currentVector in 0 .. referenceVectors width) {
			currentObservationVector := FloatPoint3D new(observationVectors[currentVector, 0], observationVectors[currentVector, 1], observationVectors[currentVector, 2])
			currentReferenceVector := FloatPoint3D new(referenceVectors[currentVector, 0], referenceVectors[currentVector, 1], referenceVectors[currentVector, 2])
			temporaryZ += normalizedWeights[currentVector / 3] / 3.0f * currentObservationVector vectorProduct(currentReferenceVector)
		}
		vectorQuantityZ := FloatMatrix new(1, 3) take()
		vectorQuantityZ setVertical(0, 0, temporaryZ)

		maximumEigenvalue := This _approximateMaximumEigenvalueForQuest(matrixQuantityS, vectorQuantityZ, 1.0f, 5)
		linearCoefficients := (maximumEigenvalue + attitudeProfile trace()) * FloatMatrix identity(3) - matrixQuantityS
		gibbsVector := linearCoefficients solve(vectorQuantityZ) take()

		gibbsVectorSquaredNorm := 0.0f
		for (index in 0 .. gibbsVector height)
			gibbsVectorSquaredNorm += gibbsVector[0, index] squared()

		result := This new(1.0f, -gibbsVector[0, 0], -gibbsVector[0, 1], -gibbsVector[0, 2])
		result *= 1.0f / sqrt(1.0f + gibbsVectorSquaredNorm)

		normalizedWeights free()
		referenceVectors free()
		observationVectors free()
		attitudeProfile free()
		matrixQuantityS free()
		vectorQuantityZ free()
		gibbsVector free()
		result
	}
	_approximateMaximumEigenvalueForQuest: static func (matrixQuantityS, vectorQuantityZ: FloatMatrix, initialGuess: Float, maximumIterationCount := 20) -> Float {
		sigma := 0.5f * matrixQuantityS trace()
		constantA := sigma squared() - matrixQuantityS adjugate() trace()
		constantB := sigma squared() + (vectorQuantityZ transpose() * vectorQuantityZ)[0, 0]
		constantC := matrixQuantityS determinant() + (vectorQuantityZ transpose() * matrixQuantityS * vectorQuantityZ)[0, 0]
		constantD := (vectorQuantityZ transpose() * matrixQuantityS * matrixQuantityS * vectorQuantityZ)[0, 0]

		for (_ in 0 .. maximumIterationCount) {
			functionValue := pow(initialGuess, 4) - (constantA + constantB) * initialGuess squared() - constantC * initialGuess + (constantA * constantB + constantC * sigma - constantD)
			derivativeValue := 4 * pow(initialGuess, 3) + 2 * (constantA + constantB) * initialGuess - constantC
			fraction := functionValue / derivativeValue
			initialGuess -= fraction
			if (Float absolute(fraction) < 1.0e-6f)
				break
		}
		initialGuess
	}
	_createVectorMeasurementsForQuest: static func (quaternions: VectorList<This>) -> (FloatMatrix, FloatMatrix) {
		referenceVectors := FloatMatrix new(3 * quaternions count, 3) take()
		observationVectors := FloatMatrix new(3 * quaternions count, 3) take()
		xAxis := FloatPoint3D new(1.0f, 0.0f, 0.0f)
		yAxis := FloatPoint3D new(0.0f, 1.0f, 0.0f)
		zAxis := FloatPoint3D new(0.0f, 0.0f, 1.0f)
		for (index in 0 .. quaternions count) {
			referenceVectors setVertical(index * 3, 0, xAxis)
			referenceVectors setVertical(index * 3 + 1, 0, yAxis)
			referenceVectors setVertical(index * 3 + 2, 0, zAxis)
			observationVectors setVertical(index * 3, 0, quaternions[index] * xAxis)
			observationVectors setVertical(index * 3 + 1, 0, quaternions[index] * yAxis)
			observationVectors setVertical(index * 3 + 2, 0, quaternions[index] * zAxis)
		}
		(referenceVectors, observationVectors)
	}
	toString: func -> String {
		"Real: " << "%8f" formatFloat(this real) >>
		" Imaginary: " & "%8f" formatFloat(this imaginary x) >> " " & "%8f" formatFloat(this imaginary y) >> " " & "%8f" formatFloat(this imaginary z)
	}
	kean_math_quaternion_new: unmangled static func (w, x, y, z: Float) -> This { This new(w, x, y, z) }
}
operator * (value: Float, other: Quaternion) -> Quaternion {
	other * value
}
