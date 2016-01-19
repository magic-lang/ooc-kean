use ooc-unit
use draw

RasterYuv420PlanarTest: class extends Fixture {
	inputPath := "test/draw/input/Flower.png"
	init: func {
		super("RasterYuv420Planar")
		this add("convert", func {
			imageYuvPlanar := RasterYuv420Planar open(this inputPath)
			imageYuvSemiplanar := RasterYuv420Semiplanar convertFrom(imageYuvPlanar)
			expect(imageYuvPlanar distance(imageYuvSemiplanar) < imageYuvPlanar width)
			imageYuvPlanarConverted := RasterYuv420Planar convertFrom(imageYuvSemiplanar)
			expect(imageYuvPlanar distance(imageYuvPlanarConverted) < imageYuvPlanar width)
			imageYuvPlanar referenceCount decrease()
			imageYuvSemiplanar referenceCount decrease()
			imageYuvPlanarConverted referenceCount decrease()
		})
		this add("save", func {
			outputPath := "test/draw/output/RasterYuv420Planar.png"
			image := RasterYuv420Planar open(this inputPath)
			image save(outputPath)
			image referenceCount decrease()
			outputPath free()
		})
	}
	free: override func {
		this inputPath free()
		super()
	}
}

RasterYuv420PlanarTest new() run() . free()
