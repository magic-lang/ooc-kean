/*use ooc-math
use ooc-unit
use ooc-draw-gpu-android
use ooc-draw-gpu
use ooc-base

GraphicBufferAlignTest: class extends Fixture {
	init: func {
		super("GraphicBufferAlign")
		this add("Align", func {
			GraphicBuffer _unpaddedWidth = Int[5] new()

			for(i in 0..5) {
				GraphicBuffer _unpaddedWidth[i] = (i+1)*16
				println("Unpadded width: " + GraphicBuffer _unpaddedWidth[i])
			}
			expect((GraphicBuffer alignWidth(5) == 16), is true)
			expect((GraphicBuffer alignWidth(16) == 16), is true)
			expect((GraphicBuffer alignWidth(18) == 16), is true)
			expect((GraphicBuffer alignWidth(30) == 32), is true)
			expect((GraphicBuffer alignWidth(34) == 32), is true)
			expect((GraphicBuffer alignWidth(78) == 80), is true)
			expect((GraphicBuffer alignWidth(80) == 80), is true)
			expect((GraphicBuffer alignWidth(90) == 80), is true)

			expect((GraphicBuffer alignWidth(5, AlignWidth Floor) == 16), is true)
			expect((GraphicBuffer alignWidth(16, AlignWidth Floor) == 16), is true)
			expect((GraphicBuffer alignWidth(31, AlignWidth Floor) == 16), is true)
			expect((GraphicBuffer alignWidth(80, AlignWidth Floor) == 80), is true)
			expect((GraphicBuffer alignWidth(90, AlignWidth Floor) == 80), is true)

			expect((GraphicBuffer alignWidth(0, AlignWidth Ceiling) == 16), is true)
			expect((GraphicBuffer alignWidth(16, AlignWidth Ceiling) == 16), is true)
			expect((GraphicBuffer alignWidth(16, AlignWidth Ceiling) == 16), is true)
			expect((GraphicBuffer alignWidth(17, AlignWidth Ceiling) == 32), is true)
			expect((GraphicBuffer alignWidth(65, AlignWidth Ceiling) == 80), is true)
			expect((GraphicBuffer alignWidth(80, AlignWidth Ceiling) == 80), is true)
			expect((GraphicBuffer alignWidth(90, AlignWidth Ceiling) == 80), is true)

		})
	}
}
GraphicBufferAlignTest new() run()*/
