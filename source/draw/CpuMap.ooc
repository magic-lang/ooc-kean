/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
use collections

CpuMap: class extends Map {
	init: func
	// Pre-conditions: target and inputImage in drawState inherits RasterPacked
	// Side-effects: Renders a quad to drawState target using the settings in drawState
	// Bottlenecks: All texture access will be faster for known texture types
	render: virtual static func (drawState: DrawState) {
		if (drawState inputImage == null)
			raise("Needs input image!")
		else if (!drawState inputImage inheritsFrom(RasterPacked))
			raise("Needs packed CPU image!")
		else {
			finalViewport := drawState viewport intersection(IntBox2D new(drawState target size))
			dx := 1.0f / (finalViewport width as Float)
			dy := 1.0f / (finalViewport height as Float)
			readY := 0.0f
			for (writeY in finalViewport top .. finalViewport bottom) {
				readY += dy
				readX := 0.0f
				for (writeX in finalViewport left .. finalViewport right) {
					readX += dx
					// Pixel shader
					outputColor := (drawState inputImage as RasterPacked) samplePixelGpuClamped(readX, readY)
					// Blend stage (skip to clip pixels)
					(drawState target as RasterPacked) writePixelGpu(writeX, writeY, outputColor)
				}
			}
		}
	}
}
