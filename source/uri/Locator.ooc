/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use uri
use collections

Locator: class {
	_scheme: Text
	_authority: Authority
	_path: VectorList<Text>
	_query: Query
	_fragment: Text
	scheme ::= this _scheme take()
	authority ::= this _authority
	path: VectorList<Text> { get {
		result: VectorList<Text>
		if (this _path != null) {
			result = VectorList<Text> new()
			for (i in 0 .. this _path count)
				result add(this _path[i] take())
		}
		result
	}}
	query ::= this _query
	fragment ::= this _fragment take()

	init: func(=_scheme, =_authority, =_path, =_query, =_fragment)
	free: override func {
		this _scheme free(Owner Receiver)
		if (this _authority != null)
			this _authority free()
		if (this _path != null) {
			for (i in 0 .. this _path count)
				this _path[i] free(Owner Receiver)
			this _path free()
		}
		if (this _query != null)
			this _query free()
		this _fragment free(Owner Receiver)
		super()
	}
	toText: func -> Text {
		result := Text new()
		if (!this scheme isEmpty)
			result += this scheme + t"://"
		if (this authority != null)
			result += this authority toText()
		if (this _path != null)
			for (i in 0 .. this _path count)
				result += t"/" + this _path[i] take()
		if (this query != null)
			result += t"?" + this query toText()
		if (!this fragment isEmpty)
			result += t"#" + this fragment
		result
	}
	parse: static func(data: Text) -> This {
		result: This
		d := data take()
		if (!d isEmpty) {
			splitted := d split(t"://")
			newScheme := splitted count > 1 ? splitted remove(0) : Text empty
			d = splitted remove()
			splitted free()
			index: Int
			newFragment := Text empty
			if (!d isEmpty && (index = d lastIndexOf('#')) > -1) {
				newFragment = d slice(index + 1)
				d = d slice(0, index)
			}
			newQuery: Query
			if (!d isEmpty && (index = d lastIndexOf('?')) > -1) {
				newQuery = Query parse(d slice(index + 1))
				d = d slice(0, index)
			}
			newPath: VectorList<Text>
			if (!d isEmpty && (index = d find(t"/")) > -1) {
				newPath = d slice(index + 1) split(t"/")
				for (i in 0 .. newPath count)
					newPath[i] = newPath[i] take()
				d = d slice(0, index)
			}
			newAuthority: Authority
			if (!d isEmpty)
				newAuthority = Authority parse(d)
			result = This new(newScheme take(), newAuthority, newPath, newQuery, newFragment take())
		}
		data free(Owner Receiver)
		result
	}
}
