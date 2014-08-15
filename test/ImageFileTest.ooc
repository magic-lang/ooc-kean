use ooc-unit
use ooc-draw
import math
import lang/IO
import io/File

ImageFileTest: class extends Fixture {
	init: func () {
		super("ImageFile")
		this add("First", func() {
			expect(1, is equal to(1))
		})
		this add("open PNG", func() {
			source := "input/Space.png"
			destination := "output/outputPNG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			failureReason := StbImage failureReason()
			println()
			failureReason toString() println()
			x toString() println()
			y toString() println()
			n toString() println()

			StbImage writePng(destination, x, y, 4, data, x * 4)
			failureReason = StbImage failureReason()
			failureReason toString() println()
		})
		this add("open RasterBgra", func() {
			source := "input/Space.png"
			destination := "output/outputBGRA.png"
			image := RasterBgra open(source)	
			image save(destination)	
		})
		this add("open JPEG", func() {
			source := "input/Flower.jpg"
			destination := "output/outputJPEG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			failureReason := StbImage failureReason()
			println()
			failureReason toString() println()
			x toString() println()
			y toString() println()
			n toString() println()

			StbImage writePng(destination, x, y, 4, data, x * 4)
			failureReason = StbImage failureReason()
			failureReason toString() println()
		})
		this add("Last", func() {
			expect(1, is equal to(1))
		})
	}
}
ImageFileTest new() run()
