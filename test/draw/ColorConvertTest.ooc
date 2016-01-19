use ooc-unit
use draw

ColorConvertTest: class extends Fixture {
	init: func {
		super("ColorConvert")
		this add("from BGR", func {
			color := ColorBgr new(120, 100, 80)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 141, 116)), is true)
			expect(color toBgr() equals(ColorBgr new(120, 100, 80)), is true)
			expect(color toBgra() equals(ColorBgra new(120, 100, 80, 255)), is true)
			expect(color toMonochrome() equals(ColorMonochrome new(94)), is false)
			expect(color toYuv() equals(ColorYuv new(95, 141, 115)), is false)
			expect(color toBgr() equals(ColorBgr new(120, 100, 81)), is false)
			expect(color toBgra() equals(ColorBgra new(120, 100, 81, 255)), is false)
		})
		this add("from BGRA", func {
			color := ColorBgra new(120, 100, 80, 60)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 141, 116)), is true)
			expect(color toBgr() equals(ColorBgr new(120, 100, 80)), is true)
			expect(color toBgra() equals(ColorBgra new(120, 100, 80, 60)), is true)
		})
		this add("from Y", func {
			color := ColorMonochrome new(95)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 128, 128)), is true)
			expect(color toBgr() equals(ColorBgr new(95, 95, 95)), is true)
			expect(color toBgra() equals(ColorBgra new(95, 95, 95, 255)), is true)
		})
		this add("from YUV", func {
			color := ColorYuv new(95, 141, 116)
			expect(color toMonochrome() equals(ColorMonochrome new(95)), is true)
			expect(color toYuv() equals(ColorYuv new(95, 141, 116)), is true)
			expect(color toBgr() equals(ColorBgr new(118, 99, 78)), is true)
			expect(color toBgra() equals(ColorBgra new(118, 99, 78, 255)), is true)
		})
	}
}

ColorConvertTest new() run() . free()
