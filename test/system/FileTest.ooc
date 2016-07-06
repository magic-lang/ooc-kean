/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
import io/File
import io/FileWriter
import io/FileReader

FileTest: class extends Fixture {
	_testOutput := "test/system/output/file/"
	init: func {
		super("File")
		this add("creating directory", func {
			file := File new(this _testOutput)
			file createDirectories()
			expect(file exists(), is true)
			expect(file isDirectory(), is true)
			file free()
		})
		this add("copy", func {
			path := this _testOutput + "test.txt"
			pathCopy := this _testOutput + "test2.txt"
			writer := FileWriter new(path)
			writer write('a')
			writer write('b')
			writer write('c')
			writer free()
			file := File new(path)
			expect(file exists())
			fileCopy := File new(pathCopy)
			file copyTo(fileCopy)
			reader := FileReader new(pathCopy)
			expect(reader hasNext())
			expect(reader read(), is equal to('a'))
			expect(reader read(), is equal to('b'))
			expect(reader read(), is equal to('c'))
			reader free()
			(file, fileCopy) remove()
			(file, fileCopy, path, pathCopy) free()
		})
		this add("static remove, copy, exists and rename", func {
			first := this _testOutput + "first.txt"
			second := this _testOutput + "second.txt"
			third := this _testOutput + "third.txt"
			File remove(first) . remove(second) . remove(third)
			file := File new(first)
			file write(this _testOutput)
			expect(File exists~file(first))
			expect(File exists~file(second), is false)
			file free()
			File copy(first, second)
			expect(File exists~file(second))
			File rename(second, third)
			expect(File exists~file(second), is false)
			expect(File exists~file(third))
			File remove(first)
			File remove(second)
			File remove(third)
			expect(File exists~file(first), is false)
			expect(File exists~file(second), is false)
			expect(File exists~file(third), is false)
			(first, second, third) free()
		})
		this add("cleanup", func {
			file := File new(this _testOutput)
			expect(file exists(), is true)
			file remove()
			expect(file exists(), is false)
			file free()
		})
	}
	free: override func {
		this _testOutput free()
		super()
	}
}

FileTest new() run() . free()
