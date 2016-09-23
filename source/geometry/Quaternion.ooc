/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use math
import FloatPoint3D
import FloatVector3D
import FloatTransform3D

Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D
	// q = w + xi + yj + zk
	w ::= this real
	x ::= this imaginary x
	y ::= this imaginary y
	z ::= this imaginary z

	isValid ::= this real isNumber && this imaginary isValid
	isIdentity ::= this real equals(1.f) && this imaginary isZero
	isZero ::= this real equals(0.f) && this imaginary isZero
	norm ::= (this real squared + this imaginary norm squared) sqrt()
	normalized ::= this / this norm
	conjugate ::= This new(this real, -this imaginary)
	inverse ::= this conjugate / (this real squared + this imaginary norm squared)
	transform ::= this toFloatTransform3D()
	direction ::= (this logarithm imaginary) normalized
	// NOTE: Separation into parts assumes order of application X -> Y -> Z
	rotationX: Float { get {
		result: Float
		value := this w * this y - this z * this x
		if ((value abs() - 0.5f) abs() < This precision)
			result = 0.0f
		else
			result = (2.0f * (this w * this x + this y * this z)) atan2(1.0f - 2.0f * (this x squared + this y squared))
		result
	}}
	rotationY: Float { get {
		result: Float
		value := this w * this y - this z * this x
		if ((value abs() - 0.5f) abs() < This precision)
			result = value sign * (Float pi / 2.0f)
		else
			result = ((2.0f * value) clamp(-1, 1)) asin()
		result
	}}
	rotationZ: Float { get {
		result: Float
		value := this w * this y - this z * this x
		if ((value abs() - 0.5f) abs() < This precision)
			result = 2.0f * (this z atan2(this w))
		else
			result = (2.0f * (this w * this z + this x * this y)) atan2(1.0f - 2.0f * (this y squared + this z squared))
		result
	}}
	logarithm: This { get {
		result: This
		norm := this norm
		if (this imaginary norm != 0)
			result = This new(norm log(), this imaginary normalized * ((this real / norm) acos()))
		else
			result = This new(norm, FloatPoint3D new())
		result
	}}
	exponential: This { get {
		result: This
		imaginaryNorm := this imaginary norm
		realExponential := this real exp()
		if (imaginaryNorm != 0)
			result = This new(realExponential * imaginaryNorm cos(), realExponential * this imaginary normalized * imaginaryNorm sin())
		else
			result = This new(realExponential, FloatPoint3D new())
		result
	}}

	init: func@ (=real, =imaginary)
	init: func@ ~floats (w, x, y, z: Float) { this init(w, FloatPoint3D new(x, y, z)) }
	init: func@ ~default { this init(0, 0, 0, 0) }
	init: func@ ~floatArray (source: Float[]) { this init(source[0], source[1], source[2], source[3]) }
	init: func@ ~fromFloatTransform3D (transform: FloatTransform3D) {
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
	distance: func (other: This) -> Float { (this - other) norm }
	angle: func (other: This) -> Float {
		result := 2.0f * (this dotProduct(other) absolute) acos()
		result isNumber ? result : 0.0f
	}
	dotProduct: func (other: This) -> Float { this w * other w + this x * other x + this y * other y + this z * other z }
	power: func (scalar: Float) -> This { (scalar * this logarithm) exponential }
	sphericalLinearInterpolation: func (other: This, factor: Float) -> This {
		cosAngle := this dotProduct(other)
		longPath := cosAngle < 0.0f
		angle := acos(cosAngle absolute clamp(-1.0f, 1.0f))
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
	toAxisAngle: func -> (FloatVector3D, Float) {
		angle := 2.f * this real acos()
		factor := (1.f - this real squared) sqrt()
		axis := factor equals(0.f) ? FloatPoint3D new(1.f, 0.f, 0.f) : this imaginary / factor
		(FloatVector3D new(axis x, axis y, axis z), angle)
	}
	toEulerVector: func -> FloatVector3D {
		(axis, angle) := this toAxisAngle()
		FloatVector3D new(axis x, axis y, axis z) * angle
	}
	toString: func (decimals := 6) -> String {
		"Real: " << this real toString(decimals) >> " Imaginary: " & this imaginary x toString(decimals) >> " " & this imaginary y toString(decimals) >> " " & this imaginary z toString(decimals)
	}

	operator * (other: This) -> This {
		realResult := this real * other real - this imaginary scalarProduct(other imaginary)
		imaginaryResult := this real * other imaginary + this imaginary * other real + this imaginary vectorProduct(other imaginary)
		This new(realResult, imaginaryResult)
	}
	operator + (other: This) -> This { This new(this real + other real, this imaginary + other imaginary) }
	operator - (other: This) -> This { this + (-other) }
	operator == (other: This) -> Bool { this w == other w && this x == other x && this y == other y && this z == other z }
	operator != (other: This) -> Bool { !(this == other) }
	operator - -> This { This new(-this real, -this imaginary) }
	operator / (value: Float) -> This { This new(this w / value, this x / value, this y / value, this z / value) }
	operator * (value: Float) -> This { This new(this w * value, this x * value, this y * value, this z * value) }
	operator * (value: FloatPoint3D) -> FloatPoint3D { This hamiltonProduct(This hamiltonProduct(this, This new(0.0f, value)), this inverse) imaginary }

	precision: static Float = 1.0e-6f
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f) } }

	createFromEulerAngles: static func (rotationX, rotationY, rotationZ: Float) -> This {
		This createRotationZ(rotationZ) * This createRotationY(rotationY) * This createRotationX(rotationX)
	}
	createFromAxisAngle: static func (axis: FloatVector3D, angle: Float) -> This {
		axis = axis isZero ? axis : axis normalized
		halfAngle := angle / 2.f
		This new(halfAngle cos(), (halfAngle sin() * axis) toFloatPoint3D())
	}
	createRotationX: static func (angle: Float) -> This { This createFromAxisAngle(FloatVector3D new(1.0f, 0.0f, 0.0f), angle) }
	createRotationY: static func (angle: Float) -> This { This createFromAxisAngle(FloatVector3D new(0.0f, 1.0f, 0.0f), angle) }
	createRotationZ: static func (angle: Float) -> This { This createFromAxisAngle(FloatVector3D new(0.0f, 0.0f, 1.0f), angle) }
	createFromEulerVector: static func (vector: FloatVector3D) -> This { vector isZero ? This identity : This createFromAxisAngle(vector normalized, vector norm) }
	hamiltonProduct: static func (left, right: This) -> This {
		(a1, b1, c1, d1) := (left w, left x, left y, left z)
		(a2, b2, c2, d2) := (right w, right x, right y, right z)
		w := a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2
		x := a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2
		y := a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2
		z := a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2
		This new(w, x, y, z)
	}
	weightedMean: static func (quaternions: VectorList<This>, weights: FloatVectorList) -> This {
		// Implementation of the QUEST algorithm. Original publication:
		// M.D. Shuster and S.D. Oh, "Three-Axis Attitude Determination from Vector Observations", 1981
		// [http://www.malcolmdshuster.com/Pub_1981a_J_TRIAD-QUEST_scan.pdf]
		// Equation symbol - variable name conversions:
		// B - attitudeProfile
		// q - result
		// S - matrixQuantityS
		// W - observationVectors
		// Y - gibbsVector
		// Z - vectorQuantityZ
		// Rotate quaternions if the angle is close to pi to avoid singularity problem
		centerQuaternion := quaternions[quaternions count / 2]
		preRotate := centerQuaternion angle(This identity) equals(Float pi, 0.5f)
		if (preRotate) {
			centerQuaternionInverse := centerQuaternion inverse
			for (index in 0 .. quaternions count)
				quaternions[index] = centerQuaternionInverse * quaternions[index]
		}
		observationVectors := This _createVectorMeasurementsForQuest(quaternions)
		normalizedWeights := weights / weights sum

		attitudeProfile := FloatMatrix new(3, 3) take()
		for (index in 0 .. quaternions count)
			for (column in 0 .. 3)
				for (row in 0 .. 3)
					attitudeProfile[column, row] = attitudeProfile[column, row] + normalizedWeights[index] / 3.0f * observationVectors[index * 3 + column, row]
		matrixQuantityS := FloatMatrix new(3, 3) take()
		for (column in 0 .. 3)
			for (row in 0 .. 3)
				matrixQuantityS[column, row] = attitudeProfile[column, row] + attitudeProfile[row, column]
		vectorQuantityZ := FloatMatrix new(1, 3) take()
		for (index in 0 .. quaternions count) {
			vectorQuantityZ[0, 0] = vectorQuantityZ[0, 0] + normalizedWeights[index] / 3.0f * (-observationVectors[index * 3 + 1, 2] + observationVectors[index * 3 + 2, 1])
			vectorQuantityZ[0, 1] = vectorQuantityZ[0, 1] + normalizedWeights[index] / 3.0f * (observationVectors[index * 3, 2] - observationVectors[index * 3 + 2, 0])
			vectorQuantityZ[0, 2] = vectorQuantityZ[0, 2] + normalizedWeights[index] / 3.0f * (-observationVectors[index * 3, 1] + observationVectors[index * 3 + 1, 0])
		}
		maximumEigenvalue := This _approximateMaximumEigenvalueForQuest(matrixQuantityS, vectorQuantityZ, 1.0f, 5)
		linearCoefficients := (maximumEigenvalue + attitudeProfile trace()) * FloatMatrix identity(3) - matrixQuantityS
		gibbsVector := linearCoefficients solve(vectorQuantityZ) take()
		gibbsVectorSquaredNorm := 0.0f
		for (index in 0 .. gibbsVector height)
			gibbsVectorSquaredNorm += gibbsVector[0, index] squared

		result := This new(1.0f, -gibbsVector[0, 0], -gibbsVector[0, 1], -gibbsVector[0, 2])
		result *= 1.0f / sqrt(1.0f + gibbsVectorSquaredNorm)
		(observationVectors, normalizedWeights, attitudeProfile, matrixQuantityS, vectorQuantityZ, gibbsVector) free()
		preRotate ? centerQuaternion * result : result
	}
	_approximateMaximumEigenvalueForQuest: static func (matrixQuantityS, vectorQuantityZ: FloatMatrix, initialGuess: Float, maximumIterationCount := 20) -> Float {
		sigma := 0.5f * matrixQuantityS trace()
		constantA := sigma squared - matrixQuantityS adjugate() trace()
		constantB := sigma squared + (vectorQuantityZ transpose() * vectorQuantityZ)[0, 0]
		constantC := matrixQuantityS determinant() + (vectorQuantityZ transpose() * matrixQuantityS * vectorQuantityZ)[0, 0]
		constantD := (vectorQuantityZ transpose() * matrixQuantityS * matrixQuantityS * vectorQuantityZ)[0, 0]
		for (_ in 0 .. maximumIterationCount) {
			functionValue := initialGuess pow(4) - (constantA + constantB) * initialGuess squared - constantC * initialGuess + (constantA * constantB + constantC * sigma - constantD)
			derivativeValue := 4 * (initialGuess pow(3)) + 2 * (constantA + constantB) * initialGuess - constantC
			fraction := functionValue / derivativeValue
			initialGuess -= fraction
			if (fraction equals(0.f, 1.0e-6f))
				break
		}
		initialGuess
	}
	_createVectorMeasurementsForQuest: static func (quaternions: VectorList<This>) -> FloatMatrix {
		result := FloatMatrix new(3 * quaternions count, 3) take()
		for (index in 0 .. quaternions count) {
			xAxis := quaternions[index] * FloatPoint3D new(1.0f, 0.0f, 0.0f)
			result setVertical(index * 3, 0, xAxis x, xAxis y, xAxis z)
			yAxis := quaternions[index] * FloatPoint3D new(0.0f, 1.0f, 0.0f)
			result setVertical(index * 3 + 1, 0, yAxis x, yAxis y, yAxis z)
			zAxis := quaternions[index] * FloatPoint3D new(0.0f, 0.0f, 1.0f)
			result setVertical(index * 3 + 2, 0, zAxis x, zAxis y, zAxis z)
		}
		result
	}
}
operator * (value: Float, other: Quaternion) -> Quaternion { other * value }

extend Cell<Quaternion> {
	toString: func ~quaternion -> String { (this val as Quaternion) toString() }
}
