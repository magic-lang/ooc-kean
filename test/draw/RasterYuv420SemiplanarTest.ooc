use ooc-unit
use ooc-draw
use ooc-math
import math

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
			target free()
			target = RasterYuv420Semiplanar new(sourceSize)
			source resizeInto(target)
			expect(target distance(source), is equal to(0.0f) within(0.001f))
			source free()
			target free()
		})
		this add("resize (odd height)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source resizeTo(IntSize2D new(source size width, source size height - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddHeight.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
		this add("resize (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source resizeTo(IntSize2D new(source size width - 1, source size height))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddWidth.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
		this add("resize (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source resizeTo(IntSize2D new(source size width - 1, source size height - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddSize.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
		this add("crop", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			targetSize := source size / 2
			cropArea := FloatBox2D new(FloatPoint2D new(10, 10), targetSize toFloatSize2D())
			target := source crop(cropArea)
			expect(target size == cropArea size toIntSize2D())
			target free()
			cropArea = FloatBox2D new(FloatPoint2D new(), source size toFloatSize2D())
			target = RasterYuv420Semiplanar new(cropArea size toIntSize2D())
			source cropInto(cropArea, target)
			expect(target distance(source), is equal to(0.0f) within(0.001f))
			source free()
			target free()
		})
		this add("crop (odd height)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatSize2D new(source size width, source size height - 1)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddHeight.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
		this add("crop (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatSize2D new(source size width - 1, source size height)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddWidth.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
		this add("crop (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(Int even(source size width))
			expect(Int even(source size height))
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatSize2D new(source size width - 1, source size height - 1)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddSize.png"
			resized save(output)
			resized free()
			source free()
			output free()
		})
	}
	free: override func {
		this _inputPath free()
		this _inputOddWidth free()
		this _inputOddHeight free()
		super()
	}
}

test := RasterYuv420SemiplanarTest new()
test run()
test free()
