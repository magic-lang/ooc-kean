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

GpuImageRotationTest: class extends Fixture {
	sourceImage := RasterRgba open("test/draw/gpu/input/Flower.png")
	init: func {
		super("GpuImageRotationTest")
		focalLength := 500.0f
		smallRotation := 10.0f toRadians()
		flipRotation := 180.0f toRadians()
		this add("GPU rotation flip X (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_flip_rgba_X.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setTransformReference(FloatTransform3D createRotationX(flipRotation)) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU rotation flip Y (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_flip_rgba_Y.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setTransformReference(FloatTransform3D createRotationY(flipRotation)) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU rotation flip Z (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_flip_rgba_Z.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setTransformReference(FloatTransform3D createRotationZ(flipRotation)) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU rotation small X (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_small_rgba_X.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createRotationX(smallRotation)) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU rotation small Y (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_small_rgba_Y.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createRotationY(smallRotation)) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU rotation small Z (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/rotation_small_rgba_Z.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba transparent)
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createRotationZ(smallRotation)) setInputImage(this sourceImage) draw()
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
GpuImageRotationTest new() run() . free()
gpuContext free()
