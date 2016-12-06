/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Dynlib: abstract class {
	suffix: static String
	path: String
	success := false

	// If the platform-specific file extension is missing, it will be added
	load: static func (path: String) -> This {
		dl: This = null
		version (windows) {
			dl = DynlibWin32 new(path)
		} else {
			dl = DynlibUnix new(path)
		}
		if (!dl success)
			dl = null
		dl
	}

	// The address of the symbol with a given name.
	symbol: abstract func (name: String) -> Pointer

	// This must be the last called method on a given instance.
	close: abstract func -> Bool
}

{
	version (windows) {
		Dynlib suffix = ".dll"
	} else {
		version (apple) {
			Dynlib suffix = ".dylib"
		} else {
			Dynlib suffix = ".so"
		}
	}
}

version (windows) {
	DynlibWin32: class extends Dynlib {
		handle: HModule
		init: func (=path) {
			this handle = LoadLibraryA(path)
			if (!this handle)
				this handle = LoadLibraryA(path + suffix)
			this success = (this handle != null)
		}
		symbol: override func (name: String) -> Pointer {
			GetProcAddress(this handle, name)
		}
		close: override func -> Bool {
			FreeLibrary(this handle)
		}
	}
}

version (!windows) {
	include dlfcn
	RTLD_LAZY, RTLD_NOW, RTLD_GLOBAL, RTLD_LOCAL: extern Int
	version(android)
		RTLD_DEFAULT: extern Pointer

	dlopen: extern func (path: CString, flag: Int) -> Pointer
	dlsym: extern func (handle: Pointer, name: CString) -> Pointer
	dlclose: extern func (handle: Pointer) -> Int

	DynlibUnix: class extends Dynlib {
		handle: Pointer
		init: func (=path) {
			this handle = dlopen(path, RTLD_LAZY)
			if (!this handle) {
				fullPath := path + suffix
				this handle = dlopen(fullPath, RTLD_LAZY)
				fullPath free()
			}
			this success = (this handle != null)
		}
		symbol: override func (name: String) -> Pointer {
			dlsym(this handle, name)
		}
		close: override func -> Bool {
			dlclose(this handle) == 0
		}
	}
}
