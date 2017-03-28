/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
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
		this add("Blit blend", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<XXXXXXXX       >
				<X*    *X       >
				<X*    *X       >
				<X*   XXX       >
				<X****XXXXXXXX  >
				<XXXXXXXX   *X  >
				<     X*    *X  >
				<     X*   XXX  >
				<     X****XXX  >
				<     XXXXXXXX  >
				<               >
				<               >"
			)
			this testBlend(this sourceImage, correctImage, IntVector2D new(0, 0), IntVector2D new(5, 4), BlendMode Add, 0) // Bit exact
			this testBlend(this sourceImage, correctImage, IntVector2D new(0, 0), IntVector2D new(5, 4), BlendMode White, 16) // Approximated
			correctImage free()
		})
		this add("Blit fill", func {
			correctImage := RasterMonochrome fromAscii(
				"< *X>
				<XXXXXXXX      >
				<X*    *X      >
				<X*  XXXXXXXX  >
				<X*  X*    *X  >
				<X***X*    *X  >
				<XXXXX*   XXX  >
				<    X****XXX  >
				<    XXXXXXXX  >
				<              >
				<              >"
			)
			this testBlend(this sourceImage, correctImage, IntVector2D new(0, 0), IntVector2D new(4, 2), BlendMode Fill, 0) // Bit exact
			correctImage free()
		})
	}
	testOffset: func (source, expected: RasterMonochrome, offset: IntVector2D) {
		this testOffsetMode(source, expected, offset, BlendMode Fill, 0) // Bit exact
		this testOffsetMode(source, expected, offset, BlendMode Add, 0) // Bit exact
		this testOffsetMode(source, expected, offset, BlendMode White, 16) // Approximated
	}
	testOffsetMode: func (source, expected: RasterMonochrome, offset: IntVector2D, blendMode: BlendMode, cpuTolerance: Int) {
		resultCpu := RasterMonochrome new(expected size)
		resultCpu fill(ColorRgba black)
		resultCpu blit(this sourceImage, offset, blendMode)
		resultGpu := gpuContext createMonochrome(expected size)
		resultGpu fill(ColorRgba black)
		resultGpu blit(this sourceImage, offset, blendMode)
		resultCpuFromGpu := resultGpu toRaster()
		expect(resultCpu exactDistance(expected), is less than(cpuTolerance + 1))
		expect(resultCpuFromGpu distance(expected), is less than(0.05))
		(resultCpu, resultGpu, resultCpuFromGpu) free()
	}
	testBlend: func (source, expected: RasterMonochrome, offsetA: IntVector2D, offsetB: IntVector2D, blendModeB: BlendMode, cpuTolerance: Int) {
		resultCpu := RasterMonochrome new(expected size)
		resultCpu fill(ColorRgba black)
		resultCpu blit(this sourceImage, offsetA, BlendMode Fill)
		resultCpu blit(this sourceImage, offsetB, blendModeB)
		resultGpu := gpuContext createMonochrome(expected size)
		resultGpu fill(ColorRgba black)
		resultGpu blit(this sourceImage, offsetA, BlendMode Fill)
		resultGpu blit(this sourceImage, offsetB, blendModeB)
		resultCpuFromGpu := resultGpu toRaster()
		expect(resultCpu exactDistance(expected), is less than(cpuTolerance + 1))
		expect(resultCpuFromGpu distance(expected), is less than(0.05))
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
