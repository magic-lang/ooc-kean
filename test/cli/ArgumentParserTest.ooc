/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use cli
use collections
use base
use unit

ArgumentParserTest: class extends Fixture {
	init: func {
		super("ArgumentParser")
		this add("No parameter", func {
			inputList := VectorList<String> new()
			inputList add("--arga")
			inputList add("-b")
			parser := ArgumentParser new()
			argumentAValue: String
			argumentBValue: String
			parser add("arga", 'a', Event new(func { argumentAValue = "a" }))
			parser add("argb", 'b', Event new(func { argumentBValue = "b" }))
			parser parse(inputList)
			expect(argumentAValue == "a")
			expect(argumentBValue == "b")
			(inputList, parser, argumentAValue, argumentBValue) free()
		})
		this add("With parameter", func {
			inputList := VectorList<String> new()
			inputList add("--arga")
			inputList add("1234")
			inputList add("abcd")
			inputList add("--argb")
			inputList add("qwerty")
			inputList add("-c")
			inputList add("c1")
			inputList add("c2")
			inputList add("c3")
			parser := ArgumentParser new()
			argumentAFirstValue: String
			argumentASecondValue: String
			argumentBValue: String
			argumentCFirstValue: String
			argumentCSecondValue: String
			argumentCThirdValue: String
			parser add("arga", 'a', 2, Event1<VectorList<String>> new(func (list: VectorList<String>) { argumentAFirstValue = list[0]; argumentASecondValue = list[1] }))
			parser add("argb", 'b', Event1<String> new(func (parameter: String) { argumentBValue = parameter }))
			parser add("argc", 'c', 3, Event1<VectorList<String>> new(func (list: VectorList<String>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAFirstValue == "1234")
			expect(argumentASecondValue == "abcd")
			expect(argumentBValue == "qwerty")
			expect(argumentCFirstValue == "c1")
			expect(argumentCSecondValue == "c2")
			expect(argumentCThirdValue == "c3")
			(inputList, parser, argumentAFirstValue, argumentASecondValue, argumentBValue, argumentCFirstValue, argumentCSecondValue, argumentCThirdValue) free()
		})
		this add("Negative parameter", func {
			inputList := VectorList<String> new()
			inputList add("-a")
			inputList add("-12345")
			inputList add("-b")
			inputList add("--argc")
			inputList add("5")
			inputList add("-10")
			inputList add("15")
			parser := ArgumentParser new()
			argumentAValue: String
			argumentBValue: String
			argumentCFirstValue: String
			argumentCSecondValue: String
			argumentCThirdValue: String
			parser add("arga", 'a', Event1<String> new(func (parameter: String) { argumentAValue = parameter }))
			parser add("argb", 'b', Event new(func { argumentBValue = "b" }))
			parser add("argc", 'c', 3, Event1<VectorList<String>> new(func (list: VectorList<String>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser parse(inputList)
			expect(argumentAValue == "-12345")
			expect(argumentBValue == "b")
			expect(argumentCFirstValue == "5")
			expect(argumentCSecondValue == "-10")
			expect(argumentCThirdValue == "15")
			(inputList, parser, argumentAValue, argumentBValue, argumentCFirstValue, argumentCSecondValue, argumentCThirdValue) free()
		})
		this add("No shortIdentifier", func {
			inputList := VectorList<String> new()
			inputList add("-a")
			inputList add("-12345")
			inputList add("-argb")
			inputList add("--argc")
			inputList add("5")
			inputList add("-10")
			inputList add("15")
			inputList add("--argd")
			inputList add("1")
			inputList add("2")
			parser := ArgumentParser new()
			argumentAValue: String
			argumentAValue = ""
			argumentBValue: String
			argumentBValue = ""
			argumentCFirstValue: String
			argumentCSecondValue: String
			argumentCThirdValue: String
			argumentDFirstValue: String
			argumentDSecondValue: String
			parser add("arga", Event1<String> new(func (parameter: String) { argumentAValue = parameter }))
			parser add("argb", Event new(func { argumentBValue = "b" }))
			parser add("argc", 'c', 3, Event1<VectorList<String>> new(func (list: VectorList<String>) { argumentCFirstValue = list[0]; argumentCSecondValue = list[1]; argumentCThirdValue = list[2] }))
			parser add("argd", 2, Event1<VectorList<String>> new(func (list: VectorList<String>) { argumentDFirstValue = list[0]; argumentDSecondValue = list[1] }))
			parser parse(inputList)
			expect(argumentAValue == "")
			expect(argumentBValue == "")
			expect(argumentCFirstValue == "5")
			expect(argumentCSecondValue == "-10")
			expect(argumentCThirdValue == "15")
			expect(argumentDFirstValue == "1")
			expect(argumentDSecondValue == "2")
			(inputList, parser, argumentAValue, argumentBValue, argumentCFirstValue, argumentCSecondValue, argumentCThirdValue, argumentDFirstValue, argumentDSecondValue) free()
		})
		this add("Compact flags", func {
			inputList := VectorList<String> new()
			inputList add("-abc")
			inputList add("default")
			inputList add("--argd")
			inputList add("dVal")
			parser := ArgumentParser new()
			argumentAValue: String
			argumentBValue: String
			argumentCValue: String
			argumentDValue: String
			defaultArgumentValue: String
			parser add("arga", 'a', Event new(func { argumentAValue = "a" }))
			parser add("argb", 'b', Event new(func { argumentBValue = "b" }))
			parser add("argc", 'c', Event new(func { argumentCValue = "c" }))
			parser add("argd", 'd', Event1<String> new(func (parameter: String) { argumentDValue = parameter }))
			parser addDefault(Event1<String> new(func (parameter: String) { defaultArgumentValue = parameter }))
			parser parse(inputList)
			expect(argumentAValue == "a")
			expect(argumentBValue == "b")
			expect(argumentCValue == "c")
			expect(argumentDValue == "dVal")
			expect(defaultArgumentValue == "default")
			(inputList, parser, argumentAValue, argumentBValue, argumentCValue, argumentDValue) free()
		})
	}
}

ArgumentParserTest new() run() . free()
