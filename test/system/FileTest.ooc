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
	_testOutput := "test/sdk/output/"
	init: func {
		super("File")
		this add("creating directory", func {
			file := File new(this _testOutput)
			file mkdirs()
			expect(file exists(), is true)
			expect(file dir(), is true)
			file free()
		})
		this add("copy", func {
			path := this _testOutput + "test.txt"
			pathCopy := this _testOutput + "test2.txt"
			writer := FileWriter new(path)
			writer write('a')
			writer write('b')
			writer write('c')
			writer close()
			writer free()
			file := File new(path)
			expect(file exists())
			fileCopy := File new(pathCopy)
			file copyTo(fileCopy)
			reader := FileReader new(Text new(pathCopy))
			expect(reader hasNext())
			expect(reader read(), is equal to('a'))
			expect(reader read(), is equal to('b'))
			expect(reader read(), is equal to('c'))
			reader close()
			reader free()
			file rm()
			fileCopy rm()
			(file, fileCopy, path, pathCopy) free()
		})
		this add("cleanup", func {
			file := File new(this _testOutput)
			expect(file exists(), is true)
			file rm()
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
