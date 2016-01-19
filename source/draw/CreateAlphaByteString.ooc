/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
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
