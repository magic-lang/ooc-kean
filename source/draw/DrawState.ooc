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

use geometry
import Pen
import Image
import Map

// Example
// DrawState new(myImage) setMap(myShader) draw()

DrawState: cover {
	target: Image = null
	inputImage: Image = null
	map: Map = null
	opacity := 1.0f
	_transformNormalized := FloatTransform3D identity
	viewport := IntBox2D new(0, 0, 0, 0)
	init: func@ ~default
	init: func@ ~target (=target)
	setTarget: func (target: Image) -> This {
		this target = target
		this
	}
	setMap: func (map: Map) -> This {
		this map = map
		this
	}
	setOpacity: func (opacity: Float) -> This {
		this opacity = opacity
		this
	}
	setViewport: func (viewport: IntBox2D) -> This {
		this viewport = viewport
		this
	}
	setInputImage: func (inputImage: Image) -> This {
		this inputImage = inputImage
		this
	}
	setTransformReference: func ~targetSize (transform: FloatTransform3D) -> This {
		this setTransformNormalized(transform referenceToNormalized(this target size))
	}
	setTransformReference: func ~explicit (transform: FloatTransform3D, imageSize: FloatVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	setTransformNormalized: func (transform: FloatTransform3D) -> This {
		this _transformNormalized = transform
		this
	}
	getTransformNormalized: func -> FloatTransform3D { this _transformNormalized }
	draw: func { this target canvas draw(this) }
}
