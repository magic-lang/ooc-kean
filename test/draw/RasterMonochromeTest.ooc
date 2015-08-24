use ooc-base
use ooc-draw
use ooc-math
use ooc-unit
import lang/IO

RasterMonochromeTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	sourceHercules := "test/draw/input/Hercules.png"
	sourceBarn := "test/draw/input/Barn.png"
	init: func {
		super("RasterMonochrome")
		this add("equals 1", func {
			source1 := this sourceFlower
			source2 := this sourceSpace
			image1 := RasterMonochrome open(source1)
			image2 := RasterMonochrome open(source2)
			expect(image1 equals(image1))
			expect(image1 equals(image2), is false)
		})
		this add("equals 2", func {
			source := this sourceBarn
			output := "test/draw/output/RasterMonochrome"
			image1 := RasterMonochrome open(source)
			image1 save(output)
			image2 := RasterMonochrome open(output)
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		this add("distance, same image", func {
			source := this sourceSpace
			image1 := RasterMonochrome open(source)
			image2 := RasterMonochrome open(source)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 free(); image2 free()
		})
		this add("distance, convertFrom self", func {
			source := this sourceFlower
			image1 := RasterMonochrome open(this sourceHercules)
			image2 := RasterMonochrome convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 free(); image2 free()
		})
		/*this add("distance, convertFrom RasterBgr", func {
			source := this sourceHercules
			output := "test/draw/output/RasterBgrToMonochrome.png"
			image1 := RasterMonochrome open(source)
			image2 := RasterMonochrome convertFrom(RasterBgr open(source))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 free(); image2 free()
		})*/
	}
}

RasterMonochromeTest new() run()