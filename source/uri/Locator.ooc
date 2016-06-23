/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use uri
use collections

Locator: class {
	_scheme: String
	_authority: Authority
	_path: VectorList<String>
	_query: Query
	_fragment: String
	scheme ::= this _scheme
	authority ::= this _authority
	path ::= this _path
	query ::= this _query
	fragment ::= this _fragment

	init: func (=_scheme, =_authority, =_path, =_query, =_fragment)
	free: override func {
		if (this _authority != null)
			this _authority free()
		if (this _path != null)
			this _path free()
		if (this _query != null)
			this _query free()
		(this _scheme, this _fragment) free()
		super()
	}
	toString: func -> String {
		contents := StringBuilder new()
		authorityString: String = null
		queryString: String = null
		if (!this scheme empty())
			contents add(this scheme) . add("://")
		if (this authority != null) {
			authorityString = this authority toString()
			contents add(authorityString)
		}
		if (this _path != null)
			for (i in 0 .. this _path count)
				contents add("/") . add(this _path[i])
		if (this query != null) {
			queryString = this query toString()
			contents add("?") . add(queryString)
		}
		if (!this fragment empty())
			contents add("#") . add(this fragment)
		result := contents join("")
		contents free()
		if (authorityString != null)
			authorityString free()
		if (queryString != null)
			queryString free()
		result
	}
	parse: static func (data: String) -> This {
		result: This
		if (!data empty()) {
			splitted := data split("://")
			newScheme := splitted count > 1 ? splitted[0] clone() : ""
			d := splitted[splitted count > 1 ? 1 : 0] clone()
			splitted free()
			index: Int
			newFragment := ""
			if (!d empty() && (index = d lastIndexOf('#')) > -1) {
				newFragment = d substring(index + 1)
				substring := d substring(0, index)
				d free()
				d = substring
			}
			newQuery: Query
			if (!d empty() && (index = d lastIndexOf('?')) > -1) {
				substring := d substring(index + 1)
				newQuery = Query parse(substring)
				substring free()
				substring = d substring(0, index)
				d free()
				d = substring
			}
			newPath: VectorList<String>
			if (!d empty() && (index = d find("/", 0)) > -1) {
				substring := d substring(index + 1)
				newPath = substring split('/')
				substring free()
				substring = d substring(0, index)
				d free()
				d = substring
			}
			newAuthority: Authority = null
			if (!d empty())
				newAuthority = Authority parse(d)
			d free()
			result = This new(newScheme, newAuthority, newPath, newQuery, newFragment)
		}
		result
	}
}
