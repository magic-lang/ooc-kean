use ooc-unit
use ooc-draw
import math
import lang/IO

ColorConvertTest: class extends Fixture {
	init: func () {
		super("Color")
		this add("from BGR", func() {
			color := ColorBgr new(120, 100, 80) 
//			expect(color asMonochrome(), is equal to(ColorMonochrome new(95)))
			expect(color asMonochrome() equals(ColorMonochrome new(95)), is true)
//			expect(color asYuv(), is equal to(ColorYuv new(95, 141, 116)))
//			expect(color asBgr(), is equal to(ColorBgr new(120, 100, 80)))
//			expect(color asBgra(), is equal to(ColorBgra new(120, 100, 80, 255)))
		})
		this add("from BGRA", func() {
			color := ColorBgra new(120, 100, 80, 60) 
//			expect(color asMonochrome(), is equal to(ColorMonochrome new(95)))
//			expect(color asYuv(), is equal to(ColorYuv new(95, 141, 116)))
//			expect(color asBgr(), is equal to(ColorBgr new(120, 100, 80)))
//			expect(color asBgra(), is equal to(ColorBgra new(120, 100, 80, 60)))
		})
		this add("from Y", func() {
			color := ColorMonochrome new(95) 
//			expect(color asMonochrome(), is equal to(ColorMonochrome new(95)))
//			expect(color asYuv(), is equal to(ColorYuv new(95, 128, 128)))
//			expect(color asBgr(), is equal to(ColorBgr new(95, 95, 95)))
//			expect(color asBgra(), is equal to(ColorBgra new(95, 95, 95, 255)))
		})
		this add("from YUV", func() {
			color := ColorYuv new(95, 141, 116) 
//			expect(color asMonochrome(), is equal to(ColorMonochrome new(95)))
//			expect(color asYuv(), is equal to(ColorYuv new(95, 141, 116)))
//			expect(color asBgr(), is equal to(ColorBgr new(118, 99, 78)))
//			expect(color asBgra(), is equal to(ColorBgra new(118, 99, 78, 255)))
		})
	}
}
ColorConvertTest new() run()
