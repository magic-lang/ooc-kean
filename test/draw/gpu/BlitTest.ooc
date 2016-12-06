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

BlitTest: class extends Fixture {
	sourceImage := RasterMonochrome fromAscii(
		"< *X>
		<XXXXXXXX>
		<X*    *X>
		<X*    *X>
		<X*   XXX>
		<X****XXX>
		<XXXXXXXX>"
	)
	unalignedSourceImage := RasterMonochrome fromAscii(
		"< *X>
		<XXXXXXXX  >
		<X*    *X  >
		<X*    *X  >
		<X*   XXX  >
		<X****XXX  >
		<XXXXXXXX  >"
	)
	init: func {
		super("BlitTest")
		this add("Blit inside", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<                >
				<                >
				<   XXXXXXXX     >
				<   X*    *X     >
				<   X*    *X     >
				<   X*   XXX     >
				<   X****XXX     >
				<   XXXXXXXX     >
				<                >"
			)
			this testOffset(this sourceImage, correctImage, IntVector2D new(3, 2))
			correctImage free()
		})
		this add("Unaligned", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<               >
				<               >
				<   XXXXXXXX    >
				<   X*    *X    >
				<   X*    *X    >
				<   X*   XXX    >
				<   X****XXX    >
				<   XXXXXXXX    >
				<               >"
			)
			this testOffset(this unalignedSourceImage, correctImage, IntVector2D new(3, 2))
			correctImage free()
		})
		this add("Blit upper left", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<    *X  >
				<    *X  >
				<   XXX  >
				<***XXX  >
				<XXXXXX  >
				<        >"
			)
			this testOffset(this sourceImage, correctImage, IntVector2D new(-2, -1))
			correctImage free()
		})
		this add("Blit right bottom", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<        >
				<    XXXX>
				<    X*  >
				<    X*  >
				<    X*  >"
			)
			this testOffset(this sourceImage, correctImage, IntVector2D new(4, 1))
			correctImage free()
		})
	}
	testOffset: func (source, expected: RasterMonochrome, offset: IntVector2D) {
		resultCpu := RasterMonochrome new(expected size)
		resultCpu fill(ColorRgba black)
		resultCpu blitWhite(this sourceImage, offset)
		resultGpu := gpuContext createMonochrome(expected size)
		resultGpu fill(ColorRgba black)
		resultGpu blitWhite(this sourceImage, offset)
		resultCpuFromGpu := resultGpu toRaster()
		expect(resultCpu distance(expected), is less than(0.05f))
		expect(resultCpuFromGpu distance(expected), is less than(0.05f))
		(resultCpu, resultGpu, resultCpuFromGpu) free()
	}
	free: override func {
		(this sourceImage, this unalignedSourceImage) free()
		super()
	}
}
gpuContext := OpenGLContext new()
BlitTest new() run() . free()
gpuContext free()
