/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stddef, ctype, stdbool
include ./Array
import Owner

Object: abstract class {
	class: Class

	free: virtual func {
		this __destroy__()
		memfree(this)
	}

	/// Instance initializer: set default values for a new instance of this class
	__defaults__: func

	/// Finalizer: cleans up any objects belonging to this instance
	__destroy__: func

	instanceOf: final func (T: Class) -> Bool {
		result := false
		if (this) {
			current := class
			while (current) {
				if (current == T) {
					result = true
					break
				}
				current = current super
			}
		}
		result
	}
}

Class: abstract class {
	// Number of octets to allocate for a new instance of this class
	instanceSize: SizeT

	/** Number of octets to allocate to hold an instance of this class
		it's different because for classes, instanceSize may greatly
		vary, but size will always be equal to the size of a Pointer.
		for basic types (e.g. Int, Char, Pointer), size == instanceSize */
	size: SizeT

	// Human readable representation of the name of this class
	name: String

	// Pointer to instance of super-class
	super: This

	// Create a new instance of the object of type defined by this class
	alloc: final func ~_class -> Object {
		object := calloc(1, this instanceSize) as Object
		if (object)
			object class = this
		object
	}
	inheritsFrom: final func ~_class (T: This) -> Bool {
		result := false
		current := this
		while (current) {
			if (current == T) {
				result = true
				break
			}
			current = current super
		}
		result
	}
}

Array: cover from _lang_array__Array {
	length: extern SizeT
	data: extern Pointer
	free: extern (_lang_array__Array_free) func
}

None: class {
	init: func
}

Void: cover from void

Pointer: cover from Void* {
	toString: func -> String { "%p" format(this) }
}

Bool: cover from bool {
	toString: func -> String { this ? "true" : "false" }
}

Closure: cover {
	thunk: Pointer
	context: Pointer
	_owner: Owner
	owner ::= this _owner
	isOwned ::= this _owner != Owner Unknown && this _owner != Owner Static && this _owner != Owner Stack && this context != null
	take: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Receiver && this context != null)
			this _owner = Owner Sender
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Sender && this context != null)
			this _owner = Owner Receiver
		this
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _owner == criteria && this free()
	}
	free: func@ -> Bool {
		result := this context != null
		if (result) {
			memfree(this context)
			this context = null
			this thunk = null
		}
		result
	}
	fromPointer: static func (funcPtr: Pointer, owner: Owner = Owner Sender) -> This {
		(funcPtr, null, owner) as This
	}
}
