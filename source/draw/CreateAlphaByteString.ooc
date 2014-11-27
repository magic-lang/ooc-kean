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

use ooc-base

import RasterBgra, RasterMonochrome

CreateAlphaByteString: class {
	init: func ()
	makeAlphaString: static func (filename: String, name: String) -> String {
		image := RasterBgra open(filename)
		buf := image buffer as ByteBuffer
		result := name + "ImageArray := ["
		ip: Int*
		counter := 0
		tmp := ByteBuffer new(image size width * image size height)
		ipbuffer := ByteBuffer new(image size width * image size height)
		for (i in 0..(buf size / 4)) {
			ipbuffer pointer[i] = buf pointer[(i*4)+3]
		}
		ip = ipbuffer pointer as Int*
		for (i in 0..ipbuffer size / 4) {
			result = result + ip[i] toString() + ", "
			counter += 1
			if (i % 32 == 0) {
				result = result + "\n"
			}
		}
		result = result + "]"
		widthStr :=  name + "Width := " + image size width toString() + "\n"
		heightStr := name + "Height := " + image size height toString() + "\n"

		result = widthStr + heightStr + result
		result
	}
}
