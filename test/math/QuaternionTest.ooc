use ooc-unit
use ooc-math
import math
import lang/IO

QuaternionTest: class extends Fixture {
    quaternion0 := Quaternion new (33, 10, -12, 54.5f)
    quaternion1 := Quaternion new (10, 17, -10, 14.5f)
    quaternion2 := Quaternion new (43, 27, -22, 69)
    quaternion3 := Quaternion new (-750.25f, 1032, 331.5, 1127.5f)
    point0 := FloatPoint3D new (22.221f, -3.1f, 10)
    point1 := FloatPoint3D new (12.221f, 13.1f, 20)

    init: func () {
        super("Quaternion")
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
            expect(this quaternion0 norm() == 65.5991592f)
        })
        this add("ActionOnVector", func() {
            direction := FloatPoint3D new(1, 1, 1)
            quaternion := Quaternion createRotation(this toRadians(120), direction)
            point1 := FloatPoint3D new(5, 6, 7)
            point2 := FloatPoint3D new(7, 5, 6)
            expect((quaternion * point1) distance(point2) == 0.0f)
        })
    }
    // TODO: Migrate to better place?
	toRadians: func(angle: Float) -> Float {
		Float pi / 180.0f * angle
	}
	// TODO: Migrate to better place?
	toDegrees: func(angle: Float) -> Float {
		180.0f / Float pi * angle
	}
}

QuaternionTest new() run()
