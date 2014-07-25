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
import ../../FloatExtension
import Size
import Point
import text/StringTokenizer
import structs/ArrayList

// The 2D transform is a 3x3 homogeneous coordinate matrix.
// The element order is:
// A D G
// B E H
// C F I

Transform : cover {
	a, b, c, d, e, f, g, h, i: Float
//	FIXME: How do I overload the [x, y] operator? Do 2D arrays even exist in ooc?
//	operator [] () -> Float { get {
//			result := match (x)	{
//				case 0 =>
//					match (y) {
//						case 0 => this.a
//						case 1 => this.b
//						case 2 => this.c
//						case => raise(IndexOutOfRangeException())
//					}
//				case 1 =>
//					match (y) {
//						case 0 => this.d
//						case 1 => this.e
//						case 2 => this.f
//						case => raise(IndexOutOfRangeException())
//					}
//				case 2 =>
//					match (y) {
//						case 0 => this.g
//						case 1 => this.h
//						case 2 => this.i
//						case => raise(IndexOutOfRangeException())
//					}
//				case => raise(IndexOutOfRangeException())
//			}
//			result
//		}
//	}
	Determinant: Float { 
		get { 
			this a * this e * this i + this d * this h * this c	+ this g * this b * this f \
			- this g * this e * this c - this d * this b * this i - this a * this h * this f 
		} 
	}
	Translation: Size { get { Size new(this g, this h) } }
	Scaling: Float { get { (this ScalingX + this ScalingY) / 2.0f } }
	ScalingX: Float { get { (this a pow(2.0) + this b pow(2.0)) sqrt() } }
	ScalingY: Float { get { (this d pow(2.0) + this e pow(2.0)) sqrt() } }
	Rotation: Float { get { this b atan2(this a) } }
//	FIXME: This doesn't compile for some reason
//	Inverse: This {	
//		get {
//			determinant := this Determinant
//			This new(
//				(this e * this i - this h * this f) / determinant,
//				(this h * this c - this b * this i) / determinant,
//				(this b * this f - this e * this c) / determinant,
//				(this g * this f - this d * this i) / determinant,
//				(this a * this i - this g * this c) / determinant,
//				(this c * this d - this a * this f) / determinant,
//				(this d * this h - this g * this e) / determinant,
//				(this g * this b - this a * this h) / determinant,
//				(this a * this e - this b * this d) / determinant
//			)
//		}
//	}
	IsProjective: Bool { get { this Determinant != 0.0f } }
	IsAffine: Bool { get { this c == 0.0f && this f == 0.0f && this i == 1.0f } }
	IsSimilarity: Bool { get { this == This create(this Translation, this Scaling, this Rotation) } }
	IsEuclidian: Bool { get { this == This create(this Translation, this Rotation) } }
	IsIdentity: Bool { get { (this a == this e == this i == 1.0f) && (this b == this c == this d == this f == this g == this h == 0.0f) } }
	init: func@ (=a, =b, =c, =d, =e, =f, =g, =h, =i) { }
	init: func@ ~reduced(a, b, d, e, g, h: Float) { this init(a, b, 0.0f, d, e, 0.0f, g, h, 1.0f) }
	init: func@ ~default() { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
//	FIXME: Unary minus
//	setTranslation: func(translation: Size) -> This { this translate(translation - this Translation) }
	setScaling: func(scaling: Float) -> This { this scale(scaling / this Scaling) }
	setXScaling: func(scaling: Float) -> This { this scale(scaling / this ScalingX, 1.0f) }
	setYScaling: func(scaling: Float) -> This { this scale(1.0f, scaling / this ScalingY) }
	setRotation: func(rotation: Float) -> This { this rotate(rotation - this Rotation) }
	translate: func(xDelta, yDelta: Float) -> This { this createTranslation(xDelta, yDelta) * this }
	translate: func ~float(delta: Float) -> This { this translate(delta, delta) }
	translate: func ~point(delta: Point) -> This { this translate(delta x, delta y) }
	translate: func ~size(delta: Size) -> This { this translate(delta width, delta height) }
	scale: func(xFactor, yFactor: Float) -> This { this createScaling(xFactor, yFactor) * this }
	scale: func ~float(factor: Float) -> This { this scale(factor, factor) }
	scale: func ~size(factor: Size) -> This { this scale(factor width, factor height) }
	rotate: func (angle: Float) -> This { this createZRotation(angle) * this }
	skewX: func (angle: Float) -> This { this createSkewingX(angle) * this }
	skewY: func (angle: Float) -> This { this createSkewingY(angle) * this }
	reflectX: func () -> This { this createReflectionX() * this }
	reflectY: func () -> This { this createReflectionY() * this }
	Identity: static This { get { This new(1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) } }
	create: static func(translation: Size, scale : Float, rotation: Float) -> This { 
		This new(rotation cos() * scale, rotation sin() * scale, -rotation sin() * scale, rotation cos() * scale, translation width, translation height) 
	}
	create: static func ~reduced(translation: Size, rotation: Float) -> This { This create(translation, 1.0f, rotation) }
	createTranslation: static func (xDelta, yDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta) }	
	createTranslation: static func ~float(delta: Float) -> This { This createTranslation(delta, delta) }
	createTranslation: static func ~size(delta: Size) -> This { This createTranslation(delta width, delta height) }
	createTranslation: static func ~point(delta: Point) -> This { This createTranslation(delta x, delta y) }
	createScaling: static func(xFactor, yFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, yFactor, 0.0f, 0.0f) }
	createScaling: static func ~float(factor: Float) -> This { This createScaling(factor, factor) }
	createScaling: static func ~size(factor: Size) -> This { This createScaling(factor width, factor height) }
	createZRotation: static func(angle: Float) -> This { This new(angle cos(), angle sin(), -angle sin(), angle cos(), 0.0f, 0.0f) }
	createZRotation: static func ~pivot(angle: Float, pivot: Point) -> This { 
		one := 1.0f
		sine := angle sin()
		cosine := angle cos()
		This new(cosine, sine, -sine, cosine, (one - cosine) * pivot x + sine * pivot y, -sine * pivot x + (one - cosine) * pivot y) 
	}
	createSkewingX: static func(angle: Float) -> This { This new(1.0f, 0.0f, angle sin(), 1.0f, 0.0f, 0.0f) }
	createSkewingY: static func(angle: Float) -> This { This new(1.0f, angle sin(), 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionX: static func() -> This { This new(-1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionY: static func() -> This { This new(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f) }
	operator * (other: This) -> This {
		This new(
			this a * other a + this d * other b + this g * other c,
			this b * other a + this e * other b + this h * other c,
			this c * other a + this f * other b + this i * other c,
			this a * other d + this d * other e + this g * other f,
			this b * other d + this e * other e + this h * other f,
			this c * other d + this f * other e + this i * other f,
			this a * other g + this d * other h + this g * other i,
			this b * other g + this e * other h + this h * other i,
			this c * other g + this f * other h + this i * other i
		)
	}
	operator * (other: Point) -> Point {
		divisor := this c * other x + this f * other y + this i
		Point new((this a * other x + this d * other y + this g) / divisor, (this b * other x + this e * other y + this h) / divisor)
	}
	operator == (other: This) -> Bool {
		this a == other a &&
		this b == other b &&
		this c == other c &&
		this d == other d &&
		this e == other e &&
		this f == other f &&
		this g == other g &&
		this h == other h &&
		this i == other i
	}
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String {
		this toString()
	}
	toString: func -> String {
		"#{this a toString()}, #{this b toString()}, #{this c toString()}, \
		#{this d toString()}, #{this e toString()}, #{this f toString()}, \
		#{this g toString()}, #{this h toString()}, #{this i toString()}"
	}
}
