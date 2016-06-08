/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import FileReader, FileWriter, Reader, BufferWriter, BufferReader
import native/[FileWin32, FileUnix]

/**
 * Represents a file/directory path, allows to retrieve informations like
 * last date of creation/access/modification, permissions, size,
 * existence, content, type, children...
 *
 * You can also create directories, remove files, read their content,
 * copy them, write to them.
 *
 * For input/output (I/O) beyond 'reading to a String' and
 * 'writing a String', see the FileReader and FileWriter classes
 */
File: abstract class {
	path: String {
		get
		set (value) {
			if (this path)
				this path free()
			this path = value ? value clone() : null
		}
	}
	name ::= this getName()
	parent ::= this getParent()
	extension ::= this getExtension()
	nameWithoutExtension ::= this getNameWithoutExtension()
	pathWithoutExtension ::= this getPathWithoutExtension()
	children: VectorList<This> { get {
		this getChildren()
	}}

	rectifySeparator: func {
		if (this isDirectory() && !this path endsWith(This separator)) {
			oldPath := this path
			this path = oldPath + This separator
			oldPath free()
		}
		else if (!this isDirectory() && this path endsWith(This separator)) {
			newPath := this path trimRight(This separator)
			this path free()
			this path = newPath
		}
	}

	isDirectory: abstract func -> Bool
	isFile: abstract func -> Bool
	isLink: abstract func -> Bool
	getSize: abstract func -> LLong
	exists: abstract func -> Bool
	ownerPermissions: abstract func -> Int
	groupPermissions: abstract func -> Int
	otherPermissions: abstract func -> Int
	executable: abstract func -> Bool

	setExecutable: abstract func (exec: Bool) -> Bool
	getPath: func -> String { this path }
	getName: func -> String {
		trimmed := this path trim(This separator)
		idx := trimmed lastIndexOf(This separator)
		idx == -1 ? trimmed : trimmed substring(idx + 1)
	}
	getParent: func -> This {
		result: This
		pName := this parentName()
		if (pName) {
			result = This new(pName)
			pName free()
		} else if (this path != "." && !this path startsWith(This separator))
			result = This new(".")
		result
	}
	getExtension: func -> String {
		result := ""
		if (!this isDirectory()) {
			index := this path lastIndexOf('.')
			if (index > 0)
				result = this path substring(index + 1)
		}
		result
	}
	getNameWithoutExtension: func -> String {
		result := this name
		if (this hasExtension()) {
			result = this name substring(0, this name lastIndexOf('.'))
		}
		result
	}
	getPathWithoutExtension: func -> String {
		result := this path
		if (this hasExtension()) {
			result = this path substring(0, this path lastIndexOf('.'))
		}
		result
	}
	hasExtension: func -> Bool {
		(this path lastIndexOf('.') > 0) && (!this isDirectory())
	}
	parentName: func -> String {
		idx := this path lastIndexOf(This separator)
		idx == -1 ? null as String : this path substring(0, idx)
	}
	// Create a named pipe at the path specified by this file
	makeFIFO: func -> Int { this makeFIFO(0c755) }
	makeFIFO: abstract func ~withMode (mode: Int) -> Int
	// Create a directory at the path specified by this file,
	createDirectory: func -> Int { this createDirectory(0c755) }
	createDirectory: abstract func ~withMode (mode: Int) -> Int
	// Create a directory at the path specified by this file and all the parent directories if needed
	createDirectories: func -> Int { this createDirectories(0c755) }
	createDirectories: func ~withMode (mode: Int) -> Int {
		p := this parent
		if (p)
			p createDirectories(mode) . free()
		this createDirectory()
	}

	lastAccessed: abstract func -> Long
	lastModified: abstract func -> Long
	created: abstract func -> Long
	relative: abstract func -> Bool
	getAbsolutePath: abstract func -> String
	getLongPath: func -> String { this path }
	getAbsoluteFile: func -> This { This new(this getAbsolutePath()) }
	getReducedPath: func -> String {
		elems := VectorList<String> new()
		tokens := this path split(This separator)
		for (elem in tokens)
			if (elem == "..") {
				if (!elems empty)
					elems removeAt(elems count - 1)
				else
					elems add(elem)
			} else if (elem != "." && elem != "")
				elems add(elem)

		result := ""
		if (!elems empty) {
			result = elems[0]
			for (i in 1 .. elems count)
				result = (result + This separator) >> elems[1]
		}
		if (this path startsWith(This separator))
			result = This separator + result
		result
	}
	getReducedFile: func -> This { This new(this getReducedPath()) }
	getChildrenNames: abstract func -> VectorList<String>
	getChildren: abstract func -> VectorList<This>
	remove: func -> Bool { _remove(this) }
	removeRecursive: func -> Bool {
		if (this isDirectory()) {
			children := this getChildren()
			for (i in 0 .. children count) {
				child := children[i]
				if (!child removeRecursive())
					return false
			}
		}
		this remove()
	}
	// Searches for a file with given name until cb returns false
	find: func (name: String, cb: Func (This) -> Bool) -> Bool {
		if (this getName() == name)
			if (!cb(this))
				return true // abort if caller is happy

		if (this isDirectory()) {
			children := this getChildren()
			for (child in children)
				if (child find(name, cb))
					return true // abort if caller found happiness in a sub-directory
		}
		false
	}
	find: func ~first (name: String) -> This {
		result: This
		this find(name, |f|
			result = f
			false
		)
		result
	}
	copyTo: func (dstFile: This) {
		dstParent := dstFile parent
		dstParent createDirectories() . free()
		src := FileReader new(this)
		dst := FileWriter new(dstFile)
		max := 8192
		buffer := Char[max] new()

		while (src hasNext()) {
			num := src read(buffer data, 0, max)
			dst write(buffer data, num)
		}

		(buffer, dst, src) free()
	}
	read: func -> String {
		fR := FileReader new(this)
		bW := BufferWriter new() . write(fR)
		fR free()
		result := bW buffer toString()
		bW free()
		result
	}
	write: func ~string (str: String) {
		buffer := BufferReader new(str _buffer)
		this write(buffer)
		buffer free()
	}
	write: func ~reader (reader: Reader) {
		FileWriter new(this) write(reader) . free()
	}
	// Walk this directory and call `f` on all files it contains, recursively, until f returns false
	walk: func (f: Func(This) -> Bool) -> Bool {
		result := true
		if (this isFile()) {
			if (!f(this))
				result = false
		} else if (this isDirectory())
			for (child in this getChildren())
				if (!child walk(f))
					result = false
		result
	}
	/**
	 * If this file has path: some/base/directory/sub/path
	 * And base is a file like: some/base/directory
	 * This method will return a File with path "sub/path"
	 */
	rebase: func (base: This) -> This {
		left := base getReducedFile() getAbsolutePath() replaceAll(This separator, '/')
		full := this getReducedFile() getAbsolutePath() replaceAll(This separator, '/')
		if (!left endsWith("/"))
			left = left >> "/"
		right := full substring(left size)
		This new(right)
	}
	getChild: func (childPath: String) -> This { This new((this path + this separator) << childPath) }
	getChild: func ~file (file: This) -> This { this getChild(file path) }

	separator: static Char
	pathDelimiter: static Char
	MAX_PATH_LENGTH := static 16383

	new: static func (.path) -> This {
		result: This = null
		version (unix || apple)
			result = FileUnix new(path)
		version (windows)
			result = FileWin32 new(path)
		raise(result == null, "Unsupported platform!\n", This)
		result
	}
	copy: static func (originalPath, newPath: String) {
		originalFile := This new(originalPath)
		newFile := This new(newPath)
		originalFile copyTo(newFile)
		(originalFile, newFile) free()
	}
	exists: static func ~file (path: String) -> Bool {
		file := This new(path)
		result := file exists()
		file free()
		result
	}
	rename: static func (originalPath, newPath: String) {
		rename(originalPath toCString(), newPath toCString())
	}
	createDirectories: static func ~file (path: String) -> Int {
		file := This new(path)
		result := file createDirectories()
		file free()
		result
	}
	createParentDirectories: static func ~file (path: String) -> Int {
		file := This new(path)
		fileParent := file parent
		result := fileParent createDirectories()
		(fileParent, file) free()
		result
	}
	remove: static func ~file (path: String) -> Bool {
		file := This new(path)
		result := file remove()
		file free()
		result
	}
	getCwd: static func -> String {
		ooc_get_cwd()
	}
	free: override func {
		if (this path)
			this path free()
		super()
	}
}

_isDirHardlink: func (dir: CString) -> Bool {
	(dir[0] == '.') && (dir[1] == '\0' || ( dir[1] == '.' && dir[2] == '\0'))
}
