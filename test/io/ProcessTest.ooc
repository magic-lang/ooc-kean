/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use io
import io/FileReader

ProcessTest: class extends Fixture {
	init: func {
		super("Process")
		this add("Basic use", func {
			scriptName: String
			version (windows)
				scriptName = "bash test/io/input/pipeprocesstester.sh"
			else
				scriptName = "test/io/input/pipeprocesstester.sh"

			scriptArgs := [scriptName, "10000", "abcABC"]
			process := Process new(scriptArgs)
			process setStdout(Pipe new())
			process execute()
			process args free()
			process free()
			scriptArgs free()

			reader := FileReader new(t"test/io/output/sum.txt")
			expect(reader hasNext())
			data := CString new(16)
			reader read(data, 0, 15)
			string := data toString()
			expect(string, is equal to("50005000 abcABC"))
			string free()
			memfree(data)
			reader close() . free()
		})
	}
}

ProcessTest new() run() . free()
