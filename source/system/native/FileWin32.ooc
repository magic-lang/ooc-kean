/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import structs/VectorList
import io/File

version(windows) {
File separator = '\\'
File pathDelimiter = ';'

_remove: unmangled func (file: File) -> Bool {
	file isDirectory() ? RemoveDirectory(file path) : DeleteFile(file path)
}

ooc_get_cwd: unmangled func -> String {
	ret := CharBuffer new(File MAX_PATH_LENGTH + 1)
	bytesWritten := GetCurrentDirectory(File MAX_PATH_LENGTH, ret data)
	if (bytesWritten == 0)
		OSException new("Failed to get current directory!") throw()
	ret setLength(bytesWritten)
	String new(ret)
}

FileWin32: class extends File {
	init: func ~win32 (.path) {
		this path = this _normalizePath(path)
	}
	_getFindData: func -> (FindData, Bool) {
		ffd: FindData
		hFind := FindFirstFile(this path toCString(), ffd&)
		status := true
		if (hFind != INVALID_HANDLE_VALUE)
			FindClose(hFind)
		else
			status = false
		(ffd, status)
	}
	isDirectory: override func -> Bool {
		res := GetFileAttributes(this path as CString)
		(res & FILE_ATTRIBUTE_DIRECTORY) != 0
	}
	isFile: override func -> Bool {
		// our definition of a file: neither a directory or a link
		// (and no, FILE_ATTRIBUTE_NORMAL isn't true when we need it..)
		(ffd, ok) := this _getFindData()
		ok && ((ffd attr) & FILE_ATTRIBUTE_DIRECTORY) == 0 && ((ffd attr) & FILE_ATTRIBUTE_REPARSE_POINT) == 0
	}
	isLink: override func -> Bool {
		(ffd, ok) := this _getFindData()
		ok && ((ffd attr) & FILE_ATTRIBUTE_REPARSE_POINT) != 0
	}
	getSize: override func -> LLong {
		(ffd, ok) := this _getFindData()
		ok ? toLLong(ffd fileSizeLow, ffd fileSizeHigh) : 0
	}
	exists: override func -> Bool {
		res := GetFileAttributes(this path as CString)
		(res != INVALID_FILE_ATTRIBUTES)
	}
	// Win32 permissions are not unix-like
	ownerPermissions: override func -> Int { 0 }
	groupPermissions: override func -> Int { 0 }
	otherPermissions: override func -> Int { 0 }
	executable: override func -> Bool { false }
	setExecutable: override func (exec: Bool) -> Bool { false }
	createDirectory: override func ~withMode (mode: Int) -> Int {
		if (this relative())
			return this getAbsoluteFile() createDirectory()
		p := this parent
		if (!p exists())
			this parent createDirectory()
		CreateDirectory(this path toCString(), null) ? 0 : -1
	}
	makeFIFO: override func ~withMode (mode: Int) -> Int {
		fprintf(stderr, "FileWin32: stub mkfifo")
	}
	lastAccessed: override func -> Long {
		(ffd, ok) := this _getFindData()
		ok ? toTimestamp(ffd lastAccessTime) : -1
	}
	lastModified: override func -> Long {
		(ffd, ok) := this _getFindData()
		ok ? toTimestamp(ffd lastWriteTime) : -1
	}
	created: override func -> Long {
		(ffd, ok) := this _getFindData()
		ok ? toTimestamp(ffd creationTime) : -1
	}
	relative: override func -> Bool {
		!this path startsWith("/") && (this path length() <= 1 || this path[1] != ':') // Should work most of the time
	}
	getAbsolutePath: override func -> String {
		fullPath := CharBuffer new(File MAX_PATH_LENGTH)
		fullPath setLength(GetFullPathName(this path toCString(), File MAX_PATH_LENGTH, fullPath data, null))
		this _normalizePath(fullPath toString())
	}
	// The long path, ie. with correct casing. e.g. the final path will contain the original case of the concerned folder/files
	getLongPath: func -> String {
		abs := this getAbsoluteFile()
		if (!abs exists())
			Exception new(class, "Called File getLongPath on non-existing file %s" format(abs path)) throw()
		longPath := CharBuffer new(File MAX_PATH_LENGTH)
		longPath setLength(GetLongPathName(abs path toCString(), longPath data, File MAX_PATH_LENGTH))
		longPath toString()
	}
	_getChildren: func <T> (T: Class) -> VectorList<T> {
		result := VectorList<T> new()
		ffd: FindData
		searchPath := this path + "\\*"
		hFile := FindFirstFile(searchPath toCString(), ffd&)

		if (hFile != INVALID_HANDLE_VALUE) {
			running := true
			while (running) {
				if (!_isDirHardlink(ffd fileName)) {
					s := ffd fileName toString()
					match T {
						case String => result add(s)
						case => result add(File new((this path + this separator) & s))
					}
				}
				running = FindNextFile(hFile, ffd&)
			}
			FindClose(hFile)
		}
		result
	}
	getChildrenNames: override func -> VectorList<String> {
		this _getChildren(String)
	}
	getChildren: override func -> VectorList<File> {
		this _getChildren (File)
	}
	_normalizePath: static func (in: String) -> String {
		// normalize "c:/Dev" to "C:\Dev"
		result := in replaceAll("/", "\\")
		if (result size >= 2 && result[1] == ':')
			result = result[0 .. 1] toUpper() + result[1 .. -1] // normalize "c:\Dev" to "C:\Dev"
		result
	}
}
}
