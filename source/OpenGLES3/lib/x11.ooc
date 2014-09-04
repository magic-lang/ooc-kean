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

include X11/Xlib
include X11/Xatom
include X11/Xutil


ExposureMask: extern const Long
PointerMotionMask: extern const Long
KeyPressMask: extern const Long
CopyFromParent: extern const Long
InputOutput: extern const UInt
CWEventMask: extern const ULong


XSetWindowAttributesOOC: cover from XSetWindowAttributes {
  backgroundPixmap: extern(background_pixmap) Long
  backgroundPixel: extern(background_pixel) ULong
  borderPixmap: extern(border_pixmap) Long
  borderPixel: extern(border_pixel) ULong
  bitGravity: extern(bit_gravity) Int
  winGravity: extern(win_gravity) Int
  backingStore: extern(backing_store) Int
  backingPlanes: extern(backing_planes) ULong
  backingPixel: extern(backing_pixel) ULong
  saveUnder: extern(save_under) Bool
  eventMask: extern(event_mask) Long
  doNotPropagateMask: extern(do_not_propagate_mask) Long
  overrideRedirect: extern(override_redirect) Bool
  colormap: extern Long
  cursor: extern Long
}


XOpenDisplay: extern func(displayName: Char*) -> Pointer
XCreateWindow: extern func(display: Pointer, window: Long, x: Int, y: Int,
  width: UInt, height: UInt, borderWidth: UInt, depth: Int, class: UInt, visual: Pointer, valueMask: ULong, attributes: Pointer) -> Long
XMapWindow: extern func(display: Pointer, window: Long) -> Int
XStoreName: extern func(display: Pointer, window: Long, windowName: Char*) -> Int
DefaultRootWindow: extern func(display: Pointer) -> UInt
