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

RasterYuv420SemiplanarTest: class extends Fixture {
	_inputPath := "test/draw/input/Flower.png"
	_inputOddWidth := "test/draw/input/Hercules.png"
	_inputOddHeight := "test/draw/input/Barn.png"
	init: func {
		super("RasterYuv420Semiplanar")
		this add("resize", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			sourceSize := source size
			targetSize := sourceSize / 2
			target := source resizeTo(targetSize)
			expect(targetSize == target size)
			target referenceCount decrease()
			target = RasterYuv420Semiplanar new(sourceSize)
			source resizeInto(target)
			expect(target distance(source), is equal to(0.0f) within(0.001f))
			source referenceCount decrease()
			target referenceCount decrease()
		})
		this add("resize (odd height)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x, source size y - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddHeight.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
		this add("resize (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x - 1, source size y))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddWidth.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
		this add("resize (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x - 1, source size y - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddSize.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
		this add("crop", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			targetSize := source size / 2
			cropArea := FloatBox2D new(FloatPoint2D new(10, 10), targetSize toFloatVector2D())
			target := source crop(cropArea)
			expect(target size == cropArea size toIntVector2D())
			target free()
			cropArea = FloatBox2D new(FloatPoint2D new(), source size toFloatVector2D())
			target = RasterYuv420Semiplanar new(cropArea size toIntVector2D())
			source cropInto(cropArea, target)
			expect(target distance(source), is equal to(0.0f) within(0.001f))
			source referenceCount decrease()
			target referenceCount decrease()
		})
		this add("crop (odd height)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatVector2D new(source size x, source size y - 1)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddHeight.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
		this add("crop (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatVector2D new(source size x - 1, source size y)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddWidth.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
		this add("crop (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatVector2D new(source size x - 1, source size y - 1)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddSize.png"
			resized save(output)
			resized referenceCount decrease()
			source referenceCount decrease()
			output free()
		})
	}
	free: override func {
		(this _inputPath, this _inputOddWidth, this _inputOddHeight) free()
		super()
	}
}

RasterYuv420SemiplanarTest new() run() . free()
