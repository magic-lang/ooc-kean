/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

include GLES3/gl3, GLES3/gl3ext, GLES3/gl3platform, GLES2/gl2ext
PFNGLEGLIMAGETARGETTEXTURE2DOESPROC_OOC: cover from PFNGLEGLIMAGETARGETTEXTURE2DOESPROC

/*-------------------------------------------------------------------------
 * Token definitions
 *-----------------------------------------------------------------------*/

/* Extensions */
GL_TEXTURE_EXTERNAL_OES: extern const UInt
GL_REQUIRED_TEXTURE_IMAGE_UNITS_OES: extern const UInt

/* OpenGL ES core versions */
GL_ES_VERSION_3_0: extern const UInt
GL_ES_VERSION_2_0: extern const UInt

/* OpenGL ES 2.0 */

/* ClearBufferMask */
GL_DEPTH_BUFFER_BIT: extern const UInt
GL_STENCIL_BUFFER_BIT: extern const UInt
GL_COLOR_BUFFER_BIT: extern const UInt

/* Boolean */
GL_FALSE: extern const UInt
GL_TRUE: extern const UInt

/* BeginMode */
GL_POINTS: extern const UInt
GL_LINES: extern const UInt
GL_LINE_LOOP: extern const UInt
GL_LINE_STRIP: extern const UInt
GL_TRIANGLES: extern const UInt
GL_TRIANGLE_STRIP: extern const UInt
GL_TRIANGLE_FAN: extern const UInt

/* BlendingFactorDest */
GL_ZERO: extern const UInt
GL_ONE: extern const UInt
GL_SRC_COLOR: extern const UInt
GL_ONE_MINUS_SRC_COLOR: extern const UInt
GL_SRC_ALPHA: extern const UInt
GL_ONE_MINUS_SRC_ALPHA: extern const UInt
GL_DST_ALPHA: extern const UInt
GL_ONE_MINUS_DST_ALPHA: extern const UInt

/* BlendingFactorSrc */
/*      GL_ZERO */
/*      GL_ONE */
GL_DST_COLOR: extern const UInt
GL_ONE_MINUS_DST_COLOR: extern const UInt
GL_SRC_ALPHA_SATURATE: extern const UInt
/*      GL_SRC_ALPHA */
/*      GL_ONE_MINUS_SRC_ALPHA */
/*      GL_DST_ALPHA */
/*      GL_ONE_MINUS_DST_ALPHA */

/* BlendEquationSeparate */
GL_FUNC_ADD: extern const UInt
GL_BLEND_EQUATION: extern const UInt
GL_BLEND_EQUATION_RGB: extern const UInt    /* same as BLEND_EQUATION */
GL_BLEND_EQUATION_ALPHA: extern const UInt

/* BlendSubtract */
GL_FUNC_SUBTRACT: extern const UInt
GL_FUNC_REVERSE_SUBTRACT: extern const UInt

/* Separate Blend Functions */
GL_BLEND_DST_RGB: extern const UInt
GL_BLEND_SRC_RGB: extern const UInt
GL_BLEND_DST_ALPHA: extern const UInt
GL_BLEND_SRC_ALPHA: extern const UInt
GL_CONSTANT_COLOR: extern const UInt
GL_ONE_MINUS_CONSTANT_COLOR: extern const UInt
GL_CONSTANT_ALPHA: extern const UInt
GL_ONE_MINUS_CONSTANT_ALPHA: extern const UInt
GL_BLEND_COLOR: extern const UInt

/* Buffer Objects */
GL_ARRAY_BUFFER: extern const UInt
GL_ELEMENT_ARRAY_BUFFER: extern const UInt
GL_ARRAY_BUFFER_BINDING: extern const UInt
GL_ELEMENT_ARRAY_BUFFER_BINDING: extern const UInt

GL_STREAM_DRAW: extern const UInt
GL_STATIC_DRAW: extern const UInt
GL_DYNAMIC_DRAW: extern const UInt

GL_BUFFER_SIZE: extern const UInt
GL_BUFFER_USAGE: extern const UInt

GL_CURRENT_VERTEX_ATTRIB: extern const UInt

/* CullFaceMode */
GL_FRONT: extern const UInt
GL_BACK: extern const UInt
GL_FRONT_AND_BACK: extern const UInt

/* DepthFunction */
/*      GL_NEVER */
/*      GL_LESS */
/*      GL_EQUAL */
/*      GL_LEQUAL */
/*      GL_GREATER */
/*      GL_NOTEQUAL */
/*      GL_GEQUAL */
/*      GL_ALWAYS */

/* EnableCap */
GL_TEXTURE_2D: extern const UInt
GL_CULL_FACE: extern const UInt
GL_BLEND: extern const UInt
GL_DITHER: extern const UInt
GL_STENCIL_TEST: extern const UInt
GL_DEPTH_TEST: extern const UInt
GL_SCISSOR_TEST: extern const UInt
GL_POLYGON_OFFSET_FILL: extern const UInt
GL_SAMPLE_ALPHA_TO_COVERAGE: extern const UInt
GL_SAMPLE_COVERAGE: extern const UInt

/* ErrorCode */
GL_NO_ERROR: extern const UInt
GL_INVALID_ENUM: extern const UInt
GL_INVALID_VALUE: extern const UInt
GL_INVALID_OPERATION: extern const UInt
GL_OUT_OF_MEMORY: extern const UInt

/* FrontFaceDirection */
GL_CW: extern const UInt
GL_CCW: extern const UInt

/* GetPName */
GL_LINE_WIDTH: extern const UInt
GL_ALIASED_POINT_SIZE_RANGE: extern const UInt
GL_ALIASED_LINE_WIDTH_RANGE: extern const UInt
GL_CULL_FACE_MODE: extern const UInt
GL_FRONT_FACE: extern const UInt
GL_DEPTH_RANGE: extern const UInt
GL_DEPTH_WRITEMASK: extern const UInt
GL_DEPTH_CLEAR_VALUE: extern const UInt
GL_DEPTH_FUNC: extern const UInt
GL_STENCIL_CLEAR_VALUE: extern const UInt
GL_STENCIL_FUNC: extern const UInt
GL_STENCIL_FAIL: extern const UInt
GL_STENCIL_PASS_DEPTH_FAIL: extern const UInt
GL_STENCIL_PASS_DEPTH_PASS: extern const UInt
GL_STENCIL_REF: extern const UInt
GL_STENCIL_VALUE_MASK: extern const UInt
GL_STENCIL_WRITEMASK: extern const UInt
GL_STENCIL_BACK_FUNC: extern const UInt
GL_STENCIL_BACK_FAIL: extern const UInt
GL_STENCIL_BACK_PASS_DEPTH_FAIL: extern const UInt
GL_STENCIL_BACK_PASS_DEPTH_PASS: extern const UInt
GL_STENCIL_BACK_REF: extern const UInt
GL_STENCIL_BACK_VALUE_MASK: extern const UInt
GL_STENCIL_BACK_WRITEMASK: extern const UInt
GL_VIEWPORT: extern const UInt
GL_SCISSOR_BOX: extern const UInt
/*      GL_SCISSOR_TEST */
GL_COLOR_CLEAR_VALUE: extern const UInt
GL_COLOR_WRITEMASK: extern const UInt
GL_UNPACK_ALIGNMENT: extern const UInt
GL_PACK_ALIGNMENT: extern const UInt
GL_MAX_TEXTURE_SIZE: extern const UInt
GL_MAX_VIEWPORT_DIMS: extern const UInt
GL_SUBPIXEL_BITS: extern const UInt
GL_RED_BITS: extern const UInt
GL_GREEN_BITS: extern const UInt
GL_BLUE_BITS: extern const UInt
GL_ALPHA_BITS: extern const UInt
GL_DEPTH_BITS: extern const UInt
GL_STENCIL_BITS: extern const UInt
GL_POLYGON_OFFSET_UNITS: extern const UInt
/*      GL_POLYGON_OFFSET_FILL */
GL_POLYGON_OFFSET_FACTOR: extern const UInt
GL_TEXTURE_BINDING_2D: extern const UInt
GL_SAMPLE_BUFFERS: extern const UInt
GL_SAMPLES: extern const UInt
GL_SAMPLE_COVERAGE_VALUE: extern const UInt
GL_SAMPLE_COVERAGE_INVERT: extern const UInt

