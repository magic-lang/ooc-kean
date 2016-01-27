include stddef, stdlib, stdio, ctype, stdbool
include ./Array
import ../Owner

Object: abstract class {
	class: Class

	free: virtual func {
		this __destroy__()
		free(this)
	}

	/// Instance initializer: set default values for a new instance of this class
	__defaults__: func

	/// Finalizer: cleans up any objects belonging to this instance
	__destroy__: func

	instanceOf?: final func (T: Class) -> Bool {
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
		object := gc_malloc(instanceSize) as Object
		if (object)
			object class = this
		object
	}
	inheritsFrom?: final func ~_class (T: This) -> Bool {
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
	toText: func -> Text { this ? t"true" : t"false" }
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
			gc_free(this context)
			this context = null
			this thunk = null
		}
		result
	}
}

Cell: class <T> {
	val: __onheap__ T

	init: func (=val)
	init: func ~noval

	free: override func {
		gc_free(this val)
		super()
	}

	set: func (=val)
	get: func -> T { val }

	toString: func -> String {
		result: String
		if (T inheritsFrom?(Text))
			result = (this val as Text) toString()
		else if (T inheritsFrom?(String))
			result = this val as String
		else if (T inheritsFrom?(Bool))
			result = (this val as Bool) toString()
		else if (T inheritsFrom?(Char))
			result = (this val as Char) toString()
		else if (T inheritsFrom?(Int))
			result = (this val as Int) toString()
		else if (T inheritsFrom?(Long))
			result = (this val as Long) toString()
		else if (T inheritsFrom?(LLong))
			result = (this val as LLong) toString()
		else if (T inheritsFrom?(UInt))
			result = (this val as UInt) toString()
		else if (T inheritsFrom?(ULong))
			result = (this val as ULong) toString()
		else if (T inheritsFrom?(ULLong))
			result = (this val as ULLong) toString()
		else if (T inheritsFrom?(Float))
			result = "%.8f" formatFloat(this val as Float)
		else if (T inheritsFrom?(Double))
			result = "%.12f" formatDouble(this val as Double)
		else if (T inheritsFrom?(LDouble))
			result = "%.12f" formatLDouble(this val as LDouble)
		else
			raise("[Cell] toString() is not implemented on the specified type")
		result
	}
}

operator [] <T> (c: Cell<T>, T: Class) -> T {
	if (!c T inheritsFrom?(T)) {
		Exception new(Cell, "Wants a %s, but got a %s" format(T name, c T name)) throw()
	}
	c val
}
