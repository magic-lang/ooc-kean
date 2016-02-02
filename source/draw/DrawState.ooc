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
// DrawState new(targetImage) setMap(shader) draw()

DrawState: cover {
	target: Image = null
	inputImage: Image = null
	map: Map = null
	opacity := 1.0f
	_transformNormalized := FloatTransform3D identity
	viewport := IntBox2D new(0, 0, 0, 0)
	destination := IntBox2D new(0, 0, 0, 0) // TODO: Accept FloatBox2D
	_sourceNormalized := FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
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
	// Local region
	setViewport: func (viewport: IntBox2D) -> This {
		this viewport = viewport
		this
	}
	// Local region
	setDestination: func (destination: IntBox2D) -> This {
		this destination = destination
		this
	}
	// Local region
	setSource: func ~Int (source: IntBox2D, imageSize: IntVector2D) -> This {
		this setSource(source toFloatBox2D(), imageSize toFloatVector2D())
	}
	// Local region
	setSource: func ~Float (source: FloatBox2D, imageSize: FloatVector2D) -> This {
		this setSourceNormalized(source / imageSize)
	}
	// Normalized region
	setSourceNormalized: func (source: FloatBox2D) -> This {
		this _sourceNormalized = source
		this
	}
	// Normalized region
	getSourceNormalized: func -> FloatBox2D { this _sourceNormalized }
	// Giving a single texture as "texture0"
	setInputImage: func (inputImage: Image) -> This {
		this inputImage = inputImage
		this
	}
	// Reference transform
	setTransformReference: func ~targetSize (transform: FloatTransform3D) -> This {
		this setTransformNormalized(transform referenceToNormalized(this target size))
	}
	// Reference transform
	setTransformReference: func ~explicit (transform: FloatTransform3D, imageSize: FloatVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	// Normalized transform
	setTransformNormalized: func (transform: FloatTransform3D) -> This {
		this _transformNormalized = transform
		this
	}
	// Normalized transform
	getTransformNormalized: func -> FloatTransform3D { this _transformNormalized }
	draw: func { this target canvas draw(this) }
}
