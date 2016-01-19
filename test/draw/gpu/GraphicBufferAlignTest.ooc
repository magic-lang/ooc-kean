use geometry
use ooc-unit
use draw
use draw-gpu
use base
use opengl

GraphicBufferAlignTest: class extends Fixture {
	init: func {
		super("GraphicBufferAlign")
		this add("Align", func {
			GraphicBuffer _alignedWidth = Int[5] new()

			for (i in 0 .. 5)
				GraphicBuffer _alignedWidth[i] = (i + 1) * 16

			expect(GraphicBuffer alignWidth(5), is equal to(16))
			expect(GraphicBuffer alignWidth(16), is equal to(16))
			expect(GraphicBuffer alignWidth(18), is equal to(16))
			expect(GraphicBuffer alignWidth(30), is equal to(32))
			expect(GraphicBuffer alignWidth(34), is equal to(32))
			expect(GraphicBuffer alignWidth(78), is equal to(80))
			expect(GraphicBuffer alignWidth(80), is equal to(80))
			expect(GraphicBuffer alignWidth(90), is equal to(80))

			expect(GraphicBuffer alignWidth(5, AlignWidth Floor), is equal to(16))
			expect(GraphicBuffer alignWidth(16, AlignWidth Floor), is equal to(16))
			expect(GraphicBuffer alignWidth(31, AlignWidth Floor), is equal to(16))
			expect(GraphicBuffer alignWidth(80, AlignWidth Floor), is equal to(80))
			expect(GraphicBuffer alignWidth(90, AlignWidth Floor), is equal to(80))

			expect(GraphicBuffer alignWidth(0, AlignWidth Ceiling), is equal to(16))
			expect(GraphicBuffer alignWidth(16, AlignWidth Ceiling), is equal to(16))
			expect(GraphicBuffer alignWidth(16, AlignWidth Ceiling), is equal to(16))
			expect(GraphicBuffer alignWidth(17, AlignWidth Ceiling), is equal to(32))
			expect(GraphicBuffer alignWidth(65, AlignWidth Ceiling), is equal to(80))
			expect(GraphicBuffer alignWidth(80, AlignWidth Ceiling), is equal to(80))
			expect(GraphicBuffer alignWidth(90, AlignWidth Ceiling), is equal to(80))
		})
	}
}

GraphicBufferAlignTest new() run() . free()
