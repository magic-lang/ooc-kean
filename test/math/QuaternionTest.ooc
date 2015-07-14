use ooc-unit
use ooc-math
import math
import lang/IO

QuaternionTest: class extends Fixture {
	quaternion0 := Quaternion new(33.0f, 10.0f, -12.0f, 54.5f)
	quaternion1 := Quaternion new(10.0f, 17.0f, -10.0f, 14.5f)
	quaternion2 := Quaternion new(43.0f, 27.0f, -22.0f, 69.0f)
	quaternion3 := Quaternion new(-750.25f, 1032.0f, 331.5f, 1127.5f)
	point0 := FloatPoint3D new(22.221f, -3.1f, 10.0f)
	point1 := FloatPoint3D new(12.221f, 13.1f, 20.0f)
	init: func () {
		super("Quaternion")
		tolerance := 0.000001f
		this add("addition", func() {
		    expect(this quaternion0 + this quaternion1 == this quaternion2)
		})
		this add("subtraction", func() {
		    expect(this quaternion0 - this quaternion0 == Quaternion new())
		})
		this add("multiplication", func() {
		    expect(this quaternion0 * this quaternion1 == this quaternion3)
		})
		this add("scalarMultiplication", func() {
		    expect((-1.0f) * this quaternion0 == -this quaternion0)
		})
		this add("norm", func() {
		    expect(this quaternion0 norm, is equal to(65.5991592f))
		})
		this add("ActionOnVector", func() {
				direction := FloatPoint3D new(1.0f, 1.0f, 1.0f)
				quaternion := Quaternion createRotation(Float toRadians(120.0f), direction)
				point1 := FloatPoint3D new(5.0f, 6.0f, 7.0f)
				point2 := FloatPoint3D new(7.0f, 5.0f, 6.0f)
				expect((quaternion * point1) distance(point2), is equal to(0.0f))
		})
		this add("LogarithmExponential", func() {
			roll := Float toRadians(20.0f)
			pitch := Float toRadians(-30.0f)
			yaw := Float toRadians(45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expLog := quaternion exponential logarithm
			logExp := quaternion logarithm exponential
			expect(expLog real, is equal to(quaternion real))
			expect(logExp real, is equal to(quaternion real))
			expect(logExp imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
			expect(expLog imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
		})
		this add("Action", func() {
			roll := Float toRadians(30.0f)
			pitch := Float toRadians(20.0f)
			yaw := Float toRadians(-45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expect(quaternion rotationX, is equal to(roll) within(tolerance))
			expect(quaternion rotationY, is equal to(pitch) within(tolerance))
			expect(quaternion rotationZ, is equal to(yaw) within(tolerance))
		})
		this add("RotationDirectionRepresentation1", func() {
			angle := Float toRadians(30.0f)
			direction := FloatPoint3D new(1.0f, 4.0f, 7.0f)
			direction /= direction norm
			quaternion := Quaternion createRotation(angle, direction)
			expect(quaternion rotation, is equal to(angle) within(tolerance))
		})
	}
}

QuaternionTest new() run()
