/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use draw
use geometry

RasterYuv422SemipackedTest: class extends Fixture {
	_inputPath := "test/draw/input/Flower.png"
	init: func {
		super("RasterYuv422Semipacked")
		this add("create and copy", func {
			raster := RasterYuv422Semipacked open(this _inputPath)
			rasterCopy := raster copy()
			expect(raster width, is equal to(rasterCopy width))
			expect(raster height, is equal to(rasterCopy height))
			expect(raster stride, is equal to(rasterCopy stride))
			rasterCopy referenceCount decrease()
			outputPath := "test/draw/output/RasterYuv422Semipacked_test1.png"
			raster save(outputPath)
			outputPath free()
			raster referenceCount decrease()
			size := IntVector2D new(256, 256)
			raster = RasterYuv422Semipacked new(size)
			expect(size x, is equal to(raster width))
			expect(size y, is equal to(raster height))
			for (row in 0 .. size y)
				for (column in 0 .. size x)
					raster[column, row] = ColorBgr new(row, 0, column) toYuv()
			outputPath = "test/draw/output/RasterYuv422Semipacked_test2.png"
			raster save(outputPath)
			raster referenceCount decrease()
			outputPath free()
		})
	}
	free: override func {
		this _inputPath free()
		super()
	}
}

RasterYuv422SemipackedTest new() run() . free()