/* GetTextureParameter */
/*      GL_TEXTURE_MAG_FILTER */
/*      GL_TEXTURE_MIN_FILTER */
/*      GL_TEXTURE_WRAP_S */
/*      GL_TEXTURE_WRAP_T */

GL_NUM_COMPRESSED_TEXTURE_FORMATS: extern const UInt
GL_COMPRESSED_TEXTURE_FORMATS: extern const UInt

/* HintMode */
GL_DONT_CARE: extern const UInt
GL_FASTEST: extern const UInt
GL_NICEST: extern const UInt

/* HintTarget */
GL_GENERATE_MIPMAP_HINT: extern const UInt

/* DataType */
GL_BYTE: extern const UInt
GL_UNSIGNED_BYTE: extern const UInt
GL_SHORT: extern const UInt
GL_UNSIGNED_SHORT: extern const UInt
GL_INT: extern const UInt
GL_UNSIGNED_INT: extern const UInt
GL_FLOAT: extern const UInt
GL_FIXED: extern const UInt

/* PixelFormat */
GL_DEPTH_COMPONENT: extern const UInt
GL_ALPHA: extern const UInt
GL_RGB: extern const UInt
GL_RGBA: extern const UInt
GL_LUMINANCE: extern const UInt
GL_LUMINANCE_ALPHA: extern const UInt

/* PixelType */
/*      GL_UNSIGNED_BYTE */
GL_UNSIGNED_SHORT_4_4_4_4: extern const UInt
GL_UNSIGNED_SHORT_5_5_5_1: extern const UInt
GL_UNSIGNED_SHORT_5_6_5: extern const UInt

/* Shaders */
GL_FRAGMENT_SHADER: extern const UInt
GL_VERTEX_SHADER: extern const UInt
GL_MAX_VERTEX_ATTRIBS: extern const UInt
GL_MAX_VERTEX_UNIFORM_VECTORS: extern const UInt
GL_MAX_VARYING_VECTORS: extern const UInt
GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS: extern const UInt
GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS: extern const UInt
GL_MAX_TEXTURE_IMAGE_UNITS: extern const UInt
GL_MAX_FRAGMENT_UNIFORM_VECTORS: extern const UInt
GL_SHADER_TYPE: extern const UInt
GL_DELETE_STATUS: extern const UInt
GL_LINK_STATUS: extern const UInt
GL_VALIDATE_STATUS: extern const UInt
GL_ATTACHED_SHADERS: extern const UInt
GL_ACTIVE_UNIFORMS: extern const UInt
GL_ACTIVE_UNIFORM_MAX_LENGTH: extern const UInt
GL_ACTIVE_ATTRIBUTES: extern const UInt
GL_ACTIVE_ATTRIBUTE_MAX_LENGTH: extern const UInt
GL_SHADING_LANGUAGE_VERSION: extern const UInt
GL_CURRENT_PROGRAM: extern const UInt

/* StencilFunction */
GL_NEVER: extern const UInt
GL_LESS: extern const UInt
GL_EQUAL: extern const UInt
GL_LEQUAL: extern const UInt
GL_GREATER: extern const UInt
GL_NOTEQUAL: extern const UInt
GL_GEQUAL: extern const UInt
GL_ALWAYS: extern const UInt

/* StencilOp */
/*      GL_ZERO */
GL_KEEP: extern const UInt
GL_REPLACE: extern const UInt
GL_INCR: extern const UInt
GL_DECR: extern const UInt
GL_INVERT: extern const UInt
GL_INCR_WRAP: extern const UInt
GL_DECR_WRAP: extern const UInt

/* StringName */
GL_VENDOR: extern const UInt
GL_RENDERER: extern const UInt
GL_VERSION: extern const UInt
GL_EXTENSIONS: extern const UInt

/* TextureMagFilter */
GL_NEAREST: extern const UInt
GL_LINEAR: extern const UInt

/* TextureMinFilter */
/*      GL_NEAREST */
/*      GL_LINEAR */
GL_NEAREST_MIPMAP_NEAREST: extern const UInt
GL_LINEAR_MIPMAP_NEAREST: extern const UInt
GL_NEAREST_MIPMAP_LINEAR: extern const UInt
GL_LINEAR_MIPMAP_LINEAR: extern const UInt

/* TextureParameterName */
GL_TEXTURE_MAG_FILTER: extern const UInt
GL_TEXTURE_MIN_FILTER: extern const UInt
GL_TEXTURE_WRAP_S: extern const UInt
GL_TEXTURE_WRAP_T: extern const UInt

/* TextureTarget */
/*      GL_TEXTURE_2D */
GL_TEXTURE: extern const UInt

GL_TEXTURE_CUBE_MAP: extern const UInt
GL_TEXTURE_BINDING_CUBE_MAP: extern const UInt
GL_TEXTURE_CUBE_MAP_POSITIVE_X: extern const UInt
GL_TEXTURE_CUBE_MAP_NEGATIVE_X: extern const UInt
GL_TEXTURE_CUBE_MAP_POSITIVE_Y: extern const UInt
GL_TEXTURE_CUBE_MAP_NEGATIVE_Y: extern const UInt
GL_TEXTURE_CUBE_MAP_POSITIVE_Z: extern const UInt
GL_TEXTURE_CUBE_MAP_NEGATIVE_Z: extern const UInt
GL_MAX_CUBE_MAP_TEXTURE_SIZE: extern const UInt

/* TextureUnit */
GL_TEXTURE0: extern const UInt
GL_TEXTURE1: extern const UInt
GL_TEXTURE2: extern const UInt
GL_TEXTURE3: extern const UInt
GL_TEXTURE4: extern const UInt
GL_TEXTURE5: extern const UInt
GL_TEXTURE6: extern const UInt
GL_TEXTURE7: extern const UInt
GL_TEXTURE8: extern const UInt
GL_TEXTURE9: extern const UInt
GL_TEXTURE10: extern const UInt
GL_TEXTURE11: extern const UInt
GL_TEXTURE12: extern const UInt
GL_TEXTURE13: extern const UInt
GL_TEXTURE14: extern const UInt
GL_TEXTURE15: extern const UInt
GL_TEXTURE16: extern const UInt
GL_TEXTURE17: extern const UInt
GL_TEXTURE18: extern const UInt
GL_TEXTURE19: extern const UInt
GL_TEXTURE20: extern const UInt
GL_TEXTURE21: extern const UInt
GL_TEXTURE22: extern const UInt
GL_TEXTURE23: extern const UInt
GL_TEXTURE24: extern const UInt
GL_TEXTURE25: extern const UInt
GL_TEXTURE26: extern const UInt
GL_TEXTURE27: extern const UInt
GL_TEXTURE28: extern const UInt
GL_TEXTURE29: extern const UInt
GL_TEXTURE30: extern const UInt
GL_TEXTURE31: extern const UInt
GL_ACTIVE_TEXTURE: extern const UInt

