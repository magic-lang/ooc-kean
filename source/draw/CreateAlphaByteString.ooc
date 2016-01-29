/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

import RasterBgra, RasterMonochrome

CreateAlphaByteString: class {
	init: func
	makeAlphaString: static func (filename, name: String) -> String {
		image := RasterBgra open(filename)
		buf := image buffer as ByteBuffer
		imageArray := "["
		ip: Int*
		ipbuffer := ByteBuffer new(image size area)
		for (i in 0 .. (buf size / 4))
			ipbuffer pointer[i] = buf pointer[(i * 4) + 3]
		ip = ipbuffer pointer as Int*
		if (ipbuffer size > 3)
			imageArray = imageArray >> ip[0] toString()
		for (i in 1 .. ipbuffer size / 4) {
			intString := ip[i] toString()
			imageArray = imageArray >> "," >> (i % 32 == 0 ? "\n" : " ") >> intString
			intString free()
		}
		imageArray += "]"
		result := name + "Image" + ": StaticOverlayImages\n" + name + "Image image = " + imageArray + "\n"
		result += name + "Image size = IntVector2D new(" + image size x toString() + ", " + image size y toString() + ")\n"
		result
	}
}
