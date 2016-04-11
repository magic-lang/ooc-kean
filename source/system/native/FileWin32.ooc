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
		if (file dir())
			return RemoveDirectory(file path)
		return DeleteFile(file path)
	}

	ooc_get_cwd: unmangled func -> String {
		ret := CharBuffer new(File MAX_PATH_LENGTH + 1)
		bytesWritten := GetCurrentDirectory(File MAX_PATH_LENGTH, ret data)
		if (bytesWritten == 0) OSException new("Failed to get current directory!") throw()
		ret setLength(bytesWritten)
		String new(ret)
	}

	/*
	 * Win32 implementation of File
	 */
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
			return (ffd, status)
		}

		/**
		 * @return true if it's a directory (return false if it doesn't exist)
		 */
		dir: override func -> Bool {
			res := GetFileAttributes(this path as CString)
			(res & FILE_ATTRIBUTE_DIRECTORY) != 0
		}

		/**
		 * @return true if it's a file (ie. exists and is not a directory nor a symbolic link)
		 */
		file: override func -> Bool {
			// our definition of a file: neither a directory or a link
			// (and no, FILE_ATTRIBUTE_NORMAL isn't true when we need it..)
			(ffd, ok) := this _getFindData()
			return (ok) &&
				(((ffd attr) & FILE_ATTRIBUTE_DIRECTORY) == 0) &&
				(((ffd attr) & FILE_ATTRIBUTE_REPARSE_POINT) == 0)
		}

		/**
		 * @return true if the file is a symbolic link
		 */
		link: override func -> Bool {
			(ffd, ok) := this _getFindData()
			return (ok) && ((ffd attr) & FILE_ATTRIBUTE_REPARSE_POINT) != 0
		}

		/**
		 * @return the size of the file, in bytes
		 */
		getSize: override func -> LLong {
			(ffd, ok) := this _getFindData()
			return (ok) ? toLLong(ffd fileSizeLow, ffd fileSizeHigh) : 0
		}

		/**
		 * @return true if the file exists
		 */
		exists: override func -> Bool {
			res := GetFileAttributes(this path as CString)
			(res != INVALID_FILE_ATTRIBUTES)
		}

		/**
		 * @return the permissions for the owner of this file
		 */
		ownerPerm: override func -> Int {
			// Win32 permissions are not unix-like
			return 0
		}

		/**
		 * @return the permissions for the group of this file
		 */
		groupPerm: override func -> Int {
			// Win32 permissions are not unix-like
			return 0
		}

		/**
		 * @return the permissions for the others (not owner, not group)
		 */
		otherPerm: override func -> Int {
			// Win32 permissions are not unix-like
			return 0
		}

		/**
		* @return true if a file is executable by the current owner
		*/
		executable: override func -> Bool {
			// Win32 has no *simple* concept of 'executable' bit
			// we'd have to handle ACLs, and that's a nasty can of worms.
			// For now, `executable` and `setExecutable` are enough
			// to set basic permissions when creating files on *nix.
			// See discussion on this commit for more details:
			// https://github.com/nddrylliog/rock/commit/c6b8e9a23079451f2d6c6964cace8ff786f4d434
			false
		}

		/**
		* set the executable bit on this file's permissions for
		* current user, group, and other.
		*/
		setExecutable: override func (exec: Bool) -> Bool {
			// see comment for 'executable'
			false
		}

		mkdir: override func ~withMode (mode: Int) -> Int {
			if (this relative())
				return this getAbsoluteFile() mkdir()

			p := this parent
			if (!p exists()) this parent mkdir()
			CreateDirectory(this path toCString(), null) ? 0 : -1
		}

		mkfifo: override func ~withMode (mode: Int) -> Int {
			fprintf(stderr, "FileWin32: stub mkfifo")
		}

		/**
		 * @return the time of last access
		 */
		lastAccessed: override func -> Long {
			(ffd, ok) := this _getFindData()
			return (ok) ? toTimestamp(ffd lastAccessTime) : -1
		}

		/**
		 * @return the time of last modification
		 */
		lastModified: override func -> Long {
			(ffd, ok) := this _getFindData()
			return (ok) ? toTimestamp(ffd lastWriteTime) : -1
		}

		/**
		 * @return the time of creation
		 */
		created: override func -> Long {
			(ffd, ok) := this _getFindData()
			return (ok) ? toTimestamp(ffd creationTime) : -1
		}

		/**
		 * @return true if the function is relative to the current directory
		 */
		relative: override func -> Bool {
			// that's a bit rough, but should work most of the time
			!this path startsWith("/") && (this path length() <= 1 || this path[1] != ':')
		}

		/**
		 * The absolute path, e.g. "my/dir" => "C:\current\directory\my\dir"
		 */
		getAbsolutePath: override func -> String {
			fullPath := CharBuffer new(File MAX_PATH_LENGTH)
			fullPath setLength(GetFullPathName(this path toCString(), File MAX_PATH_LENGTH, fullPath data, null))
			this _normalizePath(fullPath toString())
		}

		/**
		 * The long path, ie. with correct casing. e.g. the final path will
		 * contain the original case of the concerned folder/files.
		 */
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

			if (hFile == INVALID_HANDLE_VALUE)
				return result

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
			result
		}

		/**
		 * List the name of the children of this path
		 * Works only on directories, obviously
		 */
		getChildrenNames: override func -> VectorList<String> {
			this _getChildren(String)
		}

		/**
		 * List the children of this path
		 * Works only on directories, obviously
		 */
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
