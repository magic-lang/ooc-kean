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
use ooc-math
import structs/ArrayList
import Texture

TextureBin: class {
	monochrome: ArrayList<Texture>
	bgr: ArrayList<Texture>
	bgra: ArrayList<Texture>
	uv: ArrayList<Texture>

	init: func {
		monochrome = ArrayList<Texture> new()
		bgr = ArrayList<Texture> new()
		bgra = ArrayList<Texture> new()
		uv = ArrayList<Texture> new()
	}
	dispose: func {
		for(texture in this monochrome)
			texture dispose()
		for(texture in this bgr)
			texture dispose()
		for(texture in this bgra)
			texture dispose()
		for(texture in this uv)
			texture dispose()

		this monochrome clear()
		this bgr clear()
		this bgra clear()
		this uv clear()
	}

	add: func (texture: Texture) {
		match (texture type) {
			case TextureType monochrome =>
				this monochrome add(texture)
			case TextureType bgr =>
				this bgr add(texture)
			case TextureType bgra =>
				this bgra add(texture)
			case TextureType uv =>
				this uv add(texture)
		}
	}

	_search: func (width: UInt, height: UInt, arrayList: ArrayList<Texture>) -> Texture {
		result := null

		for (texture in arrayList) {
			if(texture width == width && texture height == height) {
				result = texture
				break
			}
		}
		if (result != null)
			arrayList remove(result)
		result
	}
	find: func (type: TextureType, width: UInt, height: UInt) -> Texture {
		result := null
		match (type) {
			case TextureType monochrome =>
				result = this _search(width, height, this monochrome)
			case TextureType bgr =>
				result = this _search(width, height, this bgr)
			case TextureType bgra =>
				result = this _search(width, height, this bgra)
			case TextureType uv =>
				result = this _search(width, height, this uv)
		}
		result
	}

}
