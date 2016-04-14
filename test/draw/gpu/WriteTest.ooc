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

WriteTest: class extends Fixture {
	sourceImage := RasterMonochrome open("test/draw/gpu/input/Flower.png")
	correctImage := RasterMonochrome open("test/draw/gpu/correct/text.png")
	init: func {
		super("WriteTest")
		this add("Write text on the GPU", func {
			resultGpu := gpuContext createImage(sourceImage)
			DrawState new(resultGpu) setInputImage(gpuContext getDefaultFont()) setOrigin(FloatPoint2D new(-150.0f, -40.0f)) write(t"Hello world!\nThis is a line.\nThis is another line." give())
			resultCpu := resultGpu toRaster()
			expect(resultCpu distance(correctImage), is equal to(0.0f))
			(resultGpu, resultCpu) free()
		})
	}
	free: override func {
		(this sourceImage, this correctImage) free()
		super()
	}
}
gpuContext := OpenGLContext new()
WriteTest new() run() . free()
gpuContext free()
