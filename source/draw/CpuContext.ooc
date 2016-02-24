/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry

CpuContext: class extends DrawContext {
	init: func
	createMonochrome: override func (size: IntVector2D) -> RasterMonochrome { RasterMonochrome new(size) }
	createRgb: override func (size: IntVector2D) -> RasterRgb { RasterRgb new(size) }
	createRgba: override func (size: IntVector2D) -> RasterRgba { RasterRgba new(size) }
	createUv: override func (size: IntVector2D) -> RasterUv { RasterUv new(size) }
	createImage: override func (rasterImage: RasterImage) -> RasterImage { rasterImage copy() }
	createYuv420Semiplanar: override func (size: IntVector2D) -> RasterYuv420Semiplanar { RasterYuv420Semiplanar new(size) }
	createYuv420Semiplanar: override func ~fromImages (y, uv: Image) -> RasterYuv420Semiplanar { RasterYuv420Semiplanar new(y as RasterMonochrome, uv as RasterUv) }
	createYuv420Semiplanar: override func ~fromRaster (raster: RasterYuv420Semiplanar) -> RasterYuv420Semiplanar { raster copy() }
	update: override func
}
