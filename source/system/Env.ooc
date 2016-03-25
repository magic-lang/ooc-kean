/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Env: class {
	// returns an environment variable. if not found, it returns null
	get: static func (variableName: String) -> String {
		x := getenv(variableName as CString)
		x != null ? x toString() : null
	}
	set: static func (key, value: String, overwrite: Bool) -> Int {
		result := -1
		if (key != null && value != null) {
			version(windows)
				result = putenv("%s=%s" format(key toCString(), value toCString()) toCString())
			else
				result = setenv(key toCString(), value toCString(), overwrite)
		}
		result
	}
	set: static func ~overwrite (key, value: String) -> Int {
		set(key, value, true)
	}
	unset: static func (key: String) -> Int {
		result: Int
		version(windows) {
			// under mingw, this unsets the key
			result = putenv((key + "=") toCString())
		} else {
			unsetenv(key toCString())
			result = 0
		}
		result
	}
}
operator [] (c: EnvClass, key: String) -> String { Env get(key) }
operator []= (c: EnvClass, key, value: String) { Env set(key, value, true) }
