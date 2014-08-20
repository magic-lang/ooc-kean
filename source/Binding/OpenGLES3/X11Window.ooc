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

import lib/x11
import NativeWindow

X11Window: class extends NativeWindow {

  create: static func (width: UInt, height: UInt, title: String) -> This {
    result := X11Window new(width, height, title)
    result _generate(width, height, title) ? result : null
  }

  init: func (width: UInt, height: UInt, title: String) {
    this width = width
    this height = height
  }

  _generate: func (width: UInt, height: UInt, title: String) -> Bool {
    /* FIXME: ":0" is the usual identifier for the default display but this should be read from the DISPLAY variable in the system by passing null as parameter,
    i.e. this display = XOpenDisplay(null) */
    this display = XOpenDisplay(":0")
    if(!display)
      return false
    root: Long = DefaultRootWindow(this display)

    swa: XSetWindowAttributesOOC
    swa eventMask = ExposureMask | PointerMotionMask | KeyPressMask
    this window = XCreateWindow(this display, root, 0, 0, width, height, 0u, CopyFromParent as Int, InputOutput as UInt, null, CWEventMask, swa&)

    XMapWindow(this display, this window)
    XStoreName(this display, this window, title)
    true
  }

}