/* TextureWrapMode */
GL_REPEAT: extern const UInt
GL_CLAMP_TO_EDGE: extern const UInt
GL_MIRRORED_REPEAT: extern const UInt

/* Uniform Types */
GL_FLOAT_VEC2: extern const UInt
GL_FLOAT_VEC3: extern const UInt
GL_FLOAT_VEC4: extern const UInt
GL_INT_VEC2: extern const UInt
GL_INT_VEC3: extern const UInt
GL_INT_VEC4: extern const UInt
GL_BOOL: extern const UInt
GL_BOOL_VEC2: extern const UInt
GL_BOOL_VEC3: extern const UInt
GL_BOOL_VEC4: extern const UInt
GL_FLOAT_MAT2: extern const UInt
GL_FLOAT_MAT3: extern const UInt
GL_FLOAT_MAT4: extern const UInt
GL_SAMPLER_2D: extern const UInt
GL_SAMPLER_CUBE: extern const UInt

/* Vertex Arrays */
GL_VERTEX_ATTRIB_ARRAY_ENABLED: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_SIZE: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_STRIDE: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_TYPE: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_NORMALIZED: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_POINTER: extern const UInt
GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING: extern const UInt

/* Read Format */
GL_IMPLEMENTATION_COLOR_READ_TYPE: extern const UInt
GL_IMPLEMENTATION_COLOR_READ_FORMAT: extern const UInt

/* Shader Source */
GL_COMPILE_STATUS: extern const UInt
GL_INFO_LOG_LENGTH: extern const UInt
GL_SHADER_SOURCE_LENGTH: extern const UInt
GL_SHADER_COMPILER: extern const UInt

/* Shader Binary */
GL_SHADER_BINARY_FORMATS: extern const UInt
GL_NUM_SHADER_BINARY_FORMATS: extern const UInt

/* Shader Precision-Specified Types */
GL_LOW_FLOAT: extern const UInt
GL_MEDIUM_FLOAT: extern const UInt
GL_HIGH_FLOAT: extern const UInt
GL_LOW_INT: extern const UInt
GL_MEDIUM_INT: extern const UInt
GL_HIGH_INT: extern const UInt

/* Framebuffer Object. */
GL_FRAMEBUFFER: extern const UInt
GL_RENDERBUFFER: extern const UInt

GL_RGBA4: extern const UInt
GL_RGB5_A1: extern const UInt
GL_RGB565: extern const UInt
GL_DEPTH_COMPONENT16: extern const UInt
GL_STENCIL_INDEX8: extern const UInt

GL_RENDERBUFFER_WIDTH: extern const UInt
GL_RENDERBUFFER_HEIGHT: extern const UInt
GL_RENDERBUFFER_INTERNAL_FORMAT: extern const UInt
GL_RENDERBUFFER_RED_SIZE: extern const UInt
GL_RENDERBUFFER_GREEN_SIZE: extern const UInt
GL_RENDERBUFFER_BLUE_SIZE: extern const UInt
GL_RENDERBUFFER_ALPHA_SIZE: extern const UInt
GL_RENDERBUFFER_DEPTH_SIZE: extern const UInt
GL_RENDERBUFFER_STENCIL_SIZE: extern const UInt

GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL: extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE: extern const UInt

GL_COLOR_ATTACHMENT0: extern const UInt
GL_DEPTH_ATTACHMENT: extern const UInt
GL_STENCIL_ATTACHMENT: extern const UInt

GL_NONE: extern const UInt

GL_FRAMEBUFFER_COMPLETE: extern const UInt
GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT             : extern const UInt
GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT     : extern const UInt
GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS             : extern const UInt
GL_FRAMEBUFFER_UNSUPPORTED                       : extern const UInt

GL_FRAMEBUFFER_BINDING                           : extern const UInt
GL_RENDERBUFFER_BINDING                          : extern const UInt
GL_MAX_RENDERBUFFER_SIZE                         : extern const UInt

GL_INVALID_FRAMEBUFFER_OPERATION                 : extern const UInt

/* OpenGL ES 3.0 */

