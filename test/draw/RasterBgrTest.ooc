use ooc-base
use ooc-draw
use ooc-math
use ooc-unit
import lang/IO

RasterBgrTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterBgrTest")
		this add("equals 1", func {
			image1 := RasterBgr open(this sourceFlower)
			image2 := RasterBgr open(this sourceSpace)
			expect(image1 equals(image1))
			expect(image1 equals(image2), is false)
			image1 free(); image2 free()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterBgr_test.png"
			image1 := RasterBgr open(this sourceSpace)
			image1 save(output)
			image2 := RasterBgr open(output)
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		this add("distance, same image", func {
			image1 := RasterBgr open(this sourceSpace)
			image2 := RasterBgr open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 free(); image2 free()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterBgr open(this sourceFlower)
			image2 := RasterBgr convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		this add("BGR to Monochrome", func {
			image1 := RasterBgr open(this sourceSpace)
			image2 := RasterMonochrome convertFrom(image1)
			image3 := RasterMonochrome open("test/draw/input/correct/Bgr-Monochrome-Space.png")
			expect(image2 distance(image3), is equal to(0.0f))
			image1 free(); image2 free(); image3 free()
		})
		this add("swapped RB", func {
			output := "test/draw/output/rbswapped.png"
			image := RasterBgr open(this sourceFlower)
			image2 := RasterBgr open(this sourceFlower)
			image swapRedBlue()
			image save(output)
			for (row in 0 .. image height)
				for (column in 0 .. image width) {
					pixel1 := image[column, row]
					pixel2 := image2[column, row]
					expect(pixel1 red == pixel2 blue)
					expect(pixel1 green == pixel2 green)
					expect(pixel1 blue == pixel2 red)
				}
			image free()
			image2 free()
			output free()
		})
	}
}

RasterBgrTest new() run() . free()
