use base
use collections

Application: class {
	_arguments := VectorList<Text> new()
	_name: Text
	name ::= this _name
	arguments ::= this _arguments
	init: func (argc: Int, argv: CString*) {
		this _name = Text new(argv[0])
		for (i in 1 .. argc)
			this _arguments add(Text new(argv[i]))
	}
	free: override func {
		this _arguments free()
		super()
	}
	processEvents: virtual func
}
