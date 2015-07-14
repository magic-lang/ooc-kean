use ooc-unit
use ooc-math
import math
import lang/IO

QuaternionTest: class extends Fixture {
    quaternion0 := Quaternion new (33.0f, 10.0f, -12.0f, 54.5f)
    quaternion1 := Quaternion new (10.0f, 17.0f, -10.0f, 14.5f)
    quaternion2 := Quaternion new (43.0f, 27.0f, -22.0f, 69.0f)
    quaternion3 := Quaternion new (-750.25f, 1032.0f, 331.5f, 1127.5f)
    point0 := FloatPoint3D new (22.221f, -3.1f, 10.0f)
    point1 := FloatPoint3D new (12.221f, 13.1f, 20.0f)
    init: func () {
        super("Quaternion")
		tolerance := 0.000001f
		// Helper tests
		this add("withinTolerance", func() {
			expect(this isWithinTolerance(0.0f, 0.01f, 0.001f), is false)
			expect(this isWithinTolerance(0.0f, 0.001f, 0.01f))
			expect(this isWithinTolerance(-2.0f, -2.01f, -0.01f))
		})
		// Quaternion tests
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
            expect(this quaternion0 norm == 65.5991592f)
        })
        this add("ActionOnVector", func() {
            direction := FloatPoint3D new(1.0f, 1.0f, 1.0f)
			quaternion := Quaternion createRotation(this toRadians(120.0f), direction) 
            point1 := FloatPoint3D new(5.0f, 6.0f, 7.0f)
            point2 := FloatPoint3D new(7.0f, 5.0f, 6.0f)
            expect((quaternion * point1) distance(point2) == 0.0f)
        })
        this add("LogarithmExponential", func() {
            roll := this toRadians(20.0f)
            pitch := this toRadians(-30.0f)
            yaw := this toRadians(45.0f)
            quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
            expLog := quaternion calculateExponential() calculateLogarithm()
            logExp := quaternion calculateLogarithm() calculateExponential()
            expect(expLog real == quaternion real)
            expect(logExp real == quaternion real)
            expect(this isWithinTolerance(0, logExp imaginary distance(quaternion imaginary), tolerance))
            expect(this isWithinTolerance(0, expLog imaginary distance(quaternion imaginary), tolerance))
        })
		this add("Action", func() {
			roll := this toRadians(30.0f)
			pitch := this toRadians(20.0f)
			yaw := this toRadians(-45.0f)
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			expect(this isWithinTolerance(roll, quaternion rotationX, tolerance))
			expect(this isWithinTolerance(pitch, quaternion rotationY, tolerance))
			expect(this isWithinTolerance(yaw, quaternion rotationZ, tolerance))	
		})
		this add("RotationDirectionRepresentation1", func() {
			angle := this toRadians(30.0f)
			direction := FloatPoint3D new(1.0f, 4.0f, 7.0f)
			direction /= direction norm
			quaternion := Quaternion createRotation(angle, direction)
			expect(this isWithinTolerance(angle, quaternion rotation, tolerance))
		})
    }
	//
	// Helpers
	//
	isWithinTolerance: func (target, actualValue, tolerance: Float) -> Bool {
		actualValue >= target - tolerance abs() && actualValue <= target + tolerance abs()
	}
    toRadians: func (angle: Float) -> Float {
		Float pi / 180.0f * angle
	}
	toDegrees: func (angle: Float) -> Float {
		180.0f / Float pi * angle
	}
}

QuaternionTest new() run()
