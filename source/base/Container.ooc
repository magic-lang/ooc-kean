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

Container: class <T> {
	blockFree: Bool {
		get
		set(value) { blockFree = value }
	}
	content: T
    set: func (=content)
    get: func -> T { content }
	init: func(=content)
	init: func ~withBlockFree(=content, blockFree: Bool) { this blockFree = blockFree }
	init: func ~novalue
	free: func {
		if (!this blockFree && T inheritsFrom?(Object) && this content != null) {
			obj := this content as Object
			obj free()
		}
		else
			gc_free(content)
		gc_free(this)
	}
}
