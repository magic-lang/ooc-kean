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

// EGL 3
EGL_NO_SURFACE: extern const UInt

EGL_FALSE: extern const UInt
EGL_TRUE: extern const UInt

/* Out-of-band handle values */
EGL_DEFAULT_DISPLAY: extern const Pointer
EGL_NO_CONTEXT: extern const Pointer
EGL_NO_DISPLAY: extern const Pointer
EGL_NO_SURFACE: extern const Pointer

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
/*
/* More config attribute values, for EGL_TEXTURE_FORMAT */
EGL_NO_TEXTURE			0x305C
EGL_TEXTURE_RGB			0x305D
EGL_TEXTURE_RGBA		0x305E
EGL_TEXTURE_2D			0x305F

/* Config attribute mask bits */
EGL_PBUFFER_BIT			0x0001	/* EGL_SURFACE_TYPE mask bits */
EGL_PIXMAP_BIT			0x0002	/* EGL_SURFACE_TYPE mask bits */
EGL_WINDOW_BIT			0x0004	/* EGL_SURFACE_TYPE mask bits */
EGL_VG_COLORSPACE_LINEAR_BIT	0x0020	/* EGL_SURFACE_TYPE mask bits */
EGL_VG_ALPHA_FORMAT_PRE_BIT	0x0040	/* EGL_SURFACE_TYPE mask bits */
EGL_MULTISAMPLE_RESOLVE_BOX_BIT 0x0200	/* EGL_SURFACE_TYPE mask bits */
EGL_SWAP_BEHAVIOR_PRESERVED_BIT 0x0400	/* EGL_SURFACE_TYPE mask bits */

EGL_OPENGL_ES_BIT		0x0001	/* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENVG_BIT			0x0002	/* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENGL_ES2_BIT		0x0004	/* EGL_RENDERABLE_TYPE mask bits */
EGL_OPENGL_BIT			0x0008	/* EGL_RENDERABLE_TYPE mask bits */

/* QueryString targets */
EGL_VENDOR			0x3053
EGL_VERSION			0x3054
EGL_EXTENSIONS			0x3055
EGL_CLIENT_APIS			0x308D

/* QuerySurface / SurfaceAttrib / CreatePbufferSurface targets */
EGL_HEIGHT			0x3056
EGL_WIDTH			0x3057
EGL_LARGEST_PBUFFER		0x3058
EGL_TEXTURE_FORMAT		0x3080
EGL_TEXTURE_TARGET		0x3081
EGL_MIPMAP_TEXTURE		0x3082
EGL_MIPMAP_LEVEL		0x3083
EGL_RENDER_BUFFER		0x3086
EGL_VG_COLORSPACE		0x3087
EGL_VG_ALPHA_FORMAT		0x3088
EGL_HORIZONTAL_RESOLUTION	0x3090
EGL_VERTICAL_RESOLUTION		0x3091
EGL_PIXEL_ASPECT_RATIO		0x3092
EGL_SWAP_BEHAVIOR		0x3093
EGL_MULTISAMPLE_RESOLVE		0x3099

/* EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets */
EGL_BACK_BUFFER			0x3084
EGL_SINGLE_BUFFER		0x3085

/* OpenVG color spaces */
EGL_VG_COLORSPACE_sRGB		0x3089	/* EGL_VG_COLORSPACE value */
EGL_VG_COLORSPACE_LINEAR	0x308A	/* EGL_VG_COLORSPACE value */

/* OpenVG alpha formats */
EGL_VG_ALPHA_FORMAT_NONPRE	0x308B	/* EGL_ALPHA_FORMAT value */
EGL_VG_ALPHA_FORMAT_PRE		0x308C	/* EGL_ALPHA_FORMAT value */

/* Constant scale factor by which fractional display resolutions &
 * aspect ratio are scaled when queried as integer values.
 */
EGL_DISPLAY_SCALING		10000

/* Unknown display resolution/aspect ratio */
EGL_UNKNOWN			((EGLint)-1)

/* Back buffer swap behaviors */
EGL_BUFFER_PRESERVED		0x3094	/* EGL_SWAP_BEHAVIOR value */
EGL_BUFFER_DESTROYED		0x3095	/* EGL_SWAP_BEHAVIOR value */

/* CreatePbufferFromClientBuffer buffer types */
EGL_OPENVG_IMAGE		0x3096

/* QueryContext targets */
EGL_CONTEXT_CLIENT_TYPE		0x3097

/* CreateContext attributes */
EGL_CONTEXT_CLIENT_VERSION	0x3098

/* Multisample resolution behaviors */
EGL_MULTISAMPLE_RESOLVE_DEFAULT 0x309A	/* EGL_MULTISAMPLE_RESOLVE value */
EGL_MULTISAMPLE_RESOLVE_BOX	0x309B	/* EGL_MULTISAMPLE_RESOLVE value */

/* BindAPI/QueryAPI targets */
EGL_OPENGL_ES_API		0x30A0
EGL_OPENVG_API			0x30A1
EGL_OPENGL_API			0x30A2

/* GetCurrentSurface targets */
EGL_DRAW			0x3059
EGL_READ			0x305A

/* WaitNative engines */
EGL_CORE_NATIVE_ENGINE		0x305B

/* EGL 1.2 tokens renamed for consistency in EGL 1.3 */
EGL_COLORSPACE			EGL_VG_COLORSPACE
EGL_ALPHA_FORMAT: extern const UInt
EGL_COLORSPACE_sRGB: extern const UInt
EGL_COLORSPACE_LINEAR: extern const UInt
EGL_ALPHA_FORMAT_NONPRE: extern const UInt
EGL_ALPHA_FORMAT_PRE: extern const UInt
*/

eglMakeCurrent: extern func(display: Pointer, draw: Pointer, read: Pointer, context: Pointer) -> UInt
