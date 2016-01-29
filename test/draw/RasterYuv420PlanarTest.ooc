/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use draw

RasterYuv420PlanarTest: class extends Fixture {
	inputPath := "test/draw/input/Flower.png"
	init: func {
		super("RasterYuv420Planar")
		this add("convert", func {
			imageYuvPlanar := RasterYuv420Planar open(this inputPath)
			imageYuvSemiplanar := RasterYuv420Semiplanar convertFrom(imageYuvPlanar)
			expect(imageYuvPlanar distance(imageYuvSemiplanar) < imageYuvPlanar width)
			imageYuvPlanarConverted := RasterYuv420Planar convertFrom(imageYuvSemiplanar)
			expect(imageYuvPlanar distance(imageYuvPlanarConverted) < imageYuvPlanar width)
			imageYuvPlanar referenceCount decrease()
			imageYuvSemiplanar referenceCount decrease()
			imageYuvPlanarConverted referenceCount decrease()
		})
		this add("save", func {
			outputPath := "test/draw/output/RasterYuv420Planar.png"
			image := RasterYuv420Planar open(this inputPath)
			image save(outputPath)
			image referenceCount decrease()
			outputPath free()
		})
	}
	free: override func {
		this inputPath free()
		super()
	}
}

RasterYuv420PlanarTest new() run() . free()
