/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use geometry
use base
use concurrent
import GpuContext

GpuImage: abstract class extends Image {
	_context: GpuContext
	filter: Bool { get set }
	init: func (size: IntVector2D, =_context) { super(size) }
	resizeTo: override func (size: IntVector2D) -> This {
		result := this create(size) as This
		DrawState new(result) setInputImage(this) draw()
		result
	}
	copy: override func -> This { this resizeTo(this size) }
	distance: override func (other: Image) -> Float { Debug error("Using unimplemented function distance in GpuImage class"); 0.0f }
	upload: abstract func (image: RasterImage)
	toRaster: func -> RasterImage { this _context toRaster(this) }
	toRaster: func ~target (target: RasterImage) -> Promise { this _context toRaster(this, target) }
	toRasterAsync: func -> ToRasterFuture { this _context toRasterAsync(this) }
	toRasterDefault: abstract func -> RasterImage
	toRasterDefault: abstract func ~target (target: RasterImage)
}
