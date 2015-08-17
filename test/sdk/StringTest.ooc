/*Foo: class {
	init: func
	__destroy__: func {
		s := "hej"
		s _buffer setCapacity(10)
//		t := s append("san")
		s free()
//		t free()
	}
}*/

//f := Foo new()
f := "hej"
f _buffer setCapacity(8)
f _buffer setCapacity(16)
f _buffer setCapacity(24000)
f free()
