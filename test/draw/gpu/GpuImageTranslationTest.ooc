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

GpuImageTranslationTest: class extends Fixture {
	init: func {
		super("GpuImageTranslationTest")
		sourceImage := RasterRgba open("test/draw/gpu/input/Flower.png")
		xTranslation := sourceImage size x / 2.0f
		yTranslation := sourceImage size y / 2.0f
		zTranslation := 1500.0f
		focalLength := zTranslation
		this add("GPU translate X (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/translation_rgba_X.png")
			expect(sourceImage size x, is equal to(636))
			expect(sourceImage size y, is equal to(424))
			gpuImage := gpuContext createRgba(sourceImage size)
			expect(gpuImage size x, is equal to(636))
			expect(gpuImage size y, is equal to(424))
			gpuImage canvas pen = Pen new(ColorRgba new())
			gpuImage canvas clear()
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createTranslation(xTranslation, 0.0f, 0.0f)) setInputImage(sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU translate Y (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/translation_rgba_Y.png")
			gpuImage := gpuContext createRgba(sourceImage size)
			gpuImage canvas pen = Pen new(ColorRgba new())
			gpuImage canvas clear()
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createTranslation(0.0f, yTranslation, 0.0f)) setInputImage(sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU translate Z (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/translation_rgba_Z.png")
			gpuImage := gpuContext createRgba(sourceImage size)
			gpuImage canvas pen = Pen new(ColorRgba new())
			gpuImage canvas clear()
			DrawState new(gpuImage) setFocalLength(focalLength, gpuImage size) setTransformReference(FloatTransform3D createTranslation(0.0f, 0.0f, zTranslation)) setInputImage(sourceImage) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(3.0f))
		})
	}
}
gpuContext := OpenGLContext new()
GpuImageTranslationTest new() run() . free()
gpuContext free()
