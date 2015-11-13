use ooc-cli
use ooc-collections
use ooc-base
use ooc-unit

ArgumentParserTest: class extends Fixture {
	init: func {
		super("ArgumentParser")
		this add("No parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"--arga")
			inputList add(t"-b")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentBValue: Text
			parser add(t"arga", 'a', Event new(func { argumentAValue = t"a" }))
			parser add(t"argb", 'b', Event new(func { argumentBValue = t"b" }))
			parser parse(inputList)
			expect(argumentAValue == t"a")
			expect(argumentBValue == t"b")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
		})
		this add("With parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"--arga")
			inputList add(t"1234")
			inputList add(t"abcd")
			inputList add(t"--argb")
			inputList add(t"qwerty")
			inputList add(t"-c")
			inputList add(t"c1")
			inputList add(t"c2")
			inputList add(t"c3")
			parser := ArgumentParser new()
			argumentAFirstValue: Text
			argumentASecondValue: Text
			argumentBValue: Text
			argumentCFirstValue: Text
			argumentCSecondValue: Text
			argumentCThirdValue: Text
			parser add(t"arga", 'a', 2, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentAFirstValue = list[0]; argumentASecondValue = list[1] }))
			parser add(t"argb", 'b', Event1<Text> new(func (parameter: Text) { argumentBValue = parameter }))
			parser add(t"argc", 'c', 3, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAFirstValue == t"1234")
			expect(argumentASecondValue == t"abcd")
			expect(argumentBValue == t"qwerty")
			expect(argumentCFirstValue == t"c1")
			expect(argumentCSecondValue == t"c2")
			expect(argumentCThirdValue == t"c3")
			inputList free()
			parser free()
			argumentAFirstValue free()
			argumentASecondValue free()
			argumentBValue free()
			argumentCFirstValue free()
			argumentCSecondValue free()
			argumentCThirdValue free()
		})
		this add("Negative parameter", func {
			inputList := VectorList<Text> new()
			inputList add(t"-a")
			inputList add(t"-12345")
			inputList add(t"-b")
			inputList add(t"--argc")
			inputList add(t"5")
			inputList add(t"-10")
			inputList add(t"15")
			parser := ArgumentParser new()
			argumentAValue: Text
			argumentBValue: Text
			argumentCFirstValue: Text
			argumentCSecondValue: Text
			argumentCThirdValue: Text
			parser add(t"arga", 'a', Event1<Text> new(func (parameter: Text) { argumentAValue = parameter }))
			parser add(t"argb", 'b', Event new(func { argumentBValue = t"b" }))
			parser add(t"argc", 'c', 3, Event1<VectorList<Text>> new(func (list: VectorList<Text>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAValue == t"-12345")
			expect(argumentBValue == t"b")
			expect(argumentCFirstValue == t"5")
			expect(argumentCSecondValue == t"-10")
			expect(argumentCThirdValue == t"15")
			inputList free()
			parser free()
			argumentAValue free()
			argumentBValue free()
			argumentCFirstValue free()
			argumentCSecondValue free()
			argumentCThirdValue free()
		})
	}
}
ArgumentParserTest new() run()
