include stddef, stdlib, stdio, ctype, stdbool
include ./Array

/**
 * objects
 */
Object: abstract class {

    class: Class

    /// Instance initializer: set default values for a new instance of this class
    __defaults__: func {}

    /// Finalizer: cleans up any objects belonging to this instance
    __destroy__: func {}

    free: virtual func {
      this __destroy__()
      free(this)
    }

    /** return true if *class* is a subclass of *T*. */
    instanceOf?: final func (T: Class) -> Bool {
        if(!this) return false

        current := class
        while(current) {
            if(current == T) return true
            current = current super
        }
        false
    }

}

Class: abstract class {

    /// Number of octets to allocate for a new instance of this class
    instanceSize: SizeT

    /** Number of octets to allocate to hold an instance of this class
        it's different because for classes, instanceSize may greatly
        vary, but size will always be equal to the size of a Pointer.
        for basic types (e.g. Int, Char, Pointer), size == instanceSize */
    size: SizeT

    /// Human readable representation of the name of this class
    name: String

    /// Pointer to instance of super-class
    super: const Class

    /// Create a new instance of the object of type defined by this class
    alloc: final func ~_class -> Object {
        object := gc_malloc(instanceSize) as Object
        if(object) {
            object class = this
        }
        return object
    }

    inheritsFrom?: final func ~_class (T: Class) -> Bool {
        current := this
        while(current) {
            if(current == T) return true
            current = current super
        }
        false
    }

}

Array: cover from _lang_array__Array {
    length: extern SizeT
    data: extern Pointer

    free: extern(_lang_array__Array_free) func
}

None: class {
    init: func { }
}

/**
 * Pointer type
 */
Void: cover from void

Pointer: cover from Void* {
    toString: func -> String { "%p" format(this) }
}

Bool: cover from bool {
    toString: func -> String { this ? "true" : "false" }
}

/**
 * Comparable
 */
Comparable: interface {
    compareTo: func<T>(other: T) -> Int
}

/**
 * Closures
 */
Closure: cover {
    thunk: Pointer
    context: Pointer
    dispose: func {
      if (this context != null)
      {
        gc_free(this context)
        this context = null
        this thunk = null
      }
    }
}

/** An object storing a value and its class. */
Cell: class <T> {
    val: __onheap__ T

    init: func(=val)
    init: func ~noval

    set: func (=val)
    get: func -> T { val }

    free: override func {
        gc_free(this val)
        super()
    }
    // TODO: Move this to an extension in ooc-kean later
    toString: func -> String {
        match (this val) {
            case value: Bool => value toString()
            case value: Char => value toString()
            case value: Int => value toString()
            case value: Long => value toString()
            case value: Int64 => value toString()
            case value: UInt => value toString()
            case value: ULong => value toString()
            case value: UInt64 => value toString()
            case value: Float => "%.8f" formatFloat(value)
            case value: Double => "%.12f" formatDouble(value)
            case value: LDouble => "%.12f" formatLDouble(value)            
            case =>
                raise("[Cell] toString() is not implemented on the specified type")
        }
    }
}

operator [] <T> (c: Cell<T>, T: Class) -> T {
    if(!c T inheritsFrom?(T)) {
        Exception new(Cell, "Wants a %s, but got a %s" format(T name, c T name)) throw()
    }
    c val
}
