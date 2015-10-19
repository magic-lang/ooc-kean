use ooc-base
use ooc-draw
use ooc-math
use ooc-unit
import lang/IO

RasterMonochromeTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterMonochrome")
		this add("equals 1", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 equals(image1))
			expect(image1 equals(image2), is false)
			image1 free(); image2 free()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterMonochrome_test.png"
			image1 := RasterMonochrome open(this sourceFlower)
			image1 save(output)
			image2 := RasterMonochrome open(output)
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		this add("distance, same image", func {
			image1 := RasterMonochrome open(this sourceSpace)
			image2 := RasterMonochrome open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 free(); image2 free()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterMonochrome open(this sourceFlower)
			image2 := RasterMonochrome convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		this add("getRow and getColumn", func {
			size := IntSize2D new(500, 256)
			image := RasterMonochrome new(size)
			for (row in 0 .. size height)
				for (column in 0 .. size width)
					image[column, row] = ColorMonochrome new(row)
			for (column in 0 .. size width) {
				columnData := image getColumn(column)
				expect(columnData count == size height)
				for (i in 0 .. columnData count)
					expect(columnData[i] as UInt8 == i)
			}
			for (row in 0 .. size height) {
				rowData := image getRow(row)
				expect(rowData count == size width)
				for (i in 0 .. rowData count)
					expect(rowData[i] as UInt8 == row)
			}
		})
		this add("resize", func {
			size := IntSize2D new(13, 5)
			image := RasterMonochrome open(this sourceFlower)
			image2 := image resizeTo(image size / 2)
			expect(image2 size == image size / 2)
			image2 = image2 resizeTo(image size)
			expect(image2 size == image size)
			expect(image distance(image2) < image size width / 10)
			image2 = image2 resizeTo(size)
			expect(image2 size == size)
		})
		this add("copy", func {
			image := RasterMonochrome open(this sourceFlower)
			image2 := image copy()
			expect(image size == image2 size)
			expect(image stride, is equal to(image2 stride))
			expect(image transform == image2 transform)
			expect(image coordinateSystem == image2 coordinateSystem)
			expect(image crop == image2 crop)
			expect(image wrap, is equal to(image2 wrap))
			expect(image referenceCount != image2 referenceCount)
		})
		/*this add("distance, convertFrom RasterBgra", func {
			source := this sourceFlower
			output := "test/draw/output/RasterBgrToMonochrome.png"
			image1 := RasterMonochrome open(source)
			image2 := RasterMonochrome convertFrom(RasterBgra open(source))
			expect(image1 distance(image2), is equal to(0.0f))
		})*/
	}
}

RasterMonochromeTest new() run()
