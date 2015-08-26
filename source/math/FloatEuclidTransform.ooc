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
import FloatPoint3D
import FloatRotation3D

FloatEuclidTransform: cover {
	rotation: FloatRotation3D
	translation: FloatPoint3D
	scaling: Float

	inverse ::= This new(-this translation, -this rotation, 1.0f / this scaling)

	init: func@ ~default { this init(FloatPoint3D new(), FloatRotation3D identity, 1.0f) }
	init: func@ ~translationAndRotation (translation: FloatPoint3D, rotation: FloatRotation3D) { this init(translation, rotation, 1.0f) }
	init: func@ ~full (=translation, =rotation, =scaling)
}
