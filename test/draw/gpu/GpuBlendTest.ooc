/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw-gpu
use draw
use opengl
use unit

GpuBlendTest: class extends Fixture {
	destinationImage := RasterRgba open("test/draw/gpu/input/Flower.png")
	sourceImageAlpha := RasterRgba open("test/draw/gpu/input/ElephantSealAlpha.png")
	sourceImageOpaque := RasterRgba open("test/draw/gpu/input/ElephantSeal.jpg")
	init: func {
		super("GpuBlend")
		this add("GPU blend add (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/blend_add.png")
			gpuImage := gpuContext createImage(this destinationImage)
			DrawState new(gpuImage) setBlendMode(BlendMode Add) setInputImage(this sourceImageOpaque) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(rasterFromGpu, gpuImage, correctImage) free()
		})
		this add("GPU blend white (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/blend_white.png")
			gpuImage := gpuContext createImage(this destinationImage)
			DrawState new(gpuImage) setBlendMode(BlendMode White) setInputImage(this sourceImageOpaque) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(rasterFromGpu, gpuImage, correctImage) free()
		})
		this add("GPU blend alpha (RGBA)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/blend_alpha.png")
			gpuImage := gpuContext createImage(this destinationImage)
			DrawState new(gpuImage) setBlendMode(BlendMode Alpha) setInputImage(this sourceImageAlpha) draw()
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(0.05f))
			(rasterFromGpu, gpuImage, correctImage) free()
		})
		this add("GPU blend alpha (RGBA to YUV)", func {
			correctImage := RasterRgba open("test/draw/gpu/correct/blend_alpha.png")
			gpuImageYuv := gpuContext createYuv420Semiplanar(correctImage size)
			DrawState new(gpuImageYuv y) setMap(gpuContext getRgbaToY()) setInputImage(destinationImage) draw()
			DrawState new(gpuImageYuv uv) setMap(gpuContext getRgbaToUv()) setInputImage(destinationImage) draw()
			DrawState new(gpuImageYuv y) setMap(gpuContext getRgbaToY()) setBlendMode(BlendMode Alpha) setInputImage(this sourceImageAlpha) draw()
			DrawState new(gpuImageYuv uv) setMap(gpuContext getRgbaToUv()) setBlendMode(BlendMode Alpha) setInputImage(this sourceImageAlpha) draw()
			gpuImageRgba := gpuImageYuv toRgba()
			rasterFromGpu := gpuImageRgba toRaster()
			expect(rasterFromGpu distance(correctImage), is less than(40.0f))
			(rasterFromGpu, gpuImageYuv, gpuImageRgba, correctImage) free()
		})
	}
	free: override func {
		(this destinationImage, this sourceImageAlpha, this sourceImageOpaque) free()
		super()
	}
}
gpuContext := OpenGLContext new()
GpuBlendTest new() run() . free()
gpuContext free()
