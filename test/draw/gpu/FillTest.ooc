/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use geometry
use draw-gpu
use draw
use opengl
use unit

FillTest: class extends Fixture {
	init: func {
		super("Fill")
		imageSize := IntVector2D new(16, 16)
		color := ColorRgba new(134, 176, 31, 0)
		this add("Fill RGB", func {
			cpuImage := RasterRgb new(imageSize)
			cpuImage fill(color)
			for (y in 0 .. cpuImage size y)
				for (x in 0 .. cpuImage size x)
					expect(cpuImage[x, y] == ColorRgb new(134, 176, 31))
			cpuImage free()
		})
		this add("Fill RGBA", func {
			gpuImage := gpuContext createRgba(imageSize)
			cpuImage := RasterRgba new(imageSize)
			gpuImage fill(color)
			cpuImage fill(color)
			gpuToCpuImage := gpuImage toRaster()
			expect(gpuToCpuImage distance(cpuImage), is less than(0.05f))
			expect(cpuImage[7, 7] == color)
			expect(cpuImage[0, 0] == color)
			expect(cpuImage[0, 15] == color)
			expect(cpuImage[15, 0] == color)
			expect(cpuImage[15, 15] == color)
			(gpuToCpuImage, cpuImage, gpuImage) free()
		})
		this add("Fill YUV420Semiplanar", func {
			gpuImage := gpuContext createYuv420Semiplanar(imageSize)
			cpuImage := RasterYuv420Semiplanar new(imageSize)
			gpuImage fill(color)
			cpuImage fill(color)
			gpuToCpuImage := gpuImage toRaster()
			expect(gpuToCpuImage distance(cpuImage), is less than(0.05f))
			(gpuToCpuImage, cpuImage, gpuImage) free()
		})
	}
}
gpuContext := OpenGLContext new()
FillTest new() run() . free()
gpuContext free()
