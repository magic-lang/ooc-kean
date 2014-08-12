use ooc-unit
use ooc-math
import math
import lang/IO
import IntSize2D
import FloatMatrix

FloatMatrixTest: class extends Fixture {

matrix := FloatMatrix new (3, 3)
matrixNonSquare := FloatMatrix new (IntSize2D new(2, 3))

	init: func () {
		super ("FloatMatrix")

		this add("identity", func() {
			checkAllElements(FloatMatrix identity(3), [1.0f, 0, 0, 0, 1.0f, 0, 0, 0, 1.0f])
		})

		this add("isSquare", func() {
			expect(matrixNonSquare isSquare == false && matrix isSquare == true)
		})

		this add("order", func() {
			expect(matrixNonSquare order == 2)
		})

		this add("dimensions", func() {
			expect(matrixNonSquare dimensions width == 2 && matrixNonSquare dimensions height == 3)
		})

		this add("elements", func() {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]), [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
		})

		this add("copy", func() {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]) copy(), [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
		})

		this add("transpose", func() {
			checkAllElements(createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f]) transpose(), [1.0f, -4.0f, 7.4f, -2.0f, 5.0f, -8.3f, 3.0f, -6.5f, 9.2f])
		})

		this add("swapRows", func() {
			matrix = createMatrix(3, 3, [1.0f, -2.0f, 3.0f, -4.0f, 5.0f, -6.5f, 7.4f, -8.3f, 9.2f])
			matrix swaprows(0,1)
			checkAllElements(matrix, [-2.0f, 1.0f, 3.0f, 5.0f, -4.0f, -6.5f, -8.3f, 7.4f, 9.2f])
		})

		this add("multiplication", func() {
			matrix = createMatrix(3, 3, [1.0f, 0, 0, 0, 0, 3.0f, 7.0f, 0, 0])
			checkAllElements(matrix * matrix, [1.0f,0,0, 21.0f,0,0, 7.0f,0,0])
		})

		this add("solver", func() {
			// Solve A * x = y
			A := createMatrix(5, 5, [ 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 1.0f, 3.0f, 6.0f, 10.0f, 15.0f, 1.0f, 4.0f, 10.0f, 20.0f, 35.0f, 1.0f, 5.0f, 15.0f, 35.0f, 70.0f ])
			y := createMatrix(1, 5, [ -1.0f, 2.0f, -3.0f, 4.0f, 5.0f])
			x := A solve(y)
			expect(x get(0, 0) == -70.0f)
			expect(x get(0, 1) == 231.0f)
			expect(x get(0, 2) == -296.0f)
			expect(x get(0, 3) == 172.0f)
			expect(x get(0, 4) == -38.0f)
		})
	}

	createMatrix: func (width: Int, height: Int, values: Float[]) -> FloatMatrix {
		result := FloatMatrix new(width, height)
		for (x in 0..width) {
			for (y in 0..height) {
				result set(x, y, values[x * height + y])
			}
		}
		result
	}


	checkAllElements: func (matrix: FloatMatrix, values: Float[]) -> Void {
		// 0 3 6
		// 1 4 7
		// 2 5 8
		expect(matrix get(0, 0) == values[0])
		expect(matrix get(0, 1) == values[1])
		expect(matrix get(0, 2) == values[2])
		expect(matrix get(1, 0) == values[3])
		expect(matrix get(1, 1) == values[4])
		expect(matrix get(1, 2) == values[5])
		expect(matrix get(2, 0) == values[6])
		expect(matrix get(2, 1) == values[7])
		expect(matrix get(2, 2) == values[8])
	}
}
FloatMatrixTest new() run()
