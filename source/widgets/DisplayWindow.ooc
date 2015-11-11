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

use ooc-draw
use ooc-math
import UnixWindow
import Win32DisplayWindow

DisplayWindow: abstract class {
	init: func (size: IntSize2D, title: String)
	draw: abstract func (image: Image)
	refresh: virtual func
	create: static func (size: IntSize2D, title: String) -> This {
		version(unix || apple)
			return UnixWindow create(size, title)
		version(windows)
			return Win32DisplayWindow new(size, title)
		raise("Platform not supported (DisplayWindow)")
		null
	}
}
