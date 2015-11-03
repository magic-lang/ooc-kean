use ooc-unit
use ooc-math
import math
import lang/IO

FloatMatrixTest: class extends Fixture {
	matrix := FloatMatrix new (3, 3)
	nonSquareMatrix := FloatMatrix new (IntSize2D new(2, 3))
	nullMatrix := FloatMatrix new(0, 0)
	precision := 1.0e-5f

	init: func {
		super ("FloatMatrix")

		this add("identity", func {
			checkAllElements(FloatMatrix identity(3), [1.0f, 0, 0, 0, 1.0f, 0, 0, 0, 1.0f])
		})

		this add("isSquare", func {
			expect(!nonSquareMatrix isSquare && matrix isSquare)
		})

		this add("order", func {
			expect(nonSquareMatrix order, is equal to(2))
		})

		this add("dimensions", func {
			expect(nonSquareMatrix dimensions width, is equal to(2))
			expect(nonSquareMatrix dimensions height, is equal to(3))
			expect(nullMatrix width, is equal to (0))
			expect(nullMatrix height, is equal to (0))
			expect(nullMatrix isNull)
		})

		this add("elements", func {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]), [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
		})

		this add("copy", func {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]) copy(), [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
			checkAllElements(createMatrix(2, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f]) copy(), [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f])
		})

		this add("trace", func {
			matrix = createMatrix(3, 3, [1.0f, 0, 0, 0, 2.0f, 0, 0, 0, 3.0f])
			expect(matrix trace(), is equal to(1.0f * 2.0f * 3.0f))
		})

		this add("transpose", func {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]) transpose(), [1.0f, -4.0f, 7.4f, -2.0f, 5.0f, -8.3f, 3.0f, -6.5f, 9.2f])
			checkAllElements(createMatrix(2, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f]) transpose(), [1.0f, -4.0f, -2.0f, 5.0f, 3.0f, -6.5f])
		})

		this add("swapRows", func {
			matrix = createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
			matrix swapRows(0, 1)
			checkAllElements(matrix, [-2.0f, 1.0f, 3.0f, 5.0f, -4.0f, -6.5f, -8.3f, 7.4f, 9.2f])
			matrix = createMatrix(2, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f])
			matrix swapRows(0, 1)
			checkAllElements(matrix, [-2.0f, 1.0f, 3.0f, 5.0f, -4.0f, -6.5f])
		})

		this add("setVertical", func {
			matrix = createMatrix(3, 3, [0, 0, 0, 0, 0, 0, 0, 0, 0])
			matrix setVertical(1, 0, FloatPoint3D new(1.0f, 2.0f, 3.0f))
			checkAllElements(matrix, [0, 0, 0, 1.0f, 2.0f, 3.0f, 0, 0, 0])
		})

		this add("multiplication", func {
			a := createMatrix(3, 3, [1.0f, 0, 0, 0, 0, 3.0f, 7.0f, 0, 0]) take()
			checkAllElements(a * a, [1.0f, 0, 0, 21.0f, 0, 0, 7.0f, 0, 0])
			b := createMatrix(2, 3, [1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f]) take()
			transpose := b transpose()
			checkAllElements(transpose * b, [14.0f, 32.0f, 32.0f, 77.0f])
		})

		this add("multiplication (scalar)", func {
			matrix = createMatrix(3, 3, [1.0f, 0, 0, 0, 2.0f, 0, 0, 0, 3.0f])
			checkAllElements(2.0f * matrix, [2.0f, 0, 0, 0, 4.0f, 0, 0, 0, 6.0f])
		})

		this add("addition", func {
			a := createMatrix(3, 3, [1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f, 9.0f]) take()
			b := createMatrix(3, 3, [9.0f, 8.0f, 7.0f, 6.0f, 5.0f, 4.0f, 3.0f, 2.0f, 1.0f]) take()
			checkAllElements(a + b, [10.0f, 10.0f, 10.0f, 10.0f, 10.0f, 10.0f, 10.0f, 10.0f, 10.0f])
			checkAllElements(a + b give() + a give(), [11.0f, 12.0f, 13.0f, 14.0f, 15.0f, 16.0f, 17.0f, 18.0f, 19.0f])
		})

		this add("subtraction", func {
			a := createMatrix(3, 3, [1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f, 9.0f]) take()
			b := createMatrix(3, 3, [9.0f, 8.0f, 7.0f, 6.0f, 5.0f, 4.0f, 3.0f, 2.0f, 1.0f])
			checkAllElements(a - b, [-8.0f, -6.0f, -4.0f, -2.0f, 0.0f, 2.0f, 4.0f, 6.0f, 8.0f])
			checkAllElements(a - a give(), [0, 0, 0, 0, 0, 0, 0, 0, 0])
		})

		this add("solver (square)", func {
			// Solve a * x = y
			a := createMatrix(5, 5, [1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 1.0f, 3.0f, 6.0f, 10.0f, 15.0f, 1.0f, 4.0f, 10.0f, 20.0f, 35.0f, 1.0f, 5.0f, 15.0f, 35.0f, 70.0f])
			y := createMatrix(1, 5, [-1.0f, 2.0f, -3.0f, 4.0f, 5.0f])
			x := a solve(y)
			checkAllElements(x, [-70.0f, 231.0f, -296.0f, 172.0f, -38.0f])
		})

		this add("solver (non-square)", func {
			a := createMatrix(2, 3, [2.0f, 0.0f, 4.0f, 2.0f, 4.0f, 6.0f])
			y := createMatrix(1, 3, [1.0f, -2.0f, 1.0f])
			x := a solve(y)
			checkAllElements(x, [1.0f, -0.5f])
		})

		this add("set and get", func {
			matrix = createMatrix(3, 3, [1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f])
			matrix[0, 0] = 42.0f
			expect(matrix[0, 0], is equal to(42.0f) within(this precision))
		})

		this add("print columns", func {
			A := createMatrix(3, 3, [1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f, 9.0f]) take()
			column := A getColumn(1)
			expect(column toString() == "4.00; 5.00; 6.00; ")
			expect(A toString() == "1.00, 4.00, 7.00; 2.00, 5.00, 8.00; 3.00, 6.00, 9.00; ")
		})

		this add("adjugate", func {
			matrix = createMatrix(3, 3, [1.f, 5.f, 3.f, 7.f, 6.f, 8.f, 9.f, 2.f, 4.f])
			checkAllElements(matrix adjugate(), [8.f, -14.f, 22.f, 44.f, -23.f, 13.f, -40.f, 43.f, -29.f])
		})

		this add("cofactors", func {
			matrix = createMatrix(3, 3, [1.f, 5.f, 3.f, 7.f, 6.f, 8.f, 9.f, 2.f, 4.f])
			checkAllElements(matrix cofactors(), [8.f, 44.f, -40.f, -14.f, -23.f, 43.f, 22.f, 13.f, -29.f])
		})

		this add("determinant", func {
			matrix = createMatrix(3, 3, [1.f, 5.f, 3.f, 7.f, 6.f, 8.f, 9.f, 2.f, 4.f])
			expect(matrix determinant(), is equal to(108.0f))
		})
	}

	createMatrix: func (width, height: Int, values: Float[]) -> FloatMatrix {
		result := FloatMatrix new(width, height) take()
		for (x in 0 .. width)
			for (y in 0 .. height)
				result[x, y] = values[x * height + y]
		result
	}

	checkAllElements: func (matrix: FloatMatrix, values: Float[]) {
		// Element order
		// 0 3
		// 1 4
		// 2 5
		for (x in 0 .. matrix dimensions width)
			for (y in 0 .. matrix dimensions height)
				expect(matrix[x, y], is equal to(values[x * matrix dimensions height + y]) within(this precision))
	}
}
FloatMatrixTest new() run()
