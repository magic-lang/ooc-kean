use ooc-base
use ooc-math
use ooc-draw-gpu
use ooc-draw-gpu-pc
use ooc-draw
use ooc-opengl
use ooc-unit
import math
import lang/IO
import os/Time

GpuSurfaceTest: class extends Fixture {
	init: func {
		super("GpuSurfaceTest")
		sourceImage := RasterBgra open("test/draw/gpu/pc/input/quad1.png")
		sourceSize := sourceImage size
		this add("draw red quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_red.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantRed := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, quadrantRed, quadrantRed)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
			window free()
		})
		this add("draw yellow quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_yellow.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantYellow := IntBox2D new(viewport width / 2, viewport top, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, quadrantYellow, quadrantYellow)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
			window free()
		})
		this add("draw blue quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_blue.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantBlue := IntBox2D new(viewport left, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, quadrantBlue, quadrantBlue)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
			window free()
		})
		this add("draw green quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_green.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantGreen := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, quadrantGreen, quadrantGreen)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
			window free()
		})
		this add("draw combined quadrants", func {
			quadrantRed := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_red.png")
			quadrantYellow := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_yellow.png")
			quadrantBlue := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_blue.png")
			quadrantGreen := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_green.png")
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quad.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			redBox := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			yellowBox := IntBox2D new(viewport width / 2, viewport top, viewport width / 2, viewport height / 2)
			blueBox := IntBox2D new(viewport left, viewport height / 2, viewport width / 2, viewport height / 2)
			greenBox := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(quadrantRed, redBox, redBox)
			gpuImage canvas draw(quadrantYellow, yellowBox, yellowBox)
			gpuImage canvas draw(quadrantBlue, blueBox, blueBox)
			gpuImage canvas draw(quadrantGreen, greenBox, greenBox)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			quadrantRed free(); quadrantYellow free(); quadrantBlue free(); quadrantGreen free()
			correctImage free(); rasterFromGpu free(); gpuImage free()
			window free()
		})
		this add("draw red quadrant zoomed", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quadrant_red_zoom.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			redBox := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			yellowBox := IntBox2D new(viewport width / 2, viewport top, viewport width / 2, viewport height / 2)
			blueBox := IntBox2D new(viewport left, viewport height / 2, viewport width / 2, viewport height / 2)
			greenBox := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, redBox, viewport)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
			window free()
		})
		this add("draw quad 1:4 scale top left bottom right and 180deg x rotation", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/output/correct/quad_scaled_top_left_bottom_right_180deg_x_rotation.png")
			window := Window new(IntSize2D new(800, 800))
			gpuContext := window context
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantTopLeft := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			quadrantBottomRight := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas transform = FloatTransform3D createRotationX(Float toRadians(180.0f))
			gpuImage canvas draw(sourceImage, quadrantTopLeft)
			gpuImage canvas transform = FloatTransform3D createRotationX(Float toRadians(180.0f))
			gpuImage canvas draw(sourceImage, quadrantBottomRight)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
			window free()
		})
	}
}

GpuSurfaceTest new() run()
