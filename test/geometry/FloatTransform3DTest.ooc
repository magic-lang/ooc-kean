use unit
use geometry

FloatTransform3DTest: class extends Fixture {
	precision := 1.0e-5f
	transform0 := FloatTransform3D new(-1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	transform1 := FloatTransform3D new(-1, 2, 3, 4, 5, 6, 7, 8, -5, 10, 11, 12)
	transform2 := FloatTransform3D new(30, 32, 36, 58, 81, 96, -10, 14, 24, 128, 182, 216)
	transform3 := FloatTransform3D new(0.5f, 1, -0.5f, 1, -5, 3, -0.5f, 3.66666666666666f, -2.16666666666667f, 0, 1, -2)
	transform4 := FloatTransform3D new(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120)
	point0 := FloatPoint3D new(34, 10, 30)
	point1 := FloatPoint3D new(226, 369, 444)
	init: func {
		super("FloatTransform3D")
		this add("equality", func {
			transform := FloatTransform3D new()
			expect(this transform0 == this transform0, is true)
			expect(this transform0 == this transform1, is false)
			expect(this transform0 == transform, is false)
			expect(transform == transform, is true)
			expect(transform == this transform0, is false)
		})
		this add("determinant", func {
			expect(transform0 determinant, is equal to(6.0f) within(this precision))
			transform := FloatTransform3D new()
			expect(transform determinant, is equal to(0.0f) within(this precision))
		})
		this add("inverse transform", func {
			transform := FloatTransform3D new(0.035711678574190f, 0.849129305868777f, 0.933993247757551f, 0.678735154857773f, 0.757740130578333f, 0.743132468124916f, 0.392227019534168f, 0.655477890177557f, 0.171186687811562f, 0.706046088019609f, 0.031832846377421f, 0.276922984960890f)
			transformInverseCorrect := FloatTransform3D new(-1.304260393891308f, 1.703723523873863f, -0.279939209639535f, 0.639686782697661f, -1.314595978968342f, 2.216619899417434f, 0.538976631155336f, 1.130007253038916f, -2.004511083979782f, 0.751249880258891f, -1.473984978790241f, 0.682183855876876f)
			transformInverse := transform inverse
			expect(transformInverse a, is equal to(transformInverseCorrect a) within(this precision))
			expect(transformInverse b, is equal to(transformInverseCorrect b) within(this precision))
			expect(transformInverse c, is equal to(transformInverseCorrect c) within(this precision))
			expect(transformInverse d, is equal to(transformInverseCorrect d) within(this precision))
			expect(transformInverse e, is equal to(transformInverseCorrect e) within(this precision))
			expect(transformInverse f, is equal to(transformInverseCorrect f) within(this precision))
			expect(transformInverse g, is equal to(transformInverseCorrect g) within(this precision))
			expect(transformInverse h, is equal to(transformInverseCorrect h) within(this precision))
			expect(transformInverse i, is equal to(transformInverseCorrect i) within(this precision))
			expect(transformInverse j, is equal to(transformInverseCorrect j) within(this precision))
			expect(transformInverse k, is equal to(transformInverseCorrect k) within(this precision))
			expect(transformInverse l, is equal to(transformInverseCorrect l) within(this precision))
		})
		this add("multiplication transform - transform", func {
			result := this transform0 * this transform1
			expect(result == this transform2)
		})
		this add("multiplication transform - point", func {
			result := this transform0 * this point0
			expect(result == this point1)
		})
		this add("create zero transform", func {
			transform := FloatTransform3D new()
			expect(transform a, is equal to(0.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(0.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))
		})
		this add("create identity", func {
			transform := FloatTransform3D identity
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(1.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("scale", func {
			scale := 20.0f
			transform := FloatTransform3D createScaling(scale)
			transform = transform scale(1.0f / scale)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(1.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("translate", func {
			xDelta := 40.0f
			yDelta := -40.0f
			zDelta := 30.0f
			transform := FloatTransform3D createTranslation(xDelta, yDelta, zDelta)
			transform = transform translate(-xDelta, -yDelta, -zDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(1.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("create rotation x", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationX(angle)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(angle cos()) within(this precision))
			expect(transform g, is equal to(angle sin()) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to((-angle) sin()) within(this precision))
			expect(transform k, is equal to(angle cos()) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("create rotation y", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationY(angle)
			expect(transform a, is equal to(angle cos()) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(-angle sin()) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(angle sin()) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(angle cos()) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("create rotation z", func {
			angle := Float pi / 9.0f
			transform := FloatTransform3D createRotationZ(angle)
			expect(transform a, is equal to(angle cos()) within(this precision))
			expect(transform b, is equal to(angle sin()) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(-angle sin()) within(this precision))
			expect(transform f, is equal to(angle cos()) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(1.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("create scale", func {
			scale := 20.0f
			transform := FloatTransform3D createScaling(scale, scale, scale)
			expect(transform a, is equal to(scale) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(scale) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(scale) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(0.0f) within(this precision))
			expect(transform n, is equal to(0.0f) within(this precision))
			expect(transform o, is equal to(0.0f) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("create translation", func {
			xDelta := 40.0f
			yDelta := -40.0f
			zDelta := 30.0f
			transform := FloatTransform3D createTranslation(xDelta, yDelta, zDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))

			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))

			expect(transform i, is equal to(0.0f) within(this precision))
			expect(transform j, is equal to(0.0f) within(this precision))
			expect(transform k, is equal to(1.0f) within(this precision))
			expect(transform l, is equal to(0.0f) within(this precision))

			expect(transform m, is equal to(xDelta) within(this precision))
			expect(transform n, is equal to(yDelta) within(this precision))
			expect(transform o, is equal to(zDelta) within(this precision))
			expect(transform p, is equal to(1.0f) within(this precision))
		})
		this add("get scalingX", func {
			scale := this transform0 scalingX
			expect(scale, is equal to(3.7416575f) within(this precision))
		})
		this add("get scalingY", func {
			scale := this transform0 scalingY
			expect(scale, is equal to(8.77496433f) within(this precision))
		})
		this add("get scalingZ", func {
			scale := this transform0 scalingZ
			expect(scale, is equal to(13.9283886f) within(this precision))
		})
		this add("get scaling", func {
			scale := this transform0 scaling
			expect(scale as Float, is equal to(8.8150f) within(this precision))
		})
		this add("get translation", func {
			translation := this transform0 translation
			expect(translation x, is equal to(10.0f) within(this precision))
			expect(translation y, is equal to(11.0f) within(this precision))
			expect(translation z, is equal to(12.0f) within(this precision))
		})
		this add("casting", func {
			value := "10.00000000, 40.00000000, 70.00000000, 100.00000000\n" + \
				"20.00000000, 50.00000000, 80.00000000, 110.00000000\n" + \
				"30.00000000, 60.00000000, 90.00000000, 120.00000000\n" + \
				"0.00000000, 0.00000000, 0.00000000, 1.00000000"
			expect(this transform4 toString(), is equal to(value))
		})
		this add("toText", func {
			text := FloatTransform3D new(1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3) toText() take()
			expect(text, is equal to(t"1.00, 4.00, 7.00, 1.00\n2.00, 5.00, 8.00, 2.00\n3.00, 6.00, 9.00, 3.00\n0.00, 0.00, 0.00, 1.00"))
			text free()
		})
	}
}

FloatTransform3DTest new() run() . free()
