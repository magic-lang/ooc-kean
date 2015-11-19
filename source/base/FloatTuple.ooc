import Debug

FloatTuple2: cover {
	a, b: Float
	init: func@(=a, =b)
	operator [] (index: Int) -> Float {
		match (index) {
			case 0 => this a
			case 1 => this b
			case => Debug raise("Index out of bounds in FloatTuple2"); 0
		}
	}
}

FloatTuple3: cover {
	a, b, c: Float
	init: func@(=a, =b, =c)
	operator [] (index: Int) -> Float {
		match (index) {
			case 0 => this a
			case 1 => this b
			case 2 => this c
			case => Debug raise("Index out of bounds in FloatTuple3"); 0
		}
	}
}

FloatTuple4: cover {
	a, b, c, d: Float
	init: func@(=a, =b, =c, =d)
	operator [] (index: Int) -> Float {
		match (index) {
			case 0 => this a
			case 1 => this b
			case 2 => this c
			case 3 => this d
			case => Debug raise("Index out of bounds in FloatTuple4"); 0
		}
	}
}
