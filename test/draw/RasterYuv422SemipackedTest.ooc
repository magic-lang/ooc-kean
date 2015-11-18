use ooc-unit
use ooc-draw
use ooc-math
import math

RasterYuv422SemipackedTest: class extends Fixture {
	_inputPath := "test/draw/input/Flower.png"
	_outputPathFirst := "test/draw/output/RasterYuv422Semipacked_test1.png"
	_outputPathSecond := "test/draw/output/RasterYuv422Semipacked_test2.png"
	init: func {
		super("RasterYuv422Semipacked")
		this add("create and copy", func {
			raster := RasterYuv422Semipacked open(this _inputPath)
			rasterCopy := raster copy()
			expect(raster width, is equal to(rasterCopy width))
			expect(raster height, is equal to(rasterCopy height))
			expect(raster stride, is equal to(rasterCopy stride))
			rasterCopy referenceCount decrease()
			raster save(this _outputPathFirst)
			raster referenceCount decrease()
			size := IntSize2D new(256, 256)
			raster = RasterYuv422Semipacked new(size)
			expect(size width, is equal to(raster width))
			expect(size height, is equal to(raster height))
			for (row in 0 .. size height)
				for (column in 0 .. size width)
					raster[column, row] = ColorBgr new(row, 0, column) toYuv()

			raster save(this _outputPathSecond)
			raster referenceCount decrease()
		})
	}
	free: override func {
		this _inputPath free()
		this _outputPathFirst free()
		this _outputPathSecond free()
		super()
	}
}

RasterYuv422SemipackedTest new() run() . free()