GL_READ_BUFFER                                   : extern const UInt
GL_UNPACK_ROW_LENGTH                             : extern const UInt
GL_UNPACK_SKIP_ROWS                              : extern const UInt
GL_UNPACK_SKIP_PIXELS                            : extern const UInt
GL_PACK_ROW_LENGTH                               : extern const UInt
GL_PACK_SKIP_ROWS                                : extern const UInt
GL_PACK_SKIP_PIXELS                              : extern const UInt
GL_COLOR                                         : extern const UInt
GL_DEPTH                                         : extern const UInt
GL_STENCIL                                       : extern const UInt
GL_RED                                           : extern const UInt
GL_RGB8                                          : extern const UInt
GL_RGBA8                                         : extern const UInt
GL_RGB10_A2                                      : extern const UInt
GL_TEXTURE_BINDING_3D                            : extern const UInt
GL_UNPACK_SKIP_IMAGES                            : extern const UInt
GL_UNPACK_IMAGE_HEIGHT                           : extern const UInt
GL_TEXTURE_3D                                    : extern const UInt
GL_TEXTURE_WRAP_R                                : extern const UInt
GL_MAX_3D_TEXTURE_SIZE                           : extern const UInt
GL_UNSIGNED_INT_2_10_10_10_REV                   : extern const UInt
GL_MAX_ELEMENTS_VERTICES                         : extern const UInt
GL_MAX_ELEMENTS_INDICES                          : extern const UInt
GL_TEXTURE_MIN_LOD                               : extern const UInt
GL_TEXTURE_MAX_LOD                               : extern const UInt
GL_TEXTURE_BASE_LEVEL                            : extern const UInt
GL_TEXTURE_MAX_LEVEL                             : extern const UInt
GL_MIN                                           : extern const UInt
GL_MAX                                           : extern const UInt
GL_DEPTH_COMPONENT24                             : extern const UInt
GL_MAX_TEXTURE_LOD_BIAS                          : extern const UInt
GL_TEXTURE_COMPARE_MODE                          : extern const UInt
GL_TEXTURE_COMPARE_FUNC                          : extern const UInt
GL_CURRENT_QUERY                                 : extern const UInt
GL_QUERY_RESULT                                  : extern const UInt
GL_QUERY_RESULT_AVAILABLE                        : extern const UInt
GL_BUFFER_MAPPED                                 : extern const UInt
GL_BUFFER_MAP_POINTER                            : extern const UInt
GL_STREAM_READ                                   : extern const UInt
GL_STREAM_COPY                                   : extern const UInt
GL_STATIC_READ                                   : extern const UInt
GL_STATIC_COPY                                   : extern const UInt
GL_DYNAMIC_READ                                  : extern const UInt
GL_DYNAMIC_COPY                                  : extern const UInt
GL_MAX_DRAW_BUFFERS                              : extern const UInt
GL_DRAW_BUFFER0                                  : extern const UInt
GL_DRAW_BUFFER1                                  : extern const UInt
GL_DRAW_BUFFER2                                  : extern const UInt
GL_DRAW_BUFFER3                                  : extern const UInt
GL_DRAW_BUFFER4                                  : extern const UInt
GL_DRAW_BUFFER5                                  : extern const UInt
GL_DRAW_BUFFER6                                  : extern const UInt
GL_DRAW_BUFFER7                                  : extern const UInt
GL_DRAW_BUFFER8                                  : extern const UInt
GL_DRAW_BUFFER9                                  : extern const UInt
GL_DRAW_BUFFER10                                 : extern const UInt
GL_DRAW_BUFFER11                                 : extern const UInt
GL_DRAW_BUFFER12                                 : extern const UInt
GL_DRAW_BUFFER13                                 : extern const UInt
GL_DRAW_BUFFER14                                 : extern const UInt
GL_DRAW_BUFFER15                                 : extern const UInt
GL_MAX_FRAGMENT_UNIFORM_COMPONENTS               : extern const UInt
GL_MAX_VERTEX_UNIFORM_COMPONENTS                 : extern const UInt
GL_SAMPLER_3D                                    : extern const UInt
GL_SAMPLER_2D_SHADOW                             : extern const UInt
GL_FRAGMENT_SHADER_DERIVATIVE_HINT               : extern const UInt
GL_PIXEL_PACK_BUFFER                             : extern const UInt
GL_PIXEL_UNPACK_BUFFER                           : extern const UInt
GL_PIXEL_PACK_BUFFER_BINDING                     : extern const UInt
GL_PIXEL_UNPACK_BUFFER_BINDING                   : extern const UInt
GL_FLOAT_MAT2x3                                  : extern const UInt
GL_FLOAT_MAT2x4                                  : extern const UInt
GL_FLOAT_MAT3x2                                  : extern const UInt
GL_FLOAT_MAT3x4                                  : extern const UInt
GL_FLOAT_MAT4x2                                  : extern const UInt
GL_FLOAT_MAT4x3                                  : extern const UInt
GL_SRGB                                          : extern const UInt
GL_SRGB8                                         : extern const UInt
GL_SRGB8_ALPHA8                                  : extern const UInt
GL_COMPARE_REF_TO_TEXTURE                        : extern const UInt
GL_MAJOR_VERSION                                 : extern const UInt
GL_MINOR_VERSION                                 : extern const UInt
GL_NUM_EXTENSIONS                                : extern const UInt
GL_RGBA32F                                       : extern const UInt
GL_RGB32F                                        : extern const UInt
GL_RGBA16F                                       : extern const UInt
GL_RGB16F                                        : extern const UInt
GL_VERTEX_ATTRIB_ARRAY_INTEGER                   : extern const UInt
GL_MAX_ARRAY_TEXTURE_LAYERS                      : extern const UInt
GL_MIN_PROGRAM_TEXEL_OFFSET                      : extern const UInt
GL_MAX_PROGRAM_TEXEL_OFFSET                      : extern const UInt
GL_MAX_VARYING_COMPONENTS                        : extern const UInt
GL_TEXTURE_2D_ARRAY                              : extern const UInt
GL_TEXTURE_BINDING_2D_ARRAY                      : extern const UInt
GL_R11F_G11F_B10F                                : extern const UInt
GL_UNSIGNED_INT_10F_11F_11F_REV                  : extern const UInt
GL_RGB9_E5                                       : extern const UInt
GL_UNSIGNED_INT_5_9_9_9_REV                      : extern const UInt
GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH         : extern const UInt
GL_TRANSFORM_FEEDBACK_BUFFER_MODE                : extern const UInt
GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS    : extern const UInt
GL_TRANSFORM_FEEDBACK_VARYINGS                   : extern const UInt
GL_TRANSFORM_FEEDBACK_BUFFER_START               : extern const UInt
GL_TRANSFORM_FEEDBACK_BUFFER_SIZE                : extern const UInt
GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN         : extern const UInt
GL_RASTERIZER_DISCARD                            : extern const UInt
GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS : extern const UInt
GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS       : extern const UInt
GL_INTERLEAVED_ATTRIBS                           : extern const UInt
GL_SEPARATE_ATTRIBS                              : extern const UInt
GL_TRANSFORM_FEEDBACK_BUFFER                     : extern const UInt
GL_TRANSFORM_FEEDBACK_BUFFER_BINDING             : extern const UInt
GL_RGBA32UI                                      : extern const UInt
GL_RGB32UI                                       : extern const UInt
GL_RGBA16UI                                      : extern const UInt
GL_RGB16UI                                       : extern const UInt
GL_RGBA8UI                                       : extern const UInt
GL_RGB8UI                                        : extern const UInt
GL_RGBA32I                                       : extern const UInt
GL_RGB32I                                        : extern const UInt
GL_RGBA16I                                       : extern const UInt
GL_RGB16I                                        : extern const UInt
GL_RGBA8I                                        : extern const UInt
GL_RGB8I                                         : extern const UInt
GL_RED_INTEGER                                   : extern const UInt
GL_RGB_INTEGER                                   : extern const UInt
GL_RGBA_INTEGER                                  : extern const UInt
GL_SAMPLER_2D_ARRAY                              : extern const UInt
GL_SAMPLER_2D_ARRAY_SHADOW                       : extern const UInt
GL_SAMPLER_CUBE_SHADOW                           : extern const UInt
GL_UNSIGNED_INT_VEC2                             : extern const UInt
GL_UNSIGNED_INT_VEC3                             : extern const UInt
GL_UNSIGNED_INT_VEC4                             : extern const UInt
GL_INT_SAMPLER_2D                                : extern const UInt
GL_INT_SAMPLER_3D                                : extern const UInt
GL_INT_SAMPLER_CUBE                              : extern const UInt
GL_INT_SAMPLER_2D_ARRAY                          : extern const UInt
GL_UNSIGNED_INT_SAMPLER_2D                       : extern const UInt
GL_UNSIGNED_INT_SAMPLER_3D                       : extern const UInt
GL_UNSIGNED_INT_SAMPLER_CUBE                     : extern const UInt
GL_UNSIGNED_INT_SAMPLER_2D_ARRAY                 : extern const UInt
GL_BUFFER_ACCESS_FLAGS                           : extern const UInt
GL_BUFFER_MAP_LENGTH                             : extern const UInt
GL_BUFFER_MAP_OFFSET                             : extern const UInt
GL_DEPTH_COMPONENT32F                            : extern const UInt
GL_DEPTH32F_STENCIL8                             : extern const UInt
GL_FLOAT_32_UNSIGNED_INT_24_8_REV                : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING         : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE         : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE               : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE             : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE              : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE             : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE             : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE           : extern const UInt
GL_FRAMEBUFFER_DEFAULT                           : extern const UInt
GL_FRAMEBUFFER_UNDEFINED                         : extern const UInt
GL_DEPTH_STENCIL_ATTACHMENT                      : extern const UInt
GL_DEPTH_STENCIL                                 : extern const UInt
GL_UNSIGNED_INT_24_8                             : extern const UInt
GL_DEPTH24_STENCIL8                              : extern const UInt
GL_UNSIGNED_NORMALIZED                           : extern const UInt
GL_DRAW_FRAMEBUFFER_BINDING                      : extern const UInt
GL_READ_FRAMEBUFFER                              : extern const UInt
GL_DRAW_FRAMEBUFFER                              : extern const UInt
GL_READ_FRAMEBUFFER_BINDING                      : extern const UInt
GL_RENDERBUFFER_SAMPLES                          : extern const UInt
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER          : extern const UInt
GL_MAX_COLOR_ATTACHMENTS                         : extern const UInt
GL_COLOR_ATTACHMENT1                             : extern const UInt
GL_COLOR_ATTACHMENT2                             : extern const UInt
GL_COLOR_ATTACHMENT3                             : extern const UInt
GL_COLOR_ATTACHMENT4                             : extern const UInt
GL_COLOR_ATTACHMENT5                             : extern const UInt
GL_COLOR_ATTACHMENT6                             : extern const UInt
GL_COLOR_ATTACHMENT7                             : extern const UInt
GL_COLOR_ATTACHMENT8                             : extern const UInt
GL_COLOR_ATTACHMENT9                             : extern const UInt
GL_COLOR_ATTACHMENT10                            : extern const UInt
GL_COLOR_ATTACHMENT11                            : extern const UInt
GL_COLOR_ATTACHMENT12                            : extern const UInt
GL_COLOR_ATTACHMENT13                            : extern const UInt
GL_COLOR_ATTACHMENT14                            : extern const UInt
GL_COLOR_ATTACHMENT15                            : extern const UInt
GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE            : extern const UInt
GL_MAX_SAMPLES                                   : extern const UInt
GL_HALF_FLOAT                                    : extern const UInt
GL_MAP_READ_BIT                                  : extern const UInt
GL_MAP_WRITE_BIT                                 : extern const UInt
GL_MAP_INVALIDATE_RANGE_BIT                      : extern const UInt
GL_MAP_INVALIDATE_BUFFER_BIT                     : extern const UInt
GL_MAP_FLUSH_EXPLICIT_BIT                        : extern const UInt
GL_MAP_UNSYNCHRONIZED_BIT                        : extern const UInt
GL_RG                                            : extern const UInt
GL_RG_INTEGER                                    : extern const UInt
GL_R8                                            : extern const UInt
GL_RG8                                           : extern const UInt
GL_R16F                                          : extern const UInt
GL_R32F                                          : extern const UInt
GL_RG16F                                         : extern const UInt
GL_RG32F                                         : extern const UInt
GL_R8I                                           : extern const UInt
GL_R8UI                                          : extern const UInt
GL_R16I                                          : extern const UInt
GL_R16UI                                         : extern const UInt
GL_R32I                                          : extern const UInt
GL_R32UI                                         : extern const UInt
GL_RG8I                                          : extern const UInt
GL_RG8UI                                         : extern const UInt
GL_RG16I                                         : extern const UInt
GL_RG16UI                                        : extern const UInt
GL_RG32I                                         : extern const UInt
GL_RG32UI                                        : extern const UInt
GL_VERTEX_ARRAY_BINDING                          : extern const UInt
GL_R8_SNORM                                      : extern const UInt
GL_RG8_SNORM                                     : extern const UInt
GL_RGB8_SNORM                                    : extern const UInt
GL_RGBA8_SNORM                                   : extern const UInt
GL_SIGNED_NORMALIZED                             : extern const UInt
GL_PRIMITIVE_RESTART_FIXED_INDEX                 : extern const UInt
GL_COPY_READ_BUFFER                              : extern const UInt
GL_COPY_WRITE_BUFFER                             : extern const UInt
GL_COPY_READ_BUFFER_BINDING                      : extern const UInt
GL_COPY_WRITE_BUFFER_BINDING                     : extern const UInt
GL_UNIFORM_BUFFER                                : extern const UInt
GL_UNIFORM_BUFFER_BINDING                        : extern const UInt
GL_UNIFORM_BUFFER_START                          : extern const UInt
GL_UNIFORM_BUFFER_SIZE                           : extern const UInt
GL_MAX_VERTEX_UNIFORM_BLOCKS                     : extern const UInt
GL_MAX_FRAGMENT_UNIFORM_BLOCKS                   : extern const UInt
GL_MAX_COMBINED_UNIFORM_BLOCKS                   : extern const UInt
GL_MAX_UNIFORM_BUFFER_BINDINGS                   : extern const UInt
GL_MAX_UNIFORM_BLOCK_SIZE                        : extern const UInt
GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS        : extern const UInt
GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS      : extern const UInt
GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT               : extern const UInt
GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH          : extern const UInt
GL_ACTIVE_UNIFORM_BLOCKS                         : extern const UInt
GL_UNIFORM_TYPE                                  : extern const UInt
GL_UNIFORM_SIZE                                  : extern const UInt
GL_UNIFORM_NAME_LENGTH                           : extern const UInt
GL_UNIFORM_BLOCK_INDEX                           : extern const UInt
GL_UNIFORM_OFFSET                                : extern const UInt
GL_UNIFORM_ARRAY_STRIDE                          : extern const UInt
GL_UNIFORM_MATRIX_STRIDE                         : extern const UInt
GL_UNIFORM_IS_ROW_MAJOR                          : extern const UInt
GL_UNIFORM_BLOCK_BINDING                         : extern const UInt
GL_UNIFORM_BLOCK_DATA_SIZE                       : extern const UInt
GL_UNIFORM_BLOCK_NAME_LENGTH                     : extern const UInt
GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS                 : extern const UInt
GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES          : extern const UInt
GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER     : extern const UInt
GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER   : extern const UInt
GL_INVALID_INDEX                                 : extern const UInt
GL_MAX_VERTEX_OUTPUT_COMPONENTS                  : extern const UInt
GL_MAX_FRAGMENT_INPUT_COMPONENTS                 : extern const UInt
GL_MAX_SERVER_WAIT_TIMEOUT                       : extern const UInt
GL_OBJECT_TYPE                                   : extern const UInt
GL_SYNC_CONDITION                                : extern const UInt
GL_SYNC_STATUS                                   : extern const UInt
GL_SYNC_FLAGS                                    : extern const UInt
GL_SYNC_FENCE                                    : extern const UInt
GL_SYNC_GPU_COMMANDS_COMPLETE                    : extern const UInt
GL_UNSIGNALED                                    : extern const UInt
GL_SIGNALED                                      : extern const UInt
GL_ALREADY_SIGNALED                              : extern const UInt
GL_TIMEOUT_EXPIRED                               : extern const UInt
GL_CONDITION_SATISFIED                           : extern const UInt
GL_WAIT_FAILED                                   : extern const UInt
GL_SYNC_FLUSH_COMMANDS_BIT                       : extern const UInt
GL_TIMEOUT_IGNORED                               : extern const UInt
GL_VERTEX_ATTRIB_ARRAY_DIVISOR                   : extern const UInt
GL_ANY_SAMPLES_PASSED                            : extern const UInt
GL_ANY_SAMPLES_PASSED_CONSERVATIVE               : extern const UInt
GL_SAMPLER_BINDING                               : extern const UInt
GL_RGB10_A2UI                                    : extern const UInt
GL_TEXTURE_SWIZZLE_R                             : extern const UInt
GL_TEXTURE_SWIZZLE_G                             : extern const UInt
GL_TEXTURE_SWIZZLE_B                             : extern const UInt
GL_TEXTURE_SWIZZLE_A                             : extern const UInt
GL_GREEN                                         : extern const UInt
GL_BLUE                                          : extern const UInt
GL_INT_2_10_10_10_REV                            : extern const UInt
GL_TRANSFORM_FEEDBACK                            : extern const UInt
GL_TRANSFORM_FEEDBACK_PAUSED                     : extern const UInt
GL_TRANSFORM_FEEDBACK_ACTIVE                     : extern const UInt
GL_TRANSFORM_FEEDBACK_BINDING                    : extern const UInt
GL_PROGRAM_BINARY_RETRIEVABLE_HINT               : extern const UInt
GL_PROGRAM_BINARY_LENGTH                         : extern const UInt
GL_NUM_PROGRAM_BINARY_FORMATS                    : extern const UInt
GL_PROGRAM_BINARY_FORMATS                        : extern const UInt
GL_COMPRESSED_R11_EAC                            : extern const UInt
GL_COMPRESSED_SIGNED_R11_EAC                     : extern const UInt
GL_COMPRESSED_RG11_EAC                           : extern const UInt
GL_COMPRESSED_SIGNED_RG11_EAC                    : extern const UInt
GL_COMPRESSED_RGB8_ETC2                          : extern const UInt
GL_COMPRESSED_SRGB8_ETC2                         : extern const UInt
GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2      : extern const UInt
GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2     : extern const UInt
GL_COMPRESSED_RGBA8_ETC2_EAC                     : extern const UInt
GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC              : extern const UInt
GL_TEXTURE_IMMUTABLE_FORMAT                      : extern const UInt
GL_MAX_ELEMENT_INDEX                             : extern const UInt
GL_NUM_SAMPLE_COUNTS                             : extern const UInt
GL_TEXTURE_IMMUTABLE_LEVELS                      : extern const UInt

