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
		this add("yuv fill", func {
			yuvImage := RasterYuv420Semiplanar new(IntVector2D new(2, 2))
			yuvImage fill(ColorRgba new(0, 100, 200, 255))
			yuvSample := yuvImage[0, 0]
			expect(yuvSample distance(ColorYuv new(81, 194, 69)), is less than(8.0f))
			rgbImage := RasterRgb convertFrom(yuvImage)
			rgbSample := rgbImage[0, 0]
			expect(rgbSample distance(ColorRgb new(0, 100, 200)), is less than(8.0f))
			(yuvImage, rgbImage) free()
		})
		this add("yuv point", func {
			yuvImage := RasterYuv420Semiplanar new(IntVector2D new(2, 2))
			//_drawPoint is using reference coordinates from the center
			yuvImage _drawPoint(-1, -1, Pen new(ColorRgba new(0, 100, 200, 255)))
			yuvSample := yuvImage[0, 0]
			expect(yuvSample distance(ColorYuv new(81, 194, 69)), is less than(8.0f))
			rgbImage := RasterRgb convertFrom(yuvImage)
			rgbSample := rgbImage[0, 0]
			expect(rgbSample distance(ColorRgb new(0, 100, 200)), is less than(8.0f))
			(yuvImage, rgbImage) free()
		})
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
			(source, target) referenceCount decrease()
		})
		this add("resize (odd height)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x, source size y - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddHeight.png"
			resized save(output)
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("resize (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x - 1, source size y))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddWidth.png"
			resized save(output)
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("resize (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source resizeTo(IntVector2D new(source size x - 1, source size y - 1))
			output := "test/draw/output/RasterYuv420SemiplanarTest_resizeOddSize.png"
			resized save(output)
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("crop", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			targetSize := source size / 2
			cropArea := FloatBox2D new(FloatPoint2D new(10, 10), targetSize toFloatVector2D())
			target := source crop(cropArea)
			expect(target size == cropArea size toIntVector2D())
			target free()
			cropAreaInt := IntBox2D new(IntPoint2D new(), source size)
			target = RasterYuv420Semiplanar new(cropAreaInt size)
			source resizeInto(target, cropAreaInt)
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
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("crop (odd width)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatVector2D new(source size x - 1, source size y)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddWidth.png"
			resized save(output)
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("crop (odd size)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			expect(source size x isEven, is true)
			expect(source size y isEven, is true)
			resized := source crop(FloatBox2D new(FloatPoint2D new(), FloatVector2D new(source size x - 1, source size y - 1)))
			output := "test/draw/output/RasterYuv420SemiplanarTest_cropOddSize.png"
			resized save(output)
			(resized, source) referenceCount decrease()
			output free()
		})
		this add("resize (with box)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			box := IntBox2D new(0, source height / 2, source width, source height / 2)
			target := RasterYuv420Semiplanar new(source size)
			source resizeInto(target, box)
			output := "test/draw/output/RasterYuv420SemiplanarTest_lowerHalfResized.png"
			target save(output)
			(target, source) referenceCount decrease()
			output free()
		})
		this add("rotate (Z)", func {
			source := RasterYuv420Semiplanar open(this _inputPath)
			target := RasterYuv420Semiplanar new(source size)
			translationToCenter := FloatTransform3D createTranslation(source width / 2.0f, source height / 2.0f, 0.0f)
			transform := FloatTransform3D createTranslation(10.0f, 10.0f, 0.0f) * FloatTransform3D createScaling(0.3f, 0.6f, 1.0f) * FloatTransform3D createRotationZ(3.14f / 7)
			transform = translationToCenter * transform * translationToCenter inverse
			DrawState new(target) setInputImage(source) setTransformNormalized(transform) setInterpolate(false) draw()
			output := "test/draw/output/RasterYuv420SemiplanarTest_RotatedScaledTranslated.png"
			target save(output)
			targetBilinear := RasterYuv420Semiplanar new(source size)
			DrawState new(targetBilinear) setInputImage(source) setTransformNormalized(transform) setInterpolate(true) draw()
			difference := targetBilinear distance(target)
			expect(difference, is greater than(0.0f))
			expect(difference, is less than(5.0f))
			(target, targetBilinear, source) referenceCount decrease()
			output free()
		})
	}
	free: override func {
		(this _inputPath, this _inputOddWidth, this _inputOddHeight) free()
		super()
	}
}

RasterYuv420SemiplanarTest new() run() . free()
