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
	}
}

RasterBgrTest new() run()