/* OpenGL ES 2.0 */

glActiveTexture: extern func(texture: UInt)
glAttachShader: extern func(program: UInt, shader: UInt)
glBindAttribLocation: extern func(program: UInt, index: UInt, name: Char*)
glBindBuffer: extern func (target: UInt, buffer: UInt)
glBindFramebuffer: extern func (target: UInt, framebuffer: UInt)
glBindRenderbuffer: extern func (target: UInt, renderbuffer: UInt)
glBindTexture: extern func (target: UInt, texture: UInt)
glBlendColor: extern func (red: Float, green: Float, blue: Float, alpha: Float)
glBlendEquation: extern func (mode: UInt)
glBlendEquationSeparate: extern func (modeRGB: UInt, modeAlpha: UInt)
glBlendFunc: extern func (sfactor: UInt, dfactor: UInt)
glBlendFuncSeparate: extern func (srcRGB: UInt, dstRGB: UInt, srcAlpha: UInt, dstAlpha: UInt)
glBufferData: extern func (target: UInt, size: Long, data: Pointer, usage: UInt)
glBufferSubData: extern func (target: UInt, offset: Int32, size: Int32, data: Pointer)
glCheckFramebufferStatus: extern func(target: UInt) -> UInt
glClear: extern func (mask: UInt)
glClearColor: extern func (red: Float, green: Float, blue: Float, alpha: Float)
glClearDepthf: extern func (depth: Float)
glClearStencil: extern func (s: Int)
glColorMask: extern func (red: UInt, green: UInt, blue: UInt, alpha: UInt)
glCompileShader: extern func (shader: UInt)
glCompressedTexImage2D: extern func (target: UInt, level: Int, internalformat: UInt, width: Int, height: Int, border: Int, imageSize: Int, data: Pointer)
glCompressedTexSubImage2D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, width: Int, height: Int, format: UInt, imageSize: Int, data: Pointer)
glCopyTexImage2D: extern func (target: UInt, level: Int, internalformat: UInt, x: Int, y: Int, width: Int, height: Int, border: Int)
glCopyTexSubImage2D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, x: Int, y: Int, width: Int, height: Int)
glCreateProgram: extern func () -> UInt
glCreateShader: extern func (type: UInt) -> UInt
glCullFace: extern func (mode: UInt)
glDeleteBuffers: extern func (n: Int, buffers: UInt*)
glDeleteFramebuffers: extern func (n: Int, framebuffers: UInt*)
glDeleteProgram: extern func (program: UInt)
glDeleteRenderbuffers: extern func (n: Int, renderbuffers: UInt*)
glDeleteShader: extern func (shader: UInt)
glDeleteTextures: extern func (n: Int, textures: UInt*)
glDepthFunc: extern func (function: UInt)
glDepthMask: extern func (flag: UInt)
glDepthRangef: extern func (n: Float, f: Float)
glDetachShader: extern func (program: UInt, shader: UInt)
glDisable: extern func (cap: UInt)
glDisableVertexAttribArray: extern func (index: UInt)
glDrawArrays: extern func (mode: UInt, first: Int, count: Int)
glDrawElements: extern func (mode: UInt, count: UInt, type: UInt, indices: Pointer)
glEnable: extern func (cap: UInt)
glEnableVertexAttribArray: extern func (index: UInt)
glFinish: extern func ()
glFlush: extern func ()
glFramebufferRenderbuffer: extern func (target: UInt, attachment: UInt, renderbuffertarget: UInt, renderbuffer: UInt)
glFramebufferTexture2D: extern func (target: UInt, attachment: UInt, textarget: UInt, texture: UInt, level: Int)
glFrontFace: extern func (mode: UInt)
glGenBuffers: extern func (n: Int, buffers: UInt*)
glGenerateMipmap: extern func (target: UInt)
glGenFramebuffers: extern func (n: Int, framebuffers: UInt*)
glGenRenderbuffers: extern func (n: Int, renderbuffers: UInt*)
glGenTextures: extern func (n: Int, textures: UInt*)
glGetActiveAttrib: extern func (program: UInt, index: UInt, bufsize: Int, length: Int*, size: UInt*, type: UInt*, name: Char*)
glGetActiveUniform: extern func (program: UInt, index: UInt, bufsize: Int, length: Int*, size: Int*, type: UInt*, name: Char*)
glGetAttachedShaders: extern func (program: UInt, maxcount: Int, count: Int*, shaders: UInt*)
glGetAttribLocation: extern func (program: UInt, name: Char*) -> Int
glGetBooleanv: extern func (pname: UInt, params: UInt*)
glGetBufferParameteriv: extern func (target: UInt, pname: UInt, params: Int*)
glGetError: extern func () -> UInt
glGetFloatv: extern func (pname: UInt, params: Float*)
glGetFramebufferAttachmentParameteriv: extern func (target: UInt, attachment: UInt, pname: UInt, params: Int*)
glGetIntegerv: extern func (pname: UInt, params: Int*)
glGetProgramiv: extern func (program: UInt, pname: UInt, params: Int*)
glGetProgramInfoLog: extern func (program: UInt, bufsize: Int*, length: Int*, infolog: Char*)
glGetRenderbufferParameteriv: extern func (target: UInt, pname: UInt, params: Int*)
glGetShaderiv: extern func (shader: UInt, pname: UInt, params: Int*)
glGetShaderInfoLog: extern func (shader: UInt, bufsize: Int, length: Int*, infolog: Char*)
glGetShaderPrecisionFormat: extern func (shadertype: UInt, precisiontype: UInt, range: Int*, precision: Int*)
glGetShaderSource: extern func (shader: UInt, bufsize: Int, length: Int*, source: Char*)
glGetString: extern func (name: UInt) -> Char*
glGetTexParameterfv: extern func (target: UInt, pname: UInt, params: Float*)
glGetTexParameteriv: extern func (target: UInt, pname: UInt, params: Int*)
glGetUniformfv: extern func (program: UInt, location: Int, params: Float*)
glGetUniformiv: extern func (program: UInt, location: Int, params: Int*)
glGetUniformLocation: extern func (program: UInt, name: Char*) -> Int
glGetVertexAttribfv: extern func (index: UInt, pname: UInt, params: Float*)
glGetVertexAttribiv: extern func (index: UInt, pname: UInt, params: Int*)
glGetVertexAttribPointerv: extern func (index: UInt, pname: UInt, pointer: Pointer*)
glHint: extern func (target: UInt, mode: UInt)
glIsBuffer: extern func (buffer: UInt) -> UInt
glIsEnabled: extern func (cap: UInt) -> UInt
glIsFramebuffer: extern func (framebuffer: UInt) -> UInt
glIsProgram: extern func (program: UInt) -> UInt
glIsRenderbuffer: extern func (renderbuffer: UInt) -> UInt
glIsShader: extern func (shader: UInt) -> UInt
glIsTexture: extern func (texture: UInt) -> UInt
glLineWidth: extern func (width: Float)
glLinkProgram: extern func (program: UInt)
glPixelStorei: extern func (pname: UInt, param: Int)
glPolygonOffset: extern func (factor: Float, units: Float)
glReadPixels: extern func (x: Int, y: Int, width: Int, height: Int, format: UInt, type: UInt, pixels: Pointer)
glReleaseShaderCompiler: extern func ()
glRenderbufferStorage: extern func (target: UInt, internalformat: UInt, width: Int, height: Int)
glSampleCoverage: extern func (value: Float, invert: UInt)
glScissor: extern func (x: Int, y: Int, width: Int, height: Int)
glShaderBinary: extern func (n: Int, shaders: UInt*, binaryformat: UInt, binary: Pointer, length: Int)
glShaderSource: extern func (shader: UInt, count: Int, string: Char**, length: Pointer)
glStencilFunc: extern func (function: UInt, ref: Int, mask: UInt)
glStencilFuncSeparate: extern func (face: UInt, function: UInt, ref: Int, mask: UInt)
glStencilMask: extern func (mask: UInt)
glStencilMaskSeparate: extern func (face: UInt, mask: UInt)
glStencilOp: extern func (fail: UInt, zfail: UInt, zpass: UInt)
glStencilOpSeparate: extern func (face: UInt, fail: UInt, zfail: UInt, zpass: UInt)
glTexImage2D: extern func (target: UInt, level: Int, internalformat: Int, width: Int, height: Int, border: Int, format: UInt, type: UInt, pixels: Pointer)
glTexParameterf: extern func (target: UInt, pname: UInt, param: Float)
glTexParameterfv: extern func (target: UInt, pname: UInt, params: Float*)
glTexParameteri: extern func (target: UInt, pname: UInt, param: Int)
glTexParameteriv: extern func (target: UInt, pname: UInt, params: Int*)
glTexSubImage2D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, width: Int, height: Int, format: UInt, type: UInt, pixels: Pointer)
glUniform1f: extern func (location: Int, x: Float)
glUniform1fv: extern func (location: Int, count: Int, v: Float*)
glUniform1i: extern func (location: Int, x: Int)
glUniform1iv: extern func (location: Int, count: Int, v: Int*)
glUniform2f: extern func (location: Int, x: Float, y: Float)
glUniform2fv: extern func (location: Int, count: Int, v: Float*)
glUniform2i: extern func (location: Int, x: Int, y: Int)
glUniform2iv: extern func (location: Int, count: Int, v: Int*)
glUniform3f: extern func (location: Int, x: Float, y: Float, z: Float)
glUniform3fv: extern func (location: Int, count: Int, v: Float*)
glUniform3i: extern func (location: Int, x: Int, y: Int, z: Int)
glUniform3iv: extern func (location: Int, count: Int, v: Int*)
glUniform4f: extern func (location: Int, x: Float, y: Float, z: Float, w: Float)
glUniform4fv: extern func (location: Int, count: Int, v: Float*)
glUniform4i: extern func (location: Int, x: Int, y: Int, z: Int, w: Int)
glUniform4iv: extern func (location: Int, count: Int, v: Int*)
glUniformMatrix2fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix3fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix4fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUseProgram: extern func (program: UInt)
glValidateProgram: extern func (program: UInt)
glVertexAttrib1f: extern func (indx: UInt, x: Float)
glVertexAttrib1fv: extern func (indx: UInt, values: Float*)
glVertexAttrib2f: extern func (indx: UInt, x: Float, y: Float)
glVertexAttrib2fv: extern func (indx: UInt, values: Float*)
glVertexAttrib3f: extern func (indx: UInt, x: Float, y: Float, z: Float)
glVertexAttrib3fv: extern func (indx: UInt, values: Float*)
glVertexAttrib4f: extern func (indx: UInt, x: Float, y: Float, z: Float, w: Float)
glVertexAttrib4fv: extern func (indx: UInt, values: Float*)
glVertexAttribPointer: extern func (indx: UInt, size: Int, type: UInt, normalized: UInt, stride: Int, ptr: Pointer)
glViewport: extern func (x: Int, y: Int, width: Int, height: Int)

