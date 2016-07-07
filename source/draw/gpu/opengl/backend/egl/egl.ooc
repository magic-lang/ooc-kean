/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(!gpuOff) {
include EGL/egl, EGL/eglext

// EGL 3
EGL_NO_SURFACE: extern const UInt

EGL_FALSE: extern const UInt
EGL_TRUE: extern const UInt

/* Out-of-band handle values */
EGL_DEFAULT_DISPLAY: extern const Pointer
EGL_NO_CONTEXT: extern const Pointer
EGL_NO_DISPLAY: extern const Pointer
EGL_NO_SURFACE: extern const Pointer
EGL_NO_IMAGE_KHR: extern const Pointer

/* Out-of-band attribute value */
EGL_DONT_CARE: extern const Int

/* Errors / GetError return values */
EGL_SUCCESS: extern const UInt
EGL_NOT_INITIALIZED: extern const UInt
EGL_BAD_ACCESS: extern const UInt
EGL_BAD_ALLOC: extern const UInt
EGL_BAD_ATTRIBUTE: extern const UInt
EGL_BAD_CONFIG: extern const UInt
EGL_BAD_CONTEXT: extern const UInt
EGL_BAD_CURRENT_SURFACE: extern const UInt
EGL_BAD_DISPLAY: extern const UInt
EGL_BAD_MATCH: extern const UInt
EGL_BAD_NATIVE_PIXMAP: extern const UInt
EGL_BAD_NATIVE_WINDOW: extern const UInt
EGL_BAD_PARAMETER: extern const UInt
EGL_BAD_SURFACE: extern const UInt
EGL_CONTEXT_LOST: extern const UInt

/* Config attributes */
EGL_BUFFER_SIZE: extern const UInt
EGL_ALPHA_SIZE: extern const UInt
EGL_BLUE_SIZE: extern const UInt
EGL_GREEN_SIZE: extern const UInt
EGL_RED_SIZE: extern const UInt
EGL_DEPTH_SIZE: extern const UInt
EGL_STENCIL_SIZE: extern const UInt
EGL_CONFIG_CAVEAT: extern const UInt
EGL_CONFIG_ID: extern const UInt
EGL_LEVEL: extern const UInt
EGL_MAX_PBUFFER_HEIGHT: extern const UInt
EGL_MAX_PBUFFER_PIXELS: extern const UInt
EGL_MAX_PBUFFER_WIDTH: extern const UInt
EGL_NATIVE_RENDERABLE: extern const UInt
EGL_NATIVE_VISUAL_ID: extern const UInt
EGL_NATIVE_VISUAL_TYPE: extern const UInt
EGL_SAMPLES: extern const UInt
EGL_SAMPLE_BUFFERS: extern const UInt
EGL_SURFACE_TYPE: extern const UInt
EGL_TRANSPARENT_TYPE: extern const UInt
EGL_TRANSPARENT_BLUE_VALUE: extern const UInt
EGL_TRANSPARENT_GREEN_VALUE: extern const UInt
EGL_TRANSPARENT_RED_VALUE: extern const UInt
EGL_NONE: extern const UInt
EGL_BIND_TO_TEXTURE_RGB: extern const UInt
EGL_BIND_TO_TEXTURE_RGBA: extern const UInt
EGL_MIN_SWAP_INTERVAL: extern const UInt
EGL_MAX_SWAP_INTERVAL: extern const UInt
EGL_LUMINANCE_SIZE: extern const UInt
EGL_ALPHA_MASK_SIZE: extern const UInt
EGL_COLOR_BUFFER_TYPE: extern const UInt
EGL_RENDERABLE_TYPE: extern const UInt
EGL_MATCH_NATIVE_PIXMAP: extern const UInt
EGL_CONFORMANT: extern const UInt
/* Config attribute values */
EGL_SLOW_CONFIG: extern const UInt
EGL_NON_CONFORMANT_CONFIG: extern const UInt
EGL_TRANSPARENT_RGB: extern const UInt
EGL_RGB_BUFFER: extern const UInt
EGL_LUMINANCE_BUFFER: extern const UInt
/* More config attribute values, for EGL_TEXTURE_FORMAT */
EGL_NO_TEXTURE: extern const UInt
EGL_TEXTURE_RGB: extern const UInt
EGL_TEXTURE_RGBA: extern const UInt
EGL_TEXTURE_2D: extern const UInt
/* Config attribute mask bits */
EGL_PBUFFER_BIT: extern const UInt
EGL_PIXMAP_BIT: extern const UInt
EGL_WINDOW_BIT: extern const UInt
EGL_VG_COLORSPACE_LINEAR_BIT: extern const UInt
EGL_VG_ALPHA_FORMAT_PRE_BIT: extern const UInt
EGL_MULTISAMPLE_RESOLVE_BOX_BIT: extern const UInt
EGL_SWAP_BEHAVIOR_PRESERVED_BIT: extern const UInt
EGL_OPENGL_ES_BIT: extern const UInt
EGL_OPENVG_BIT: extern const UInt
EGL_OPENGL_ES2_BIT: extern const UInt
EGL_OPENGL_BIT: extern const UInt
/* QueryString targets */
EGL_VENDOR: extern const UInt
EGL_VERSION: extern const UInt
EGL_EXTENSIONS: extern const UInt
EGL_CLIENT_APIS: extern const UInt
/* QuerySurface / SurfaceAttrib / CreatePbufferSurface targets */
EGL_HEIGHT: extern const UInt
EGL_WIDTH: extern const UInt
EGL_LARGEST_PBUFFER: extern const UInt
EGL_TEXTURE_FORMAT: extern const UInt
EGL_TEXTURE_TARGET: extern const UInt
EGL_MIPMAP_TEXTURE: extern const UInt
EGL_MIPMAP_LEVEL: extern const UInt
EGL_RENDER_BUFFER: extern const UInt
EGL_VG_COLORSPACE: extern const UInt
EGL_VG_ALPHA_FORMAT: extern const UInt
EGL_HORIZONTAL_RESOLUTION: extern const UInt
EGL_VERTICAL_RESOLUTION: extern const UInt
EGL_PIXEL_ASPECT_RATIO: extern const UInt
EGL_SWAP_BEHAVIOR: extern const UInt
EGL_MULTISAMPLE_RESOLVE: extern const UInt
/* EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets */
EGL_BACK_BUFFER: extern const UInt
EGL_SINGLE_BUFFER: extern const UInt
/* OpenVG color spaces */
EGL_VG_COLORSPACE_sRGB: extern const UInt
EGL_VG_COLORSPACE_LINEAR: extern const UInt
/* OpenVG alpha formats */
EGL_VG_ALPHA_FORMAT_NONPRE: extern const UInt
EGL_VG_ALPHA_FORMAT_PRE: extern const UInt
/* Constant scale factor by which fractional display resolutions &
 * aspect ratio are scaled when queried as integer values.
 */
EGL_DISPLAY_SCALING: extern const UInt
/* Unknown display resolution/aspect ratio */
EGL_UNKNOWN: extern const UInt
/* Back buffer swap behaviors */
EGL_BUFFER_PRESERVED: extern const UInt
EGL_BUFFER_DESTROYED: extern const UInt
/* CreatePbufferFromClientBuffer buffer types */
EGL_OPENVG_IMAGE: extern const UInt
/* QueryContext targets */
EGL_CONTEXT_CLIENT_TYPE: extern const UInt
/* CreateContext attributes */
EGL_CONTEXT_CLIENT_VERSION: extern const UInt
/* Multisample resolution behaviors */
EGL_MULTISAMPLE_RESOLVE_DEFAULT: extern const UInt
EGL_MULTISAMPLE_RESOLVE_BOX: extern const UInt
/* BindAPI/QueryAPI targets */
EGL_OPENGL_ES_API: extern const UInt
EGL_OPENVG_API: extern const UInt
EGL_OPENGL_API: extern const UInt
/* GetCurrentSurface targets */
EGL_DRAW: extern const UInt
EGL_READ: extern const UInt
/* WaitNative engines */
EGL_CORE_NATIVE_ENGINE: extern const UInt
/* EGL 1.2 tokens renamed for consistency in EGL 1.3 */
EGL_COLORSPACE: extern const UInt
EGL_ALPHA_FORMAT: extern const UInt
EGL_COLORSPACE_sRGB: extern const UInt
EGL_COLORSPACE_LINEAR: extern const UInt
EGL_ALPHA_FORMAT_NONPRE: extern const UInt
EGL_ALPHA_FORMAT_PRE: extern const UInt

/* Extensions */
EGL_IMAGE_PRESERVED_KHR: extern const UInt
EGL_NATIVE_BUFFER_ANDROID: extern const UInt
EGL_SYNC_NATIVE_FENCE_ANDROID: extern const UInt
EGL_SYNC_NATIVE_FENCE_FD_ANDROID: extern const UInt
EGL_NO_NATIVE_FENCE_FD_ANDROID: extern const UInt
EGL_SYNC_FLUSH_COMMANDS_BIT_KHR: extern const UInt
__eglMustCastToProperFunctionPointerType_OOC: cover from __eglMustCastToProperFunctionPointerType
eglGetProcAddress: extern func (procname: CString) -> Pointer
PFNEGLCREATEIMAGEKHRPROC_OOC: cover from PFNEGLCREATEIMAGEKHRPROC
PFNEGLDESTROYIMAGEKHRPROC_OOC: cover from PFNEGLDESTROYIMAGEKHRPROC

eglMakeCurrent: extern func (display, draw, read, context: Pointer) -> UInt
eglDestroyContext: extern func (display, context: Pointer) -> UInt
eglDestroySurface: extern func (display, surface: Pointer) -> UInt
eglGetDisplay: extern func (nativeDisplay: Pointer) -> Pointer
eglInitialize: extern func (display: Pointer, major: Int*, minor: Int*) -> UInt
eglBindAPI: extern func (api: UInt) -> UInt
eglChooseConfig: extern func (display: Pointer, attribList: Int*, configs: Pointer*, configSize: Int, numConfig: Int*) -> UInt
eglCreateWindowSurface: extern func (display: Pointer, config: Pointer, window: ULong, attribList: Int*) -> Pointer
eglCreatePbufferSurface: extern func (display: Pointer, config: Pointer, attridList: Int*) -> Pointer
eglCreateContext: extern func (display: Pointer, config: Pointer, sharedContext: Pointer, attribList: Int*) -> Pointer
eglGetConfigAttrib: extern func (display: Pointer, config: Pointer, attribute: Int, value: Int*) -> UInt
eglSwapBuffers: extern func (display, surface: Pointer)
eglTerminate: extern func (display: Pointer) -> UInt
eglGetError: extern func -> UInt
eglGetCurrentContext: extern func -> Pointer
eglQueryString: extern func (display: Pointer, name: UInt) -> Char*
}
