use ooc-unit
use ooc-draw
import math
import lang/IO

ImageFileTest: class extends Fixture {
	init: func () {
		super("ImageFile")
		this add("First", func() {
			expect(1, is equal to(1))
		})
		this add("open PNG", func() {
			source : const CString = "image.png"
//			destination : const CString = "output.png"
			image := RasterBgra open(source)
//			if (image pointer == null)
//				"Failed to open image." println()
//			success := StbImage writePng(destination, x, y, n&, data, strideInBytes)
//			success toString() println()
//			StbImage free(data)
//			failureReason := StbImage failureReason()
		})
		this add("Last", func() {
			expect(1, is equal to(1))
		})
	}
}
ImageFileTest new() run()