/* OpenGL ES 3.0 */

glReadBuffer: extern func (mode: UInt)
glDrawRangeElements: extern func (mode: UInt, start: UInt, end: UInt, count: Int, type: UInt, indices: Pointer)
glTexImage3D: extern func (target: UInt, level: Int, internalformat: Int, width: Int, height: Int, depth: Int, border: Int, format: UInt, type: UInt, pixels: Pointer)
glTexSubImage3D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Int, height: Int, depth: Int, format: UInt, type: UInt, pixels: Pointer)
glCopyTexSubImage3D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, x: Int, y: Int, width: Int, height: Int)
glCompressedTexImage3D: extern func (target: UInt, level: Int, internalformat: UInt, width: Int, height: Int, depth: Int, border: Int, imageSize: Int, data: Pointer)
glCompressedTexSubImage3D: extern func (target: UInt, level: Int, xoffset: Int, yoffset: Int, zoffset: Int, width: Int, height: Int, depth: Int, format: UInt, imageSize: Int, data: Pointer)
glGenQueries: extern func (n: Int, ids: UInt*)
glDeleteQueries: extern func (n: Int, ids: UInt*)
glIsQuery: extern func (id: UInt) -> UInt
glBeginQuery: extern func (target: UInt, id: UInt)
glEndQuery: extern func (target: UInt)
glGetQueryiv: extern func (target: UInt, pname: UInt, params: Int*)
glGetQueryObjectuiv: extern func (id: UInt, pname: UInt, params: UInt*)
glUnmapBuffer: extern func (target: UInt) -> UInt
glGetBufferPointerv: extern func (target: UInt, pname: UInt, params: Pointer*)
glDrawBuffers: extern func (n: Int, bufs: UInt*)
glUniformMatrix2x3fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix3x2fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix2x4fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix4x2fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix3x4fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glUniformMatrix4x3fv: extern func (location: Int, count: Int, transpose: UInt, value: Float*)
glBlitFramebuffer: extern func (srcX0: Int, srcY0: Int, srcX1: Int, srcY1: Int, dstX0: Int, dstY0: Int, dstX1: Int, dstY1: Int, mask: UInt, filter: UInt)
glRenderbufferStorageMultisample: extern func (target: UInt, samples: Int, internalformat: UInt, width: Int, height: Int)
glFramebufferTextureLayer: extern func (target: UInt, attachment: UInt, texture: UInt, level: Int, layer: Int)
glMapBufferRange: extern func (target: UInt, offset: Int32, length: Int32, access: UInt) -> Pointer
glFlushMappedBufferRange: extern func (target: UInt, offset: Int32, length: Int32)
glBindVertexArray: extern func (array: UInt)
glDeleteVertexArrays: extern func (n: Int, arrays: UInt*)
glGenVertexArrays: extern func (n: Int, arrays: UInt*)
glIsVertexArray: extern func (array: UInt) -> UInt
glGetIntegeri_v: extern func (target: UInt, index: UInt, data: Int*)
glBeginTransformFeedback: extern func (primitiveMode: UInt)
glEndTransformFeedback: extern func ()
glBindBufferRange: extern func (target: UInt, index: UInt, buffer: UInt, offset: Int32, size: Int)
glBindBufferBase: extern func (target: UInt, index: UInt, buffer: UInt)
glTransformFeedbackVaryings: extern func (program: UInt, count: Int, varyings: Char**, bufferMode: UInt)
glGetTransformFeedbackVarying: extern func (program: UInt, index: UInt, bufSize: Int, length: Int*, size: Int*, type: UInt*, name: Char*)
glVertexAttribIPointer: extern func (index: UInt, size: Int, type: UInt, stride: Int, pointer: Pointer)
glGetVertexAttribIiv: extern func (index: UInt, pname: UInt, params: Int*)
glGetVertexAttribIuiv: extern func (index: UInt, pname: UInt, params: UInt*)
glVertexAttribI4i: extern func (index: UInt, x: Int, y: Int, z: Int, w: Int)
glVertexAttribI4ui: extern func (index: UInt, x: UInt, y: UInt, z: UInt, w: UInt)
glVertexAttribI4iv: extern func (index: UInt, v: Int*)
glVertexAttribI4uiv: extern func (index: UInt, v: UInt*)
glGetUniformuiv: extern func (program: UInt, location: Int, params: UInt*)
glGetFragDataLocation: extern func (program: UInt, name: Char*) -> Int
glUniform1ui: extern func (location: Int, v0: UInt)
glUniform2ui: extern func (location: Int, v0: UInt, v1: UInt)
glUniform3ui: extern func (location: Int, v0: UInt, v1: UInt, v2: UInt)
glUniform4ui: extern func (location: Int, v0: UInt, v1: UInt, v2: UInt, v3: UInt)
glUniform1uiv: extern func (location: Int, count: Int, value: UInt*)
glUniform2uiv: extern func (location: Int, count: Int, value: UInt*)
glUniform3uiv: extern func (location: Int, count: Int, value: UInt*)
glUniform4uiv: extern func (location: Int, count: Int, value: UInt*)
glClearBufferiv: extern func (buffer: UInt, drawbuffer: Int, value: Int*)
glClearBufferuiv: extern func (buffer: UInt, drawbuffer: Int, value: UInt*)
glClearBufferfv: extern func (buffer: UInt, drawbuffer: Int, value: Float*)
glClearBufferfi: extern func (buffer: UInt, drawbuffer: Int, depth: Float, stencil: Int)
glGetStringi: extern func (name: UInt, index: UInt) -> Char*
glCopyBufferSubData: extern func (readTarget: UInt, writeTarget: UInt, readOffset: Int32, writeOffset: Int32, size: Int)
glGetUniformIndices: extern func (program: UInt, uniformCount: Int, uniformNames: Char**, uniformIndices: UInt*)
glGetActiveUniformsiv: extern func (program: UInt, uniformCount: Int, uniformIndices: UInt*, pname: UInt, params: Int*)
glGetUniformBlockIndex: extern func (program: UInt, uniformBlockName: Char*) -> UInt
glGetActiveUniformBlockiv: extern func (program: UInt, uniformBlockIndex: UInt, pname: UInt, params: Int*)
glGetActiveUniformBlockName: extern func (program: UInt, uniformBlockIndex: UInt, bufSize: Int, length: Int*, uniformBlockName: Char*)
glUniformBlockBinding: extern func (program: UInt, uniformBlockIndex: UInt, uniformBlockBinding: UInt)
glDrawArraysInstanced: extern func (mode: UInt, first: Int, count: Int, instanceCount: Int)
glDrawElementsInstanced: extern func (mode: UInt, count: Int, type: UInt, indices: Pointer, instanceCount: Int)
glFenceSync: extern func (condition: UInt, flags: UInt) -> Pointer
glIsSync: extern func (sync: Pointer) -> UInt
glDeleteSync: extern func (sync: Pointer)
glWaitSync: extern func (sync: Pointer, flags: UInt, timeout: UInt64)

