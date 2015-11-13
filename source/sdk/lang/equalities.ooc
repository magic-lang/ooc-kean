// The following functions were moved from HashMap.ooc

getStandardEquals: func <T> (T: Class) -> Func <T> (T, T) -> Bool {
    if(T == String) {
        stringEquals
    } else if(T == CString) {
        cstringEquals
    } else if(T size == Pointer size) {
        pointerEquals
    } else if(T size == UInt size) {
        intEquals
    } else if(T size == Char size) {
        charEquals
    } else {
        genericEquals
    }
}

stringEquals: func <K> (k1, k2: K) -> Bool {
    assert(K == String)
    k1 as String equals?(k2 as String)
}

cstringEquals: func <K> (k1, k2: K) -> Bool {
    k1 as CString == k2 as CString
}

pointerEquals: func <K> (k1, k2: K) -> Bool {
    k1 as Pointer == k2 as Pointer
}

intEquals: func <K> (k1, k2: K) -> Bool {
    k1 as Int == k2 as Int
}

charEquals: func <K> (k1, k2: K) -> Bool {
    k1 as Char == k2 as Char
}

/** used when we don't have a custom comparing function for the key type */
genericEquals: func <K> (k1, k2: K) -> Bool {
    // FIXME rock should turn == between generic vars into a memcmp itself
    memcmp(k1, k2, K size) == 0
}
