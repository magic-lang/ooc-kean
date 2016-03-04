/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit
use draw
use draw-gpu
use base
use opengl
use concurrent

GpuContextTest: class extends Fixture {
	init: func {
		super("OpenGLContext")
		this add("create context", func {
			context := OpenGLContext new()
			expect(context != null)
			context free()
		})
		this add("shared context", func {
			childThread := WorkerThread new()
			mother := OpenGLContext new()
			child: OpenGLContext
			childThread wait(|| child = OpenGLContext new(mother))
			expect(mother != null)
			expect(child != null)
			sourceImage := RasterRgba open("test/draw/gpu/input/Flower.png")
			sharedImage := mother createImage(sourceImage)
			motherRaster := sharedImage toRaster()
			expect(motherRaster distance(sourceImage), is equal to(0.0f))
			childRaster: RasterImage
			childThread wait(|| childRaster = sharedImage toRaster())
			sourceImage free()
			expect(motherRaster distance(childRaster), is equal to(0.0f))
			motherRaster free()
			childRaster free()
			childThread wait(|| child free())
			sharedImage free()
			mother free()
			childThread free()
		})
		this add("multiple contexts", func {
			thread := WorkerThread new()
			context1 := OpenGLContext new()
			context2: OpenGLContext
			thread wait(|| context2 = OpenGLContext new())
			expect(context1 != null)
			expect(context2 != null)
			context1 free()
			thread wait(|| context2 free())
			thread free()
		})
	}
}
GpuContextTest new() run() . free()
