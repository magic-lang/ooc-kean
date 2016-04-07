/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
import Image
import Map
import Mesh
import DrawContext

// Example
// DrawState new(targetImage) setMap(shader) draw()

// See README.md about input arguments and coordinate systems

BlendMode: enum {
	Fill
	Add
}

DrawState: cover {
	target: Image = null
	inputImage: Image = null
	map: Map = null
	mesh: Mesh = null
	opacity := 1.0f
	blendMode := BlendMode Fill
	_transformNormalized := FloatTransform3D identity
	viewport := IntBox2D new(0, 0, 0, 0)
	_destinationNormalized := FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
	_sourceNormalized := FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
	_focalLengthNormalized := 0.0f // Relative to image width
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
	setMesh: func (mesh: Mesh) -> This {
		this mesh = mesh
		this
	}
	setOpacity: func (opacity: Float) -> This {
		this opacity = opacity
		this
	}
	setBlendMode: func (blendMode: BlendMode) -> This {
		this blendMode = blendMode
		this
	}
	setFocalLength: func ~Int (focalLength: Float, imageSize: IntVector2D) -> This {
		this setFocalLength(focalLength, imageSize toFloatVector2D())
	}
	setFocalLength: func ~Float (focalLength: Float, imageSize: FloatVector2D) -> This {
		this _focalLengthNormalized = focalLength / imageSize x
		this
	}
	setFocalLengthNormalized: func (focalLength: Float) -> This {
		this _focalLengthNormalized = focalLength
		this
	}
	getFocalLengthNormalized: func -> Float { this _focalLengthNormalized }
	// Local region
	setViewport: func (viewport: IntBox2D) -> This {
		this viewport = viewport
		this
	}
	// Local region
	setDestination: func ~TargetSize (destination: IntBox2D) -> This {
		version(safe)
			raise(this target == null, "Can't set local destination relative to a target that does not exist.")
		this setDestination(destination, this target size)
	}
	// Local region
	setDestination: func ~Int (destination: IntBox2D, imageSize: IntVector2D) -> This {
		this setDestination(destination toFloatBox2D(), imageSize toFloatVector2D())
	}
	// Local region
	setDestination: func ~Float (destination: FloatBox2D, imageSize: FloatVector2D) -> This {
		this setDestinationNormalized(destination / imageSize)
	}
	// Normalized region
	setDestinationNormalized: func (destination: FloatBox2D) -> This {
		this _destinationNormalized = destination
		this
	}
	getDestinationNormalized: func -> FloatBox2D { this _destinationNormalized }
	// The texture coordinate source region in local coordinates
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
	setInputImage: func (inputImage: Image) -> This {
		this inputImage = inputImage
		this
	}
	// Reference transform
	setTransformReference: func ~TargetSize (transform: FloatTransform3D) -> This {
		version(safe)
			raise(this target == null, "Can't set reference transform relative to a target that does not exist.")
		this setTransformNormalized(transform referenceToNormalized(this target size))
	}
	// Reference transform
	setTransformReference: func ~ExplicitIntSize (transform: FloatTransform3D, imageSize: IntVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	// Reference transform
	setTransformReference: func ~ExplicitFloatSize (transform: FloatTransform3D, imageSize: FloatVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	// Normalized transform
	setTransformNormalized: func (transform: FloatTransform3D) -> This {
		this _transformNormalized = transform
		this
	}
	// Normalized transform
	getTransformNormalized: func -> FloatTransform3D { this _transformNormalized }
	draw: func {
		version(safe)
			raise(this target == null, "Can't draw without a selected target.")
		this target canvas draw(this)
	}
	// Printing message from location as the upper left corner of the text in local coordinates.
	// Example: DrawState new(result y) drawText("Hello world!", IntPoint2D new(200, 200), this graph context getDefaultFont())
	drawText: func ~String (message: String, location: IntPoint2D, fontAtlas: Image) {
		state := this
		version(safe)
			raise(state target == null, "Can't write without a selected target.")
		state inputImage = fontAtlas
		state blendMode = BlendMode Add
		state _transformNormalized = FloatTransform3D identity
		state _destinationNormalized = FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
		skippedRows := 2 // Skip invisible commands
		visibleRows := 6 // Use 6 lines of printable characters
		columns := 16 // Use 16 characters per row
		charSize := state inputImage size / IntVector2D new(columns, visibleRows)
		destination := IntBox2D new(location, charSize)
		targetOffset := IntPoint2D new(0, 0)
		// TODO: Make a way to write multiple characters in the same draw call on the GPU.
		for (i in 0 .. message size) {
			charCode := message[i] as Int
			sourceX := charCode % columns
			sourceY := (charCode / columns) - skippedRows
			source := FloatBox2D new((sourceX as Float) / columns, (sourceY as Float) / visibleRows, 1.0f / columns, 1.0f / visibleRows)
			if (charCode > 32 && charCode < 127)
				state setViewport(destination + (targetOffset * charSize)) setSourceNormalized(source) draw()
			targetOffset x += 1
			if (charCode == '\n') {
				targetOffset x = 0 //Carriage return
				targetOffset y += 1 //Line feed
			}
		}
	}
}
