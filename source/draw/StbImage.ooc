/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use base
use geometry
include ./stb_image/stb_image
include ./stb_image/stb_image_write

StbImage: class {
	free: extern (stbi_image_free) static func (data: Byte*)
	_load: extern (stbi_load) static func (filename: CString, x, y, n: Int*, req_comp: Int) -> Byte*
	load: static func (filename: String, requiredComponents: Int = 0) -> (ByteBuffer, IntVector2D, Int) {
		x, y, imageComponents: Int
		data := This _load (filename toCString(), x&, y&, imageComponents&, requiredComponents)
		if (data == null)
			Debug error("Failed to load image: " + filename, This)
		buffer := ByteBuffer new(data as Byte*, x * y * (requiredComponents != 0 ? requiredComponents : imageComponents), true)
		(buffer, IntVector2D new(x, y), imageComponents)
	}
	writePng: extern (stbi_write_png) static func (filename: const CString, w, h, comp: Int, data: const Pointer, stride_in_bytes: Int) -> Int
	failureReason: extern (stbi_failure_reason) static func -> const CString
}
