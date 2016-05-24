/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/File
include dirent

version (linux) {
	include sys/stat | (__USE_BSD), sys/types | (__USE_BSD)
} else {
	include sys/stat, sys/types
}

version (unix || apple) {
DIR: extern cover

DirEnt: cover from struct dirent {
	name: extern (d_name) CString
	// The struct has more members, actually, but we don't use them
}

closedir: extern func (DIR*) -> Int
opendir: extern func (const CString) -> DIR*
readdir: extern func (DIR*) -> DirEnt*
readdir_r: extern func (DIR*, DirEnt*, DirEnt**) -> Int
rewinddir: extern func (DIR*)
seekdir: extern func (DIR*, Long)
telldir: extern func (DIR*) -> Long
realpath: extern func (path, resolved: CString) -> CString

File separator = '/'
File pathDelimiter = ':'

ModeT: cover from mode_t
INodeT: cover from ino_t

FileStat: cover from struct stat {
	st_mode: extern ModeT
	st_size: extern SizeT
	st_ino: extern INodeT
	st_atime, st_mtime, st_ctime: extern TimeT
}

READWRITE: extern (O_RDWR) static Int

// mode masks
S_ISDIR: extern func (...) -> Bool // directory
S_ISREG: extern func (...) -> Bool // regular
S_ISLNK: extern func (...) -> Bool // symbolic link

// permissions masks
// Full, Read, Write, eXecute
S_IRWXU, S_IRUSR, S_IWUSR, S_IXUSR: extern ModeT // user
S_IRWXG, S_IRGRP, S_IWGRP, S_IXGRP: extern ModeT // group
S_IRWXO, S_IROTH, S_IWOTH, S_IXOTH: extern ModeT // other

lstat: extern func (CString, FileStat*) -> Int
fstat: extern func (Int, FileStat*) -> Int
chmod: extern func (CString, ModeT) -> Int
fchmod: extern func (Int, ModeT) -> Int
close: extern func (Int) -> Int
_mkdir: extern (mkdir) func (CString, ModeT) -> Int
_mkfifo: extern (mkfifo) func (CString, ModeT) -> Int
umask: extern func (ModeT) -> ModeT
remove: extern func (path: CString) -> Int
_getcwd: extern (getcwd) func (buf: CString, size: SizeT) -> CString
ooc_get_cwd: unmangled func -> String {
	result := CharBuffer new(File MAX_PATH_LENGTH)
	if (!_getcwd(result data as CString, File MAX_PATH_LENGTH))
		OSException new("error trying to getcwd! ") throw()
	result sizeFromData()
	String new (result)
}
_remove: unmangled func (file: File) -> Bool {
	remove(file path) == 0
}

FileUnix: class extends File {
	init: func ~unix (=path)

	isDirectory: override func -> Bool {
		result: FileStat
		res := lstat(this path as CString, result&)
		(res == 0 && S_ISDIR(result st_mode))
	}
	isFile: override func -> Bool {
		result: FileStat
		res := lstat(this path as CString, result&)
		(res == 0 && S_ISREG(result st_mode))
	}
	isLink: override func -> Bool {
		result: FileStat
		res := lstat(this path as CString, result&)
		(res == 0 && S_ISLNK(result st_mode))
	}
	getSize: override func -> LLong {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => result st_size as LLong
			case => -1
		}
	}
	exists: override func -> Bool {
		result: FileStat
		res := lstat(this path as CString, result&)
		(res == 0)
	}
	ownerPermissions: override func -> Int {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => (result st_mode & S_IRWXU) as Int >> 6
			case => -1
		}
	}
	groupPermissions: override func -> Int {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => (result st_mode & S_IRWXG) as Int >> 3
			case => -1
		}
	}
	otherPermissions: override func -> Int {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => (result st_mode & S_IRWXO) as Int
			case => -1
		}
	}
	executable: override func -> Bool {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => (result st_mode & S_IXUSR) != 0
			case => false
		}
	}
	setExecutable: override func (exec: Bool) -> Bool {
		lstatResult, fstatResult: FileStat
		res := lstat(this path as CString, lstatResult&)
		if (res != 0)
			return false // couldn't get file mode
		fd := open(this path as CString, READWRITE)
		if (fd == -1)
			return false
		res = fstat(fd, fstatResult&)
		if (res != 0) {
			if(close(fd) != 0)
				raise("fstat failed, close(fd) failed")
			return false
		}
		if (fstatResult st_ino != lstatResult st_ino || fstatResult st_mode != lstatResult st_mode) {
			if (close(fd) != 0)
				raise("fstat != lstat, close(fd) failed")
			return false
		}
		mode := fstatResult st_mode
		if (exec)
			mode |= (S_IXUSR | S_IXGRP | S_IXOTH)
		else
			mode &= ~(S_IXUSR | S_IXGRP | S_IXOTH)
		result := fchmod(fd, mode) == 0
		if (close(fd) != 0)
			result = false
		result
	}
	lastAccessed: override func -> Long {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => result st_atime as Long
			case => -1
		}
	}
	lastModified: override func -> Long {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => result st_mtime as Long
			case => -1
		}
	}
	created: override func -> Long {
		result: FileStat
		res := lstat(this path as CString, result&)
		match res {
			case 0 => result st_ctime as Long
			case => -1
		}
	}
	relative: override func -> Bool {
		!this path startsWith("/") // Should work most of the time
	}
	getAbsolutePath: override func -> String {
		raise(this path == null, "FileUnix::getAbsolutePath: path is null")
		raise(this path empty(), "FileUnix::getAbsolutePath: path is empty")
		actualPath := calloc(1, MAX_PATH_LENGTH) as CString
		ret := realpath(this path, actualPath)
		if (ret == null)
			OSException new("failed to get absolute path for " + this path) throw()
		actualPath toString()
	}
	getAbsoluteFile: func -> File {
		actualPath := this getAbsolutePath()
		this path != actualPath ? File new(actualPath) : this as File
	}
	_getChildren: func <T> (T: Class) -> VectorList<T> {
		if (!this isDirectory())
			raise("Trying to get the children of the non-directory '" + this path + "'!", This)
		dir := opendir(this path as CString)
		if (!dir)
			raise("Couldn't open directory '" + this path + "' for reading!", This)

		result := VectorList<T> new()
		entry := readdir(dir)
		while (entry != null) {
			if (!_isDirHardlink(entry@ name)) {
				s := String new(entry@ name, entry@ name length())
				match T {
					case String => result add(s)
					case => result add(File new((this path + this separator) & s))
				}
			}
			entry = readdir(dir)
		}
		closedir(dir)
		result
	}
	getChildrenNames: override func -> VectorList<String> { this _getChildren (String) }
	getChildren: override func -> VectorList<File> { this _getChildren (File) }
	createDirectory: override func ~withMode (mode: Int) -> Int { _mkdir(this path as CString, mode as ModeT) }
	makeFIFO: override func ~withMode (mode: Int) -> Int { _mkfifo(this path as CString, mode as ModeT) }
	createTempFile: static func (pattern, mode: String) -> FStream {
		mask := umask(S_IRUSR | S_IWUSR)
		fd := mkstemp(pattern)
		result: FStream = fd >= 0 ? fdopen(fd, mode) : null
		umask(mask)
		result
	}
}
}
