use ooc-unit
use ooc-math
use ooc-base
import math
import lang/IO

QuaternionTest: class extends Fixture {
	Debug initialize(func (s: String) { println(s) })
	quaternion0 := Quaternion new(33.0f, 10.0f, -12.0f, 54.5f)
	quaternion1 := Quaternion new(10.0f, 17.0f, -10.0f, 14.5f)
	quaternion2 := Quaternion new(43.0f, 27.0f, -22.0f, 69.0f)
	quaternion3 := Quaternion new(-750.25f, 1032.0f, 331.5f, 1127.5f)
	quaternion4 := Quaternion new(10.0f, 17.0f, -10.0f, 14.5f)
	quaternion5 := Quaternion new(1.0f, 2.0f, 3.0f, 4.0f)
	quaternion6 := Quaternion new(-1.0f, -2.0f, -3.0f, -4.0f)
	quaternion7 := Quaternion new(1.0f, 0.0f, 0.0f, 0.0f)
	quaternion8 := Quaternion new(0.1f, 0.0f, 0.0f, 1.0f)
	quaternion9 := Quaternion new(0.2f, 0.0f, 1.0f, 0.0f)
	quaternion10 := Quaternion new(0.12f, 0.4472136f, 0.8366f, 0.316227766f)
	point0 := FloatPoint3D new(22.221f, -3.1f, 10.0f)
	point1 := FloatPoint3D new(12.221f, 13.1f, 20.0f)
	init: func {
		super("Quaternion")
		tolerance := 0.0001f
		this add("comparison", func {
			expect(this quaternion1 == this quaternion4)
			expect(this quaternion2 == this quaternion3, is false)
			expect(this quaternion3 != this quaternion4)
			expect(this quaternion1 != this quaternion4, is false)
			expect(this quaternion0 <= this quaternion0)
			expect(this quaternion0 >= this quaternion0)
			expect(this quaternion6 < this quaternion5)
			expect(this quaternion5 > this quaternion6)
		})
		this add("indexOutOfBounds", func {
			indexOutOfBounds := false
			try {
				this quaternion0[4] == 0.0f
			}
			catch (e: Exception) {
				indexOutOfBounds = true
			}
			expect(indexOutOfBounds)
		})
		this add("indexing", func {
			expect(this quaternion0[0] == 33.0f)
			expect(this quaternion0[1] == 10.0f)
			expect(this quaternion0[2] == -12.0f)
			expect(this quaternion0[3] == 54.5f)
		})
		this add("addition", func {
			expect(this quaternion0 + this quaternion1 == this quaternion2)
		})
		this add("subtraction", func {
			expect(this quaternion0 - this quaternion0 == Quaternion new())
		})
		this add("multiplication", func {
			expect(this quaternion0 * this quaternion1 == this quaternion3)
		})
		this add("scalarMultiplication", func {
			expect((-1.0f) * this quaternion0 == -this quaternion0)
		})
		this add("norm", func {
			expect(this quaternion0 norm, is equal to(65.5991592f))
		})
		this add("conjugate", func {
			conjugate := quaternion5 conjugate
			expect(conjugate w == quaternion5 w)
			expect(conjugate[1] == -quaternion5[1])
			expect(conjugate[2] == -quaternion5[2])
			expect(conjugate[3] == -quaternion5[3])
		})
		this add("normalized", func {
			normalized := quaternion0 normalized
			expect(Quaternion new(1, 0, 0, 0) normalized == Quaternion identity)
			expect(normalized w, is equal to(0.5030552f) within(tolerance))
			expect(normalized x, is equal to(0.1524409f) within(tolerance))
			expect(normalized y, is equal to(-0.1829291f) within(tolerance))
			expect(normalized z, is equal to(0.8308033f) within(tolerance))
		})
		this add("toArray", func {
			source := [1.0f, 2.0f, 3.0f, 4.0f]
			quaternion := Quaternion new(source)
			dest := quaternion toArray()
			expect(source[0] == dest[0])
			expect(source[1] == dest[1])
			expect(source[2] == dest[2])
			expect(source[3] == dest[3])
			source free()
			dest free()
		})
		this add("actionOnVector", func {
			direction := FloatPoint3D new(1.0f, 1.0f, 1.0f)
			quaternion := Quaternion createRotation(Float toRadians(120.0f), direction)
			point1 := FloatPoint3D new(5.0f, 6.0f, 7.0f)
			point2 := FloatPoint3D new(7.0f, 5.0f, 6.0f)
			expect((quaternion * point1) distance(point2), is equal to(0.0f))
		})
		this add("action", func {
			roll := Float toRadians(30.0f)
			pitch := Float toRadians(20.0f)
			yaw := Float toRadians(-45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expect(quaternion rotationX, is equal to(roll) within(tolerance))
			expect(quaternion rotationY, is equal to(pitch) within(tolerance))
			expect(quaternion rotationZ, is equal to(yaw) within(tolerance))
		})
		this add("rotationDirectionRepresentation1", func {
			angle := Float toRadians(30.0f)
			direction := FloatPoint3D new(1.0f, 4.0f, 7.0f)
			direction /= direction norm
			quaternion := Quaternion createRotation(angle, direction)
			expect(quaternion rotation, is equal to(angle) within(tolerance))
		})
		this add("rollPitchYaw", func {
			for (r in -180 .. 180) {
				for (p in -90 .. 90)
					for (y in -180 .. 180)
						if (p != 90 && p != -90) {
							roll := Float toRadians(r)
							pitch := Float toRadians(p)
							yaw := Float toRadians(y)
							quaternion0 := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
							quaternion1 := Quaternion createRotationZ(quaternion0 rotationZ) * Quaternion createRotationY(quaternion0 rotationY) * Quaternion createRotationX(quaternion0 rotationX)
							// HACK: rock fails this: expect(this angleDistance(quaternion0 rotationX, quaternion1 rotationX), is equal to(0.0f) within(tolerance))
							distX := this angleDistance(quaternion0 rotationX, quaternion1 rotationX)
							distY := this angleDistance(quaternion0 rotationY, quaternion1 rotationY)
							distZ := this angleDistance(quaternion0 rotationZ, quaternion1 rotationZ)
							expect(distX > 0.0f - tolerance && distX < 0.0f + tolerance)
							expect(distY > 0.0f - tolerance && distY < 0.0f + tolerance)
							expect(distZ > 0.0f - tolerance && distZ < 0.0f + tolerance)
						}
				r += 30
			}
		})
		this add("exponentialLogarithm", func {
			roll := Float toRadians(20.0f)
			pitch := Float toRadians(-30.0f)
			yaw := Float toRadians(45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expLog := quaternion exponential logarithm
			expect(expLog real, is equal to(quaternion real) within(tolerance))
		})
		this add("logarithmExponential", func {
			roll := Float toRadians(20.0f)
			pitch := Float toRadians(-30.0f)
			yaw := Float toRadians(45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			logExp := quaternion logarithm exponential
			expect(logExp real, is equal to(quaternion real) within(tolerance))
		})
		this add("exponentialLogarithmDistance", func {
			roll := Float toRadians(20.0f)
			pitch := Float toRadians(-30.0f)
			yaw := Float toRadians(45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expLog := quaternion exponential logarithm
			expect(expLog imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
		})
		this add("logarithmExponentialDistance", func {
			roll := Float toRadians(20.0f)
			pitch := Float toRadians(-30.0f)
			yaw := Float toRadians(45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			logExp := quaternion exponential logarithm
			expect(logExp imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
		})
		this add("toFloatTransform3D_1", func {
			// Results from http://www.energid.com/resources/quaternion-calculator/
			float3DTransform := Quaternion new(0.1f, 1.0f, 0.0f, 0.0f) toFloatTransform3D()
			expect(float3DTransform a, is equal to(1.0f) within(tolerance))
			expect(float3DTransform b, is equal to(0.0f) within(tolerance))
			expect(float3DTransform c, is equal to(0.0f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(0.0f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.980198f) within(tolerance))
			expect(float3DTransform g, is equal to(0.1980198f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.0f) within(tolerance))
			expect(float3DTransform j, is equal to(-0.1980198f) within(tolerance))
			expect(float3DTransform k, is equal to(-0.980198f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("toFloatTransform3D_2", func {
			float3DTransform := Quaternion new(0.543f, 0.123f, 0.325f, 0.876f) toFloatTransform3D()
			expect(float3DTransform a, is equal to(-0.475937f) within(tolerance))
			expect(float3DTransform b, is equal to(0.871770f) within(tolerance))
			expect(float3DTransform c, is equal to(-0.116193f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(-0.736603f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.322940f) within(tolerance))
			expect(float3DTransform g, is equal to(0.594244f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.480521f) within(tolerance))
			expect(float3DTransform j, is equal to(0.368411f) within(tolerance))
			expect(float3DTransform k, is equal to(0.795848f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("toFloatTransform3D_3", func {
			float3DTransform := quaternion3 toFloatTransform3D()
			expect(float3DTransform a, is equal to(0.082003f) within(tolerance))
			expect(float3DTransform b, is equal to(-0.334856f) within(tolerance))
			expect(float3DTransform c, is equal to(0.938694f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(0.789629f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.552837f) within(tolerance))
			expect(float3DTransform g, is equal to(-0.266192f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.608081f) within(tolerance))
			expect(float3DTransform j, is equal to(0.763048f) within(tolerance))
			expect(float3DTransform k, is equal to(0.219078f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("fromFloatTransform3D: identity", func {
			// Identity matrix
			matrix := FloatTransform3D new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w == 1.0f)
			expect(quaternion x == 0.0f)
			expect(quaternion y == 0.0f)
			expect(quaternion z == 0.0f)
		})
		this add("fromFloatTransform3D: trace > 0.0f", func {
			matrix := FloatTransform3D new(1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.866025f) within(tolerance))
			expect(quaternion x, is equal to(0.288675f) within(tolerance))
			expect(quaternion y, is equal to(0.577350f) within(tolerance))
			expect(quaternion z, is equal to(0.0f) within(tolerance))
		})
		this add("fromFloatTransform3D: matrix a > matrix e && matrix a > matrix i", func {
			matrix := FloatTransform3D new(1.0f, 1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 0.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.0f) within(tolerance))
			expect(quaternion x, is equal to(1.0f) within(tolerance))
			expect(quaternion y, is equal to(0.5f) within(tolerance))
			expect(quaternion z, is equal to(-0.25f) within(tolerance))
		})
		this add("fromFloatTransform3D: matrix e > matrix i", func {
			matrix := FloatTransform3D new(0.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.707106f) within(tolerance))
			expect(quaternion x, is equal to(0.707106f) within(tolerance))
			expect(quaternion y, is equal to(0.707106f) within(tolerance))
			expect(quaternion z, is equal to(0.353553f) within(tolerance))
		})
		this add("fromFloatTransform3D: else", func {
			matrix := FloatTransform3D new(-1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(-0.35355339059327373f) within(tolerance))
			expect(quaternion x, is equal to(-0.353553f) within(tolerance))
			expect(quaternion y, is equal to(-0.353553f) within(tolerance))
			expect(quaternion z, is equal to(0.707106f) within(tolerance))
		})
		this add("fromFloatTransform3D_1", func {
			matrix := quaternion0 toFloatTransform3D()
			quaternion := Quaternion new(matrix)
			normalized := quaternion0 normalized
			expect(quaternion w, is equal to(normalized w) within(tolerance))
			expect(quaternion x, is equal to(normalized x) within(tolerance))
			expect(quaternion y, is equal to(normalized y) within(tolerance))
			expect(quaternion z, is equal to(normalized z) within(tolerance))
		})
		this add("fromFloatTransform3D_2", func {
			matrix := quaternion3 toFloatTransform3D()
			quaternion := Quaternion new(matrix)
			normalized := quaternion3 normalized
			expect(quaternion w, is equal to(normalized w) within(tolerance))
			expect(quaternion x, is equal to(normalized x) within(tolerance))
			expect(quaternion y, is equal to(normalized y) within(tolerance))
			expect(quaternion z, is equal to(normalized z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_1", func {
			interpolated := quaternion8 sphericalLinearInterpolation(quaternion9, 0.5f)
			expect(interpolated w, is equal to(0.210042f) within(tolerance))
			expect(interpolated x, is equal to(0.0f) within(tolerance))
			expect(interpolated y, is equal to(0.700140f) within(tolerance))
			expect(interpolated z, is equal to(0.700140f) within(tolerance))
		})
		this add("sphericalLinearInterpolation_2", func {
			interpolated := quaternion10 sphericalLinearInterpolation(quaternion8, 0.0f)
			expect(interpolated w, is equal to(quaternion10 w) within(tolerance))
			expect(interpolated x, is equal to(quaternion10 x) within(tolerance))
			expect(interpolated y, is equal to(quaternion10 y) within(tolerance))
			expect(interpolated z, is equal to(quaternion10 z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_3", func {
			interpolated := quaternion10 sphericalLinearInterpolation(quaternion8, 1.0f)
			expect(interpolated w, is equal to(quaternion8 w) within(tolerance))
			expect(interpolated x, is equal to(quaternion8 x) within(tolerance))
			expect(interpolated y, is equal to(quaternion8 y) within(tolerance))
			expect(interpolated z, is equal to(quaternion8 z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_4", func {
			interpolated := quaternion10 sphericalLinearInterpolation(quaternion8, 0.24f)
			expect(interpolated w, is equal to(0.13351797f) within(tolerance))
			expect(interpolated x, is equal to(0.38223242f) within(tolerance))
			expect(interpolated y, is equal to(0.71509135f) within(tolerance))
			expect(interpolated z, is equal to(0.57982165f) within(tolerance))
		})
		this add("sphericalLinearInterpolation_5", func {
			interpolated := quaternion10 sphericalLinearInterpolation(quaternion8, 0.9f)
			expect(interpolated w, is equal to(0.11061810f) within(tolerance))
			expect(interpolated x, is equal to(0.05838604f) within(tolerance))
			expect(interpolated y, is equal to(0.10923036f) within(tolerance))
			expect(interpolated z, is equal to(0.99080002f) within(tolerance))
		})
	}
	angleDistance: func (a, b: Float) -> Float {
		(FloatPoint2D polar(1, a) - FloatPoint2D polar(1, b)) norm
	}
}

QuaternionTest new() run()
