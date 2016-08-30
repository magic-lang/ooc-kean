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

GpuImageReflectionTest: class extends Fixture {
	sourceImage := RasterRgba open("test/draw/gpu/input/Flower.png")
	init: func {
		super("GpuImageReflectionTest")
		this add("GPU reflection X (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/reflection_rgba_X.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba black)
			DrawState new(gpuImage) setTransformNormalized(FloatTransform3D createReflectionX()) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU reflection Y (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/reflection_rgba_Y.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba black)
			DrawState new(gpuImage) setTransformNormalized(FloatTransform3D createReflectionY()) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU reflection Z (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/reflection_rgba_Z.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba black)
			DrawState new(gpuImage) setTransformNormalized(FloatTransform3D createReflectionZ()) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU flip X (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/reflection_rgba_X.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba black)
			DrawState new(gpuImage) setFlipSourceX(true) setInputImage(this sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(correctImage, gpuImage, rasterFromGpu) free()
		})
		this add("GPU flip Y (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/reflection_rgba_Y.png")
			gpuImage := gpuContext createRgba(this sourceImage size)
			gpuImage fill(ColorRgba black)
			DrawState new(gpuImage) setFlipSourceY(true) setInputImage(this sourceImage) draw()
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
GpuImageReflectionTest new() run() . free()
gpuContext free()
