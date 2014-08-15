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

import egl, x11

Context: class {
  eglContext: Pointer
  eglDisplay: Pointer
  eglSurface: Pointer

  nativeDisplay: Pointer
  nativeWindow: Long

  create: static func () -> This {
    result := Context new()
    if(result)
      result _generate(null)
    return result
  }

  init: func () {}

  create: static func ~shared (sharedContext: This) -> This {
    result := Context new()
    if(result)
      result _generate(sharedContext)
    return result
  }

  makeCurrent: func -> Bool {
    eglMakeCurrent(this eglDisplay, this eglSurface, this eglSurface, this eglContext) != 0
  }
  update: func () {
    eglSwapBuffers(eglDisplay, eglSurface)
  }

  _generate: func (sharedContext: This) {
    this nativeDisplay = XOpenDisplay(":0")
    root: Long = DefaultRootWindow(this nativeDisplay)

    swa: XSetWindowAttributesOOC
    swa eventMask = ExposureMask | PointerMotionMask | KeyPressMask
    this nativeWindow = XCreateWindow(this nativeDisplay, root, 0, 0, 800u, 480u, 0u, CopyFromParent as Int, InputOutput as UInt, null, CWEventMask, swa&)

    XMapWindow(this nativeDisplay, this nativeWindow)
    XStoreName(this nativeDisplay, this nativeWindow, "GL Test")

    this eglDisplay = eglGetDisplay(this nativeDisplay)

    eglInitialize(this eglDisplay, null, null)
    eglBindAPI(EGL_OPENGL_ES_API)

    configAttribs := [
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_BUFFER_SIZE, 16,
            EGL_NONE] as Int*

    numConfigs: Int
    eglChooseConfig(this eglDisplay, configAttribs, null, 10, numConfigs&)
    matchingConfigs := gc_malloc(numConfigs*Pointer size) as Pointer*
    eglChooseConfig(this eglDisplay, configAttribs, matchingConfigs, numConfigs, numConfigs&)
    chosenConfig: Pointer = null

    for(i in 0..numConfigs) {
      success: UInt
      red, green, blue, alpha: Int
      success = eglGetConfigAttrib(this eglDisplay, matchingConfigs[i], EGL_RED_SIZE, red&)
      success &= eglGetConfigAttrib(this eglDisplay, matchingConfigs[i], EGL_BLUE_SIZE, blue&)
      success &= eglGetConfigAttrib(this eglDisplay, matchingConfigs[i], EGL_GREEN_SIZE, green&)
      success &= eglGetConfigAttrib(this eglDisplay, matchingConfigs[i], EGL_ALPHA_SIZE, alpha&)

      if(success && red == 8 && blue == 8 && green == 8 && alpha == 8) {
        chosenConfig = matchingConfigs[i]
        break
      }
    }

    gc_free(matchingConfigs)
    eglSurface = eglCreateWindowSurface(this eglDisplay, chosenConfig, this nativeWindow, null)
    contextAttribs := [
            EGL_CONTEXT_CLIENT_VERSION, 3,
            EGL_NONE] as Int*

    shared: Pointer = null
    if(sharedContext)
      shared = sharedContext eglContext
    this eglContext = eglCreateContext(this eglDisplay, chosenConfig, shared, contextAttribs)
  }

  dispose: func {
    eglMakeCurrent(this eglDisplay, null, null, null)
    eglDestroyContext(this eglDisplay, this eglContext)
    eglDestroySurface(this eglDisplay, this eglSurface)
  }
}
