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

GpuImageCoordinateTest: class extends Fixture {
	correctImage: RasterRgba
	init: func {
		super("GpuImageCoordinate")
		this correctImage = RasterRgba open("test/draw/gpu/input/Flower.png")
		this add("Default coordinates", func { flipRightTest(RasterRgba open("test/draw/gpu/input/Flower.png")) })
		this add("Mirrored X", func { flipRightTest(RasterRgba open("test/draw/gpu/input/FlowerFlipX.png", CoordinateSystem XLeftward)) })
		this add("Mirrored Y", func { flipRightTest(RasterRgba open("test/draw/gpu/input/FlowerFlipY.png", CoordinateSystem YUpward)) })
		this add("Mirrored XY", func { flipRightTest(RasterRgba open("test/draw/gpu/input/FlowerFlipXY.png", CoordinateSystem XLeftward | CoordinateSystem YUpward)) })
	}
	flipRightTest: func (sourceImage: Image) {
		gpuImage := gpuContext createRgba(sourceImage size)
		gpuImage fill(ColorRgba transparent)
		DrawState new(gpuImage) setInputImage(sourceImage) draw()
		rasterFromGpu := gpuImage toRaster()
		expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		(sourceImage, gpuImage, rasterFromGpu) free()
	}
	free: override func {
		this correctImage free()
		super()
	}
}
gpuContext := OpenGLContext new()
GpuImageCoordinateTest new() run() . free()
gpuContext free()
