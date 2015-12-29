import io/BufferReader

// Used to turn `lang_Exception__Exception_throw_impl` into `Exception throw_impl() in lang/Exception`
Demangler: class {
	demangle: static func (s: String) -> FullSymbol {
		result := FullSymbol new(s)
		if (s contains?("__")) {
			reader := BufferReader new(s)

			while (reader hasNext?()) {
				c := reader read()
				match c {
					case '_' =>
						if (reader peek() == '_') {
							// it's the end! skip that second underscore
							reader read()
							break
						} else
							result package += '/'
					case =>
						// accumulate
						result package += c
				}
			}

			if (reader peek() upper?()) {
				while (reader hasNext?()) {
					c := reader read()
					match c {
						case '_' =>
							break
						case =>
							result type += c
					}
				}
			}

			result name = reader readAll()
		}
		result
	}
}

FullSymbol: class {
	mangled: String
	package := ""
	type := ""
	name := ""

	init: func (=mangled) {
		name = mangled
	}
	fullName: String { get {
		match (type size) {
			case 0 =>
				name
			case =>
				"%s %s" format(type, name)
		}
	} }
}
