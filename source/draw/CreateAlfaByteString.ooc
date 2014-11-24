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

CreateAlfaByteString: class {
	init: func ()
	makeAlfaString: static func (fileName: String) -> String {
		image := RasterBgra open(fileName)
		buf := image buffer as ByteBuffer
		result := "imageArray := ["
		ip: Int*
		tmp := ByteBuffer new(image size width * image size height)
		ipbuffer := ByteBuffer new(image size width * image size height)
		for (i in 0..(buf size / 4)) {
			ipbuffer pointer[i] = buf pointer[(i*4)+3]
		}
		ip = ipbuffer pointer as Int*
		for (i in 0..ipbuffer size / 4) {
			result = result + ip[i] toString() + ", "
			if (i % 32 == 0) {
				result = result + "\n"
			}
		}
		result = result + "]"
		result
	}
}
