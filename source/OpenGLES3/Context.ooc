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

import lib/egl, NativeWindow

Context: class {
  _eglContext: Pointer
  _eglDisplay: Pointer
  _eglSurface: Pointer

  init: func
  dispose: func {
    eglMakeCurrent(this _eglDisplay, null, null, null)
    eglDestroyContext(this _eglDisplay, this _eglContext)
    eglDestroySurface(this _eglDisplay, this _eglSurface)
  }
  makeCurrent: func -> Bool {
    return eglMakeCurrent(this _eglDisplay, this _eglSurface, this _eglSurface, this _eglContext) != 0
  }
  swapBuffers: func {
    eglSwapBuffers(_eglDisplay, _eglSurface)
  }
  _generate: func (window: NativeWindow, sharedContext: This) -> Bool {
    this _eglDisplay = eglGetDisplay(window display)

    if (this _eglDisplay == null)
      return false

    eglInitialize(this _eglDisplay, null, null)
    eglBindAPI(EGL_OPENGL_ES_API)

    configAttribs := [
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_BUFFER_SIZE, 16,
            EGL_NONE] as Int*

    numConfigs: Int
    eglChooseConfig(this _eglDisplay, configAttribs, null, 10, numConfigs&)
    matchingConfigs := gc_malloc(numConfigs*Pointer size) as Pointer*
    eglChooseConfig(this _eglDisplay, configAttribs, matchingConfigs, numConfigs, numConfigs&)
    chosenConfig: Pointer = null

    for (i in 0..numConfigs) {
      success: UInt
      red, green, blue, alpha: Int
      success = eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_RED_SIZE, red&)
      success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_BLUE_SIZE, blue&)
      success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_GREEN_SIZE, green&)
      success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_ALPHA_SIZE, alpha&)

      if (success && red == 8 && blue == 8 && green == 8 && alpha == 8) {
        chosenConfig = matchingConfigs[i]
        break
      }
    }

    gc_free(matchingConfigs)
    this _eglSurface = eglCreateWindowSurface(this _eglDisplay, chosenConfig, window backend, null)

    if (this _eglSurface == null)
      return false

    contextAttribs := [
            EGL_CONTEXT_CLIENT_VERSION, 3,
            EGL_NONE] as Int*

    shared: Pointer = null
    if (sharedContext)
      shared = sharedContext _eglContext
    this _eglContext = eglCreateContext(this _eglDisplay, chosenConfig, shared, contextAttribs)
    if (this _eglContext == null) {
      "Failed to create OpenGL ES 3 context, trying with OpenGL ES 2 instead" println()
      contextAttribsGLES2 := [
            EGL_CONTEXT_CLIENT_VERSION, 2,
            EGL_NONE] as Int*
      this _eglContext = eglCreateContext(this _eglDisplay, chosenConfig, shared, contextAttribsGLES2)
    }
    if (this _eglContext == null)
      raise("Failed to create OpenGL ES 3 or OpenGL ES 2 context")
    return true
  }
  create: static func (window: NativeWindow) -> This {
    result := This new()
    result _generate(window, null) ? result : null
  }
  create: static func ~shared (window: NativeWindow, sharedContext: This) -> This {
    result := This new()
    result _generate(window, sharedContext) ? result : null
  }


}
