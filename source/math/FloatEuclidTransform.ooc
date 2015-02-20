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
import FloatExtension
import FloatSize2D
import FloatPoint2D
import FloatTransform2D

FloatEuclidTransform: cover {
	translationX, translationY, rotationX, rotationY, rotationZ, scaling: Float
	imageWidth := 1920
	fov := 50.0f
	k ::= tan(this fov * 0.01745329252f / 2.0f) / (this imageWidth / 2)
	isProjective ::= this rotationX != 0 || this rotationY != 0
	isIdentity ::= this rotationX == 0 && this rotationY == 0 && this rotationZ == 0 && this translationX == 0 && this translationY == 0 && this scaling == 1
	init: func@ ~fromTransform2Dreduced (transform: FloatTransform2D) {
		this init(transform, this imageWidth, this fov)
	}
	init: func@ ~fromTransform2D (transform: FloatTransform2D, =imageWidth, =fov) {
		H1 := transform a
		H2 := transform b
		H3 := transform c
		H4 := transform d
		H5 := transform e
		H6 := transform f
		H7 := transform g
		H8 := transform h
		this rotationX = atan(H6 / this k)
		this rotationY = atan(H3 / this k * cos(this rotationX))
		K1 := cos(this rotationX)
		K2 := sin(this rotationX)
		K3 := cos(this rotationY)
		K4 := sin(this rotationY)
		K5 := tan(this rotationX)
		K6 := tan(this rotationY)
		this rotationZ = atan((K3 * (1.0f + K6 * K6) * (H7 * this k * K5 - H4)) / (H1 * (K1 + K5 * K2) - H4 * K5 * K6 - H7 * this k * K6))
		if (this isProjective)
			this scaling = (K2 * K3 * H1 - K4 * H4 + 0.00000000001f) / (cos(this rotationZ) * K5 * (K3 + K4 * K6) + sin(this rotationZ) * K6 + 0.00000000001f)
		else
			this scaling = ((H1 * H1 + H2 * H2) sqrt() + (H4 * H4 + H5 * H5) sqrt()) / 2.0f
		this translationX = H7 + this scaling / this k * (cos(this rotationZ) * K6 - sin(this rotationZ) * K5 / K3)
		this translationY = H8 + this scaling / this k * (sin(this rotationZ) * K6 + cos(this rotationZ) * K5 / K3)
	}
	init: func@ ~reduced (=translationX, =translationY, =rotationX, =rotationY, =rotationZ, =scaling)
	init: func@ ~full (=translationX, =translationY, =rotationX, =rotationY, =rotationZ, =scaling, =imageWidth, =fov)
	init: func@ ~default {
		this translationX = 0.0f
		this translationY = 0.0f
		this rotationX = 0.0f
		this rotationY = 0.0f
		this rotationZ = 0.0f
		this scaling = 1.0f
	}
	identity: static This { get { This new() } }
	inverse ::= This new(-this translationX, -this translationY, -this rotationX, -this rotationY, -this rotationZ, 1 / this scaling)
	operator == (other: This) -> Bool {
		this translationX == other translationX &&
		this translationY == other translationY &&
		this rotationX == other rotationX &&
		this rotationY == other rotationY &&
		this rotationZ == other rotationZ &&
		this scaling == other scaling
	}
	weight: func(other, weight: This) -> This {
		This new(
			this translationX * weight translationX + other translationX * (1 - weight translationX),
			this translationY * weight translationY + other translationY * (1 - weight translationY),
			this rotationX * weight rotationX + other rotationX * (1 - weight rotationX),
			this rotationY * weight rotationY + other rotationY * (1 - weight rotationY),
			this rotationZ * weight rotationZ + other rotationZ * (1 - weight rotationZ),
			this scaling * weight scaling + other scaling * (1 - weight scaling)
			)
	}
	operator + (other: This) -> This {
		This new(this translationX + other translationX, this translationY + other translationY, this rotationX + other rotationX, this rotationY + other rotationY, this rotationZ + other rotationZ, this scaling * other scaling)
	}
	operator - (other: This) -> This {
		This new(this translationX - other translationX, this translationY - other translationY, this rotationX - other rotationX, this rotationY - other rotationY, this rotationZ - other rotationZ, this scaling / other scaling)
	}
	operator / (value: Float) -> This {
		This new(this translationX / value, this translationY / value, this rotationX / value, this rotationY / value, this rotationZ / value, (this scaling - 1) / value + 1)
	}
	operator * (value: Float) -> This {
		This new(this translationX * value, this translationY * value, this rotationX * value, this rotationY * value, this rotationZ * value, (this scaling - 1) * value + 1)
	}
	toString: func -> String {
		" tx: " + "%8f" format(this translationX) +
		" ty: " + "%8f" format(this translationY) +
		" Scale: " + "%8f" format(this scaling) +
		" Rx: " + "%8f" format(this rotationX) +
		" Ry: " + "%8f" format(this rotationY) +
		" Rz: " + "%8f" format(this rotationZ)
	}
}
