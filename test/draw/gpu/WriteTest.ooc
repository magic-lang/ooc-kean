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
	message := "Hello world!\nThis is a line.\nThis is another line.\n"
	init: func {
		super("WriteTest")
		this add("Calculate visible text index bounds", func {
			bounds := DrawContext getStringIndexBounds("1234\n1234567\n\n12345\n	\n \n")
			expect(bounds x, is equal to(7))
			expect(bounds y, is equal to(4))
		})
		this add("Write text on the CPU", func {
			correctImage := RasterMonochrome open("test/draw/gpu/correct/text.png")
			resultCpu := sourceImage copy()
			DrawState new(resultCpu) setInputImage(gpuContext defaultFontRaster) setOrigin(FloatPoint2D new(-150.0f, -40.0f)) write(this message)
			expect(resultCpu distance(correctImage), is less than(0.05f))
			(resultCpu, correctImage) free()
		})
		this add("Write text on the GPU", func {
			correctImage := RasterMonochrome open("test/draw/gpu/correct/text.png")
			resultGpu := gpuContext createImage(sourceImage)
			DrawState new(resultGpu) setInputImage(gpuContext getDefaultFont()) setOrigin(FloatPoint2D new(-150.0f, -40.0f)) write(this message)
			resultCpu := resultGpu toRaster()
			expect(resultCpu distance(correctImage), is less than(0.05f))
			(resultGpu, resultCpu, correctImage) free()
		})
	}
	free: override func {
		(this sourceImage, this message) free()
		super()
	}
}
gpuContext := OpenGLContext new()
WriteTest new() run() . free()
gpuContext free()
