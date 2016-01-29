/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
