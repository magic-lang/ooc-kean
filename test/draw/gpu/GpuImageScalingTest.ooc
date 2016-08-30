/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw-gpu
use draw
use opengl
use unit

GpuImageScalingTest: class extends Fixture {
	sourceImage: RasterRgba
	init: func {
		super("GpuImageScalingTest")
		this sourceImage = RasterRgba open("test/draw/gpu/input/Flower.png")
		this add("Scaling X rotation", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/scaling_X_rotation.png")
			gpuImage := gpuContext createRgba(IntVector2D new(200, 150))
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setFocalLengthNormalized(0.1f) setTransformReference(FloatTransform3D createRotationX(5.0f toRadians())) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("Scaling Y rotation", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/scaling_Y_rotation.png")
			gpuImage := gpuContext createRgba(IntVector2D new(100, 200))
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setFocalLengthNormalized(0.1f) setTransformReference(FloatTransform3D createRotationY(5.0f toRadians())) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
	}
	free: override func {
		this sourceImage free()
		super()
	}
}
gpuContext := OpenGLContext new()
GpuImageScalingTest new() run() . free()
gpuContext free()
