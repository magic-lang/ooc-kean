/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import Image
import Map
import Mesh

// See README.md about input arguments and coordinate systems

BlendMode: enum {
	Fill // RGBA = srcRGBA
	Add // RGBA = srcRGBA + dstRGBA
	White // RGBA = srcRGBA + dstRGBA * (1 - srcRGBA)
	Alpha // RGB = srcRGB * srcAlpha + dstRGB * (1 - srcAlpha), A = dstAlpha
}

DrawState: cover {
	// See README.MD for availability of settings for each method
	target: Image = null
	inputImage: Image = null
	_originReference := FloatPoint2D new(0.0f, 0.0f) // Start of text
	map: Map = null
	mesh: Mesh = null
	blendMode := BlendMode Fill
	interpolate := true
	flipSourceX := false
	flipSourceY := false
	_transformNormalized := FloatTransform3D identity
	viewport := IntBox2D new(0, 0, 0, 0)
	_destinationNormalized := FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
	_sourceNormalized := FloatBox2D new(0.0f, 0.0f, 1.0f, 1.0f)
	_focalLengthNormalized := 0.0f // Relative to image width
	targetTransform := FloatTransform2D identity // 2D scaling done after projection matrix but before w division
	nearPlane: Float = 0.01f
	farPlane: Float = 12500.0f
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
	setBlendMode: func (blendMode: BlendMode) -> This {
		this blendMode = blendMode
		this
	}
	setInterpolate: func (interpolate: Bool) -> This {
		this interpolate = interpolate
		this
	}
	setFlipSourceX: func (flipSourceX: Bool) -> This {
		this flipSourceX = flipSourceX
		this
	}
	setFlipSourceY: func (flipSourceY: Bool) -> This {
		this flipSourceY = flipSourceY
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
	setClipPlanes: func (nearPlane, farPlane: Float) -> This {
		this nearPlane = nearPlane
		this farPlane = farPlane
		this
	}
	// Local region
	setViewport: func (viewport: IntBox2D) -> This {
		this viewport = viewport
		this
	}
	getViewport: func -> IntBox2D {
		version(safe)
			Debug error(this target == null, "Can't get local viewport relative to a target that does not exist.")
		(this viewport hasZeroArea) ? IntBox2D new(this target size) : this viewport
	}
	// Local region
	setDestination: func ~TargetSize (destination: IntBox2D) -> This {
		version(safe)
			Debug error(this target == null, "Can't set local destination relative to a target that does not exist.")
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
	// Local region
	getSourceLocal: func -> FloatBox2D {
		version(safe)
			Debug error(this inputImage == null, "Can't get local source relative to an inputImage that does not exist.")
		this _sourceNormalized * (this inputImage size toFloatVector2D())
	}
	setInputImage: func (inputImage: Image) -> This {
		this inputImage = inputImage
		this
	}
	setTransformReference: func ~TargetSize (transform: FloatTransform3D) -> This {
		version(safe)
			Debug error(this target == null, "Can't set reference transform relative to a target that does not exist.")
		this setTransformNormalized(transform referenceToNormalized(this target size))
	}
	setTransformReference: func ~ExplicitIntSize (transform: FloatTransform3D, imageSize: IntVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	setTransformReference: func ~ExplicitFloatSize (transform: FloatTransform3D, imageSize: FloatVector2D) -> This {
		this setTransformNormalized(transform referenceToNormalized(imageSize))
	}
	setTransformNormalized: func (transform: FloatTransform3D) -> This {
		this _transformNormalized = transform
		this
	}
	getTransformNormalized: func -> FloatTransform3D { this _transformNormalized }
	setTargetTransformNormalized: func (targetTransform: FloatTransform2D) -> This {
		this targetTransform = targetTransform
		this
	}
	setTargetTransformReference: func ~ExplicitIntSize (targetTransform: FloatTransform2D, imageSize: IntVector2D) -> This {
		this targetTransform = targetTransform referenceToNormalized(imageSize)
		this
	}
	setTargetTransformReference: func ~ExplicitFloatSize (targetTransform: FloatTransform2D, imageSize: FloatVector2D) -> This {
		this targetTransform = targetTransform referenceToNormalized(imageSize)
		this
	}
	getTargetTransformNormalized: func -> FloatTransform2D { this targetTransform }
	setOrigin: func (origin: FloatPoint2D) -> This {
		this _originReference = origin
		this
	}
	getOriginLocal: func -> FloatPoint2D {
		version(safe)
			Debug error(this target == null, "Can't get local origin relative to a target that does not exist.")
		this _originReference + ((this target size toFloatVector2D()) / 2.0f)
	}
	// Example: DrawState new(targetImage) setMap(shader) draw()
	draw: func {
		version(safe)
			Debug error(this target == null, "Can't draw without a target.")
		this target draw(this)
	}
	// Example: DrawState new(targetImage) setOrigin(point) setInputImage(context getDefaultFont()) write(t"Hello world!")
	write: func (message: String) {
		version(safe) {
			Debug error(this target == null, "Can't write without a target.")
			Debug error(this inputImage == null, "Can't write without a font atlas.")
		}
		this target write(message, this inputImage, this getOriginLocal() toIntPoint2D())
	}
}