glClientWaitSync: extern func (sync: Pointer, flags: UInt, timeout: UInt64) -> UInt

glGetInteger64v: extern func (pname: UInt, params: Int64*)
glGetSynciv: extern func (sync: Pointer, pname: UInt, bufSize: Int, length: Int*, values: Int*)
glGetInteger64i_v: extern func (target: UInt, index: UInt, data: Int64*)
glGetBufferParameteri64v: extern func (target: UInt, pname: UInt, params: Int64*)
glGenSamplers: extern func (count: Int, samplers: UInt*)
glDeleteSamplers: extern func (count: Int, samplers: UInt*)
glIsSampler: extern func (sampler: UInt) -> UInt
glBindSampler: extern func (unit: UInt, sampler: UInt)
glSamplerParameteri: extern func (sampler: UInt, pname: UInt, param: Int)
glSamplerParameteriv: extern func (sampler: UInt, pname: UInt, param: Int*)
glSamplerParameterf: extern func (sampler: UInt, pname: UInt, param: Float)
glSamplerParameterfv: extern func (sampler: UInt, pname: UInt, param: Float*)
glGetSamplerParameteriv: extern func (sampler: UInt, pname: UInt, params: Int*)
glGetSamplerParameterfv: extern func (sampler: UInt, pname: UInt, params: Float*)
glVertexAttribDivisor: extern func (index: UInt, divisor: UInt)
glBindTransformFeedback: extern func (target: UInt, id: UInt)
glDeleteTransformFeedbacks: extern func (n: Int, ids: UInt*)
glGenTransformFeedbacks: extern func (n: Int, ids: UInt*)
glIsTransformFeedback: extern func (id: UInt) -> UInt
glPauseTransformFeedback: extern func ()
glResumeTransformFeedback: extern func ()
glGetProgramBinary: extern func (program: UInt, bufSize: Int, length: Int*, binaryFormat: UInt*, binary: Pointer)
glProgramBinary: extern func (program: UInt, binaryFormat: UInt, binary: Pointer, length: Int)
glProgramParameteri: extern func (program: UInt, pname: UInt, value: Int)
glInvalidateFramebuffer: extern func (target: UInt, numAttachments: Int, attachments: UInt*)
glInvalidateSubFramebuffer: extern func (target: UInt, numAttachments: Int, attachments: UInt*, x: Int, y: Int, width: Int, height: Int)
glTexStorage2D: extern func (target: UInt, levels: Int, internalformat: UInt, width: Int, height: Int)
glTexStorage3D: extern func (target: UInt, levels: Int, internalformat: UInt, width: Int, height: Int, depth: Int)
glGetInternalformativ: extern func (target: UInt, internalformat: UInt, pname: UInt, bufSize: Int, params: Int*)
