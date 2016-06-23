/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use uri
use collections
use base
use unit

LocatorTest: class extends Fixture {
	init: func {
		super("Locator")
		this add("parse", func {
			userText := "name:password"
			endpointText := "one.two:123"
			pathText1 := "path"
			pathText2 := "something"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			fragmentText := "frag"
			locatorText := "http://name:password@one.two:123/path/something?key=value;key2=value2#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == "http")
			(authorityString, userString, endpointString, queryString, locatorString) := (locator authority, locator authority user, locator authority endpoint, locator query, locator) toString()
			expect(authorityString == "name:password@one.two:123")
			expect(userString == userText)
			expect(endpointString == endpointText)
			expect(locator path[0] == pathText1)
			expect(locator path[1] == pathText2)
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2, is true)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(authorityString, userString, endpointString, queryString, locatorString, locator) free()
		})
		this add("empty", func {
			locator := Locator parse("")
			expect(locator, is Null)
		})
		this add("no scheme", func {
			userText := "name:password"
			endpointText := "one.two:123"
			pathText1 := "path"
			pathText2 := "something"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			fragmentText := "frag"
			locatorText := "name:password@one.two:123/path/something?key=value;key2=value2#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == "")
			(authorityString, userString, endpointString) := (locator authority, locator authority user, locator authority endpoint) toString()
			expect(authorityString == "name:password@one.two:123")
			expect(userString == userText)
			expect(endpointString == endpointText)
			expect(locator path[0] == pathText1)
			expect(locator path[1] == pathText2)
			(queryString, locatorString) := (locator query, locator) toString()
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(locator, authorityString, userString, endpointString, queryString, locatorString) free()
		})
		this add("no user", func {
			schemeText := "http"
			endpointText := "one.two:123"
			pathText1 := "path"
			pathText2 := "something"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			fragmentText := "frag"
			locatorText := "http://one.two:123/path/something?key=value;key2=value2#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText)
			(authorityString, endpointString, queryString, locatorString) := (locator authority, locator authority endpoint, locator query, locator) toString()
			expect(authorityString == endpointText)
			expect(locator authority user as User, is Null)
			expect(endpointString == endpointText)
			expect(locator path[0] == pathText1)
			expect(locator path[1] == pathText2)
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(locator, authorityString, endpointString, queryString, locatorString) free()
		})
		this add("no authority", func {
			schemeText := "http"
			pathText1 := "path"
			pathText2 := "something"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			fragmentText := "frag"
			locatorText := "http:///path/something?key=value;key2=value2#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText)
			expect(locator authority as Authority, is Null)
			path := locator path
			expect(path[0] == pathText1)
			expect(path[1] == pathText2)
			(queryString, locatorString) := (locator query, locator) toString()
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(queryString, locatorString, locator) free()
		})
		this add("no path", func {
			schemeText := "http"
			userText := "name:password"
			endpointText := "one.two:123"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			fragmentText := "frag"
			locatorText := "http://name:password@one.two:123?key=value;key2=value2#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText)
			(authorityString, userString, endpointString, queryString, locatorString) := (locator authority, locator authority user, locator authority endpoint, locator query, locator) toString()
			expect(authorityString == "name:password@one.two:123")
			expect(userString == userText)
			expect(endpointString == endpointText)
			expect(locator path, is Null)
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2, is true)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(locator, authorityString, userString, endpointString, queryString, locatorString) free()
		})
		this add("no query", func {
			schemeText := "http"
			userText := "name:password"
			endpointText := "one.two:123"
			pathText1 := "path"
			pathText2 := "something"
			fragmentText := "frag"
			locatorText := "http://name:password@one.two:123/path/something#frag"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText)
			(authorityString, userString, endpointString, locatorString) := (locator authority, locator authority user, locator authority endpoint, locator) toString()
			expect(authorityString == "name:password@one.two:123")
			expect(userString == userText)
			expect(endpointString == endpointText)
			expect(locator path[0] == pathText1)
			expect(locator path[1] == pathText2)
			expect(locator query as Query, is Null)
			expect(locator fragment == fragmentText)
			expect(locatorString == locatorText)
			(locator, authorityString, userString, endpointString, locatorString) free()
		})
		this add("no fragment", func {
			schemeText := "http"
			userText := "name:password"
			endpointText := "one.two:123"
			pathText1 := "path"
			pathText2 := "something"
			queryKey1 := "key"
			queryKey2 := "key2"
			queryValue2 := "value2"
			queryText := "key=value;key2=value2"
			locatorText := "http://name:password@one.two:123/path/something?key=value;key2=value2"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText)
			(authorityString, userString, endpointString, queryString, locatorString) := (locator authority, locator authority user, locator authority endpoint, locator query, locator) toString()
			expect(authorityString == "name:password@one.two:123")
			expect(userString == userText)
			expect(endpointString == endpointText)
			expect(locator path[0] == pathText1)
			expect(locator path[1] == pathText2)
			expect(queryString == queryText)
			expect(locator query contains(queryKey1) as Bool, is true)
			expect(locator query getValue(queryKey2) == queryValue2)
			expect(locator fragment == "")
			expect(locatorString == locatorText)
			(locator, authorityString, userString, endpointString, queryString, locatorString) free()
		})
		this add("only path", func {
			schemeText := "http"
			pathText1 := "path"
			pathText2 := "something"
			locatorText := "http:///path/something"
			locator := Locator parse(locatorText)
			expect(locator scheme == schemeText, "1")
			expect(locator authority as Authority, is Null)
			expect(locator path[0] == pathText1, "2")
			expect(locator path[1] == pathText2, "3")
			expect(locator query as Query, is Null)
			expect(locator fragment == "", "4")
			locatorString := locator toString()
			expect(locatorString == locatorText, "5")
			(locator, locatorString) free()
		})
	}
}

LocatorTest new() run() . free()
