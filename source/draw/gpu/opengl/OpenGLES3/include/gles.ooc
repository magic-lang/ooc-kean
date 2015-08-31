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
GL_TEXTURE_EXTERNAL_OES,
GL_REQUIRED_TEXTURE_IMAGE_UNITS_OES,

/* OpenGL ES core versions */
GL_ES_VERSION_3_0,
GL_ES_VERSION_2_0,

/* OpenGL ES 2.0 */

/* ClearBufferMask */
GL_DEPTH_BUFFER_BIT,
GL_STENCIL_BUFFER_BIT,
GL_COLOR_BUFFER_BIT,

/* Boolean */
GL_FALSE,
GL_TRUE,

/* BeginMode */
GL_POINTS,
GL_LINES,
GL_LINE_LOOP,
GL_LINE_STRIP,
GL_TRIANGLES,
GL_TRIANGLE_STRIP,
GL_TRIANGLE_FAN,

/* BlendingFactorDest */
GL_ZERO,
GL_ONE,
GL_SRC_COLOR,
GL_ONE_MINUS_SRC_COLOR,
GL_SRC_ALPHA,
GL_ONE_MINUS_SRC_ALPHA,
GL_DST_ALPHA,
GL_ONE_MINUS_DST_ALPHA,

/* BlendingFactorSrc */
/*      GL_ZERO */
/*      GL_ONE */
GL_DST_COLOR,
GL_ONE_MINUS_DST_COLOR,
GL_SRC_ALPHA_SATURATE,
/*      GL_SRC_ALPHA */
/*      GL_ONE_MINUS_SRC_ALPHA */
/*      GL_DST_ALPHA */
/*      GL_ONE_MINUS_DST_ALPHA */

/* BlendEquationSeparate */
GL_FUNC_ADD,
GL_BLEND_EQUATION,
GL_BLEND_EQUATION_RGB, /* same as BLEND_EQUATION */
GL_BLEND_EQUATION_ALPHA,

/* BlendSubtract */
GL_FUNC_SUBTRACT,
GL_FUNC_REVERSE_SUBTRACT,

/* Separate Blend Functions */
GL_BLEND_DST_RGB,
GL_BLEND_SRC_RGB,
GL_BLEND_DST_ALPHA,
GL_BLEND_SRC_ALPHA,
GL_CONSTANT_COLOR,
GL_ONE_MINUS_CONSTANT_COLOR,
GL_CONSTANT_ALPHA,
GL_ONE_MINUS_CONSTANT_ALPHA,
GL_BLEND_COLOR,

/* Buffer Objects */
GL_ARRAY_BUFFER,
GL_ELEMENT_ARRAY_BUFFER,
GL_ARRAY_BUFFER_BINDING,
GL_ELEMENT_ARRAY_BUFFER_BINDING,

GL_STREAM_DRAW,
GL_STATIC_DRAW,
GL_DYNAMIC_DRAW,

GL_BUFFER_SIZE,
GL_BUFFER_USAGE,

GL_CURRENT_VERTEX_ATTRIB,

/* CullFaceMode */
GL_FRONT,
GL_BACK,
GL_FRONT_AND_BACK,

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
GL_TEXTURE_2D,
GL_CULL_FACE,
GL_BLEND,
GL_DITHER,
GL_STENCIL_TEST,
GL_DEPTH_TEST,
GL_SCISSOR_TEST,
GL_POLYGON_OFFSET_FILL,
GL_SAMPLE_ALPHA_TO_COVERAGE,
GL_SAMPLE_COVERAGE,

/* ErrorCode */
GL_NO_ERROR,
GL_INVALID_ENUM,
GL_INVALID_VALUE,
GL_INVALID_OPERATION,
GL_OUT_OF_MEMORY,

/* FrontFaceDirection */
GL_CW,
GL_CCW,

/* GetPName */
GL_LINE_WIDTH,
GL_ALIASED_POINT_SIZE_RANGE,
GL_ALIASED_LINE_WIDTH_RANGE,
GL_CULL_FACE_MODE,
GL_FRONT_FACE,
GL_DEPTH_RANGE,
GL_DEPTH_WRITEMASK,
GL_DEPTH_CLEAR_VALUE,
GL_DEPTH_FUNC,
GL_STENCIL_CLEAR_VALUE,
GL_STENCIL_FUNC,
GL_STENCIL_FAIL,
GL_STENCIL_PASS_DEPTH_FAIL,
GL_STENCIL_PASS_DEPTH_PASS,
GL_STENCIL_REF,
GL_STENCIL_VALUE_MASK,
GL_STENCIL_WRITEMASK,
GL_STENCIL_BACK_FUNC,
GL_STENCIL_BACK_FAIL,
GL_STENCIL_BACK_PASS_DEPTH_FAIL,
GL_STENCIL_BACK_PASS_DEPTH_PASS,
GL_STENCIL_BACK_REF,
GL_STENCIL_BACK_VALUE_MASK,
GL_STENCIL_BACK_WRITEMASK,
GL_VIEWPORT,
GL_SCISSOR_BOX,
/*      GL_SCISSOR_TEST */
GL_COLOR_CLEAR_VALUE,
GL_COLOR_WRITEMASK,
GL_UNPACK_ALIGNMENT,
GL_PACK_ALIGNMENT,
GL_MAX_TEXTURE_SIZE,
GL_MAX_VIEWPORT_DIMS,
GL_SUBPIXEL_BITS,
GL_RED_BITS,
GL_GREEN_BITS,
GL_BLUE_BITS,
GL_ALPHA_BITS,
GL_DEPTH_BITS,
GL_STENCIL_BITS,
GL_POLYGON_OFFSET_UNITS,
/*      GL_POLYGON_OFFSET_FILL */
GL_POLYGON_OFFSET_FACTOR,
GL_TEXTURE_BINDING_2D,
GL_SAMPLE_BUFFERS,
GL_SAMPLES,
GL_SAMPLE_COVERAGE_VALUE,
GL_SAMPLE_COVERAGE_INVERT,

/* GetTextureParameter */
/*      GL_TEXTURE_MAG_FILTER */
/*      GL_TEXTURE_MIN_FILTER */
/*      GL_TEXTURE_WRAP_S */
/*      GL_TEXTURE_WRAP_T */

GL_NUM_COMPRESSED_TEXTURE_FORMATS,
GL_COMPRESSED_TEXTURE_FORMATS,

/* HintMode */
GL_DONT_CARE,
GL_FASTEST,
GL_NICEST,

/* HintTarget */
GL_GENERATE_MIPMAP_HINT,

/* DataType */
GL_BYTE,
GL_UNSIGNED_BYTE,
GL_SHORT,
GL_UNSIGNED_SHORT,
GL_INT,
GL_UNSIGNED_INT,
GL_FLOAT,
GL_FIXED,

/* PixelFormat */
GL_DEPTH_COMPONENT,
GL_ALPHA,
GL_RGB,
GL_RGBA,
GL_LUMINANCE,
GL_LUMINANCE_ALPHA,

/* PixelType */
/*      GL_UNSIGNED_BYTE */
GL_UNSIGNED_SHORT_4_4_4_4,
GL_UNSIGNED_SHORT_5_5_5_1,
GL_UNSIGNED_SHORT_5_6_5,

/* Shaders */
GL_FRAGMENT_SHADER,
GL_VERTEX_SHADER,
GL_MAX_VERTEX_ATTRIBS,
GL_MAX_VERTEX_UNIFORM_VECTORS,
GL_MAX_VARYING_VECTORS,
GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS,
GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS,
GL_MAX_TEXTURE_IMAGE_UNITS,
GL_MAX_FRAGMENT_UNIFORM_VECTORS,
GL_SHADER_TYPE,
GL_DELETE_STATUS,
GL_LINK_STATUS,
GL_VALIDATE_STATUS,
GL_ATTACHED_SHADERS,
GL_ACTIVE_UNIFORMS,
GL_ACTIVE_UNIFORM_MAX_LENGTH,
GL_ACTIVE_ATTRIBUTES,
GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
GL_SHADING_LANGUAGE_VERSION,
GL_CURRENT_PROGRAM,

/* StencilFunction */
GL_NEVER,
GL_LESS,
GL_EQUAL,
GL_LEQUAL,
GL_GREATER,
GL_NOTEQUAL,
GL_GEQUAL,
GL_ALWAYS,

/* StencilOp */
/*      GL_ZERO */
GL_KEEP,
GL_REPLACE,
GL_INCR,
GL_DECR,
GL_INVERT,
GL_INCR_WRAP,
GL_DECR_WRAP,

/* StringName */
GL_VENDOR,
GL_RENDERER,
GL_VERSION,
GL_EXTENSIONS,

/* TextureMagFilter */
GL_NEAREST,
GL_LINEAR,

/* TextureMinFilter */
/*      GL_NEAREST */
/*      GL_LINEAR */
GL_NEAREST_MIPMAP_NEAREST,
GL_LINEAR_MIPMAP_NEAREST,
GL_NEAREST_MIPMAP_LINEAR,
GL_LINEAR_MIPMAP_LINEAR,

/* TextureParameterName */
GL_TEXTURE_MAG_FILTER,
GL_TEXTURE_MIN_FILTER,
GL_TEXTURE_WRAP_S,
GL_TEXTURE_WRAP_T,

/* TextureTarget */
/*      GL_TEXTURE_2D */
GL_TEXTURE,

GL_TEXTURE_CUBE_MAP,
GL_TEXTURE_BINDING_CUBE_MAP,
GL_TEXTURE_CUBE_MAP_POSITIVE_X,
GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
GL_MAX_CUBE_MAP_TEXTURE_SIZE,

/* TextureUnit */
GL_TEXTURE0,
GL_TEXTURE1,
GL_TEXTURE2,
GL_TEXTURE3,
GL_TEXTURE4,
GL_TEXTURE5,
GL_TEXTURE6,
GL_TEXTURE7,
GL_TEXTURE8,
GL_TEXTURE9,
GL_TEXTURE10,
GL_TEXTURE11,
GL_TEXTURE12,
GL_TEXTURE13,
GL_TEXTURE14,
GL_TEXTURE15,
GL_TEXTURE16,
GL_TEXTURE17,
GL_TEXTURE18,
GL_TEXTURE19,
GL_TEXTURE20,
GL_TEXTURE21,
GL_TEXTURE22,
GL_TEXTURE23,
GL_TEXTURE24,
GL_TEXTURE25,
GL_TEXTURE26,
GL_TEXTURE27,
GL_TEXTURE28,
GL_TEXTURE29,
GL_TEXTURE30,
GL_TEXTURE31,
GL_ACTIVE_TEXTURE,

/* TextureWrapMode */
GL_REPEAT,
GL_CLAMP_TO_EDGE,
GL_MIRRORED_REPEAT,

/* Uniform Types */
GL_FLOAT_VEC2,
GL_FLOAT_VEC3,
GL_FLOAT_VEC4,
GL_INT_VEC2,
GL_INT_VEC3,
GL_INT_VEC4,
GL_BOOL,
GL_BOOL_VEC2,
GL_BOOL_VEC3,
GL_BOOL_VEC4,
GL_FLOAT_MAT2,
GL_FLOAT_MAT3,
GL_FLOAT_MAT4,
GL_SAMPLER_2D,
GL_SAMPLER_CUBE,

/* Vertex Arrays */
GL_VERTEX_ATTRIB_ARRAY_ENABLED,
GL_VERTEX_ATTRIB_ARRAY_SIZE,
GL_VERTEX_ATTRIB_ARRAY_STRIDE,
GL_VERTEX_ATTRIB_ARRAY_TYPE,
GL_VERTEX_ATTRIB_ARRAY_NORMALIZED,
GL_VERTEX_ATTRIB_ARRAY_POINTER,
GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING,

/* Read Format */
GL_IMPLEMENTATION_COLOR_READ_TYPE,
GL_IMPLEMENTATION_COLOR_READ_FORMAT,

/* Shader Source */
GL_COMPILE_STATUS,
GL_INFO_LOG_LENGTH,
GL_SHADER_SOURCE_LENGTH,
GL_SHADER_COMPILER,

/* Shader Binary */
GL_SHADER_BINARY_FORMATS,
GL_NUM_SHADER_BINARY_FORMATS,

/* Shader Precision-Specified Types */
GL_LOW_FLOAT,
GL_MEDIUM_FLOAT,
GL_HIGH_FLOAT,
GL_LOW_INT,
GL_MEDIUM_INT,
GL_HIGH_INT,

/* Framebuffer Object. */
GL_FRAMEBUFFER,
GL_RENDERBUFFER,

GL_RGBA4,
GL_RGB5_A1,
GL_RGB565,
GL_DEPTH_COMPONENT16,
GL_STENCIL_INDEX8,

GL_RENDERBUFFER_WIDTH,
GL_RENDERBUFFER_HEIGHT,
GL_RENDERBUFFER_INTERNAL_FORMAT,
GL_RENDERBUFFER_RED_SIZE,
GL_RENDERBUFFER_GREEN_SIZE,
GL_RENDERBUFFER_BLUE_SIZE,
GL_RENDERBUFFER_ALPHA_SIZE,
GL_RENDERBUFFER_DEPTH_SIZE,
GL_RENDERBUFFER_STENCIL_SIZE,

GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL,
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE,

GL_COLOR_ATTACHMENT0,
GL_DEPTH_ATTACHMENT,
GL_STENCIL_ATTACHMENT,

GL_NONE,

GL_FRAMEBUFFER_COMPLETE,
GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS,
GL_FRAMEBUFFER_UNSUPPORTED,

GL_FRAMEBUFFER_BINDING,
GL_RENDERBUFFER_BINDING,
GL_MAX_RENDERBUFFER_SIZE,

GL_INVALID_FRAMEBUFFER_OPERATION,

/* OpenGL ES 3.0 */

GL_READ_BUFFER,
GL_UNPACK_ROW_LENGTH,
GL_UNPACK_SKIP_ROWS,
GL_UNPACK_SKIP_PIXELS,
GL_PACK_ROW_LENGTH,
GL_PACK_SKIP_ROWS,
GL_PACK_SKIP_PIXELS,
GL_COLOR,
GL_DEPTH,
GL_STENCIL,
GL_RED,
GL_RGB8,
GL_RGBA8,
GL_RGB10_A2,
GL_TEXTURE_BINDING_3D,
GL_UNPACK_SKIP_IMAGES,
GL_UNPACK_IMAGE_HEIGHT,
GL_TEXTURE_3D,
GL_TEXTURE_WRAP_R,
GL_MAX_3D_TEXTURE_SIZE,
GL_UNSIGNED_INT_2_10_10_10_REV,
GL_MAX_ELEMENTS_VERTICES,
GL_MAX_ELEMENTS_INDICES,
GL_TEXTURE_MIN_LOD,
GL_TEXTURE_MAX_LOD,
GL_TEXTURE_BASE_LEVEL,
GL_TEXTURE_MAX_LEVEL,
GL_MIN,
GL_MAX,
GL_DEPTH_COMPONENT24,
GL_MAX_TEXTURE_LOD_BIAS,
GL_TEXTURE_COMPARE_MODE,
GL_TEXTURE_COMPARE_FUNC,
GL_CURRENT_QUERY,
GL_QUERY_RESULT,
GL_QUERY_RESULT_AVAILABLE,
GL_BUFFER_MAPPED,
GL_BUFFER_MAP_POINTER,
GL_STREAM_READ,
GL_STREAM_COPY,
GL_STATIC_READ,
GL_STATIC_COPY,
GL_DYNAMIC_READ,
GL_DYNAMIC_COPY,
GL_MAX_DRAW_BUFFERS,
GL_DRAW_BUFFER0,
GL_DRAW_BUFFER1,
GL_DRAW_BUFFER2,
GL_DRAW_BUFFER3,
GL_DRAW_BUFFER4,
GL_DRAW_BUFFER5,
GL_DRAW_BUFFER6,
GL_DRAW_BUFFER7,
GL_DRAW_BUFFER8,
GL_DRAW_BUFFER9,
GL_DRAW_BUFFER10,
GL_DRAW_BUFFER11,
GL_DRAW_BUFFER12,
GL_DRAW_BUFFER13,
GL_DRAW_BUFFER14,
GL_DRAW_BUFFER15,
GL_MAX_FRAGMENT_UNIFORM_COMPONENTS,
GL_MAX_VERTEX_UNIFORM_COMPONENTS,
GL_SAMPLER_3D,
GL_SAMPLER_2D_SHADOW,
GL_FRAGMENT_SHADER_DERIVATIVE_HINT,
GL_PIXEL_PACK_BUFFER,
GL_PIXEL_UNPACK_BUFFER,
GL_PIXEL_PACK_BUFFER_BINDING,
GL_PIXEL_UNPACK_BUFFER_BINDING,
GL_FLOAT_MAT2x3,
GL_FLOAT_MAT2x4,
GL_FLOAT_MAT3x2,
GL_FLOAT_MAT3x4,
GL_FLOAT_MAT4x2,
GL_FLOAT_MAT4x3,
GL_SRGB,
GL_SRGB8,
GL_SRGB8_ALPHA8,
GL_COMPARE_REF_TO_TEXTURE,
GL_MAJOR_VERSION,
GL_MINOR_VERSION,
GL_NUM_EXTENSIONS,
GL_RGBA32F,
GL_RGB32F,
GL_RGBA16F,
GL_RGB16F,
GL_VERTEX_ATTRIB_ARRAY_INTEGER,
GL_MAX_ARRAY_TEXTURE_LAYERS,
GL_MIN_PROGRAM_TEXEL_OFFSET,
GL_MAX_PROGRAM_TEXEL_OFFSET,
GL_MAX_VARYING_COMPONENTS,
GL_TEXTURE_2D_ARRAY,
GL_TEXTURE_BINDING_2D_ARRAY,
GL_R11F_G11F_B10F,
GL_UNSIGNED_INT_10F_11F_11F_REV,
GL_RGB9_E5,
GL_UNSIGNED_INT_5_9_9_9_REV,
GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH,
GL_TRANSFORM_FEEDBACK_BUFFER_MODE,
GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS,
GL_TRANSFORM_FEEDBACK_VARYINGS,
GL_TRANSFORM_FEEDBACK_BUFFER_START,
GL_TRANSFORM_FEEDBACK_BUFFER_SIZE,
GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN,
GL_RASTERIZER_DISCARD,
GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS ,
GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS,
GL_INTERLEAVED_ATTRIBS,
GL_SEPARATE_ATTRIBS,
GL_TRANSFORM_FEEDBACK_BUFFER,
GL_TRANSFORM_FEEDBACK_BUFFER_BINDING,
GL_RGBA32UI,
GL_RGB32UI,
GL_RGBA16UI,
GL_RGB16UI,
GL_RGBA8UI,
GL_RGB8UI,
GL_RGBA32I,
GL_RGB32I,
GL_RGBA16I,
GL_RGB16I,
GL_RGBA8I,
GL_RGB8I,
GL_RED_INTEGER,
GL_RGB_INTEGER,
GL_RGBA_INTEGER,
GL_SAMPLER_2D_ARRAY,
GL_SAMPLER_2D_ARRAY_SHADOW,
GL_SAMPLER_CUBE_SHADOW,
GL_UNSIGNED_INT_VEC2,
GL_UNSIGNED_INT_VEC3,
GL_UNSIGNED_INT_VEC4,
GL_INT_SAMPLER_2D,
GL_INT_SAMPLER_3D,
GL_INT_SAMPLER_CUBE,
GL_INT_SAMPLER_2D_ARRAY,
GL_UNSIGNED_INT_SAMPLER_2D,
GL_UNSIGNED_INT_SAMPLER_3D,
GL_UNSIGNED_INT_SAMPLER_CUBE,
GL_UNSIGNED_INT_SAMPLER_2D_ARRAY,
GL_BUFFER_ACCESS_FLAGS,
GL_BUFFER_MAP_LENGTH,
GL_BUFFER_MAP_OFFSET,
GL_DEPTH_COMPONENT32F,
GL_DEPTH32F_STENCIL8,
GL_FLOAT_32_UNSIGNED_INT_24_8_REV,
GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING,
GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE,
GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE,
GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE,
GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE,
GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE,
GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE,
GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE,
GL_FRAMEBUFFER_DEFAULT,
GL_FRAMEBUFFER_UNDEFINED,
GL_DEPTH_STENCIL_ATTACHMENT,
GL_DEPTH_STENCIL,
GL_UNSIGNED_INT_24_8,
GL_DEPTH24_STENCIL8,
GL_UNSIGNED_NORMALIZED,
GL_DRAW_FRAMEBUFFER_BINDING,
GL_READ_FRAMEBUFFER,
GL_DRAW_FRAMEBUFFER,
GL_READ_FRAMEBUFFER_BINDING,
GL_RENDERBUFFER_SAMPLES,
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER,
GL_MAX_COLOR_ATTACHMENTS,
GL_COLOR_ATTACHMENT1,
GL_COLOR_ATTACHMENT2,
GL_COLOR_ATTACHMENT3,
GL_COLOR_ATTACHMENT4,
GL_COLOR_ATTACHMENT5,
GL_COLOR_ATTACHMENT6,
GL_COLOR_ATTACHMENT7,
GL_COLOR_ATTACHMENT8,
GL_COLOR_ATTACHMENT9,
GL_COLOR_ATTACHMENT10,
GL_COLOR_ATTACHMENT11,
GL_COLOR_ATTACHMENT12,
GL_COLOR_ATTACHMENT13,
GL_COLOR_ATTACHMENT14,
GL_COLOR_ATTACHMENT15,
GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE,
GL_MAX_SAMPLES,
GL_HALF_FLOAT,
GL_MAP_READ_BIT,
GL_MAP_WRITE_BIT,
GL_MAP_INVALIDATE_RANGE_BIT,
GL_MAP_INVALIDATE_BUFFER_BIT,
GL_MAP_FLUSH_EXPLICIT_BIT,
GL_MAP_UNSYNCHRONIZED_BIT,
GL_RG,
GL_RG_INTEGER,
GL_R8,
GL_RG8,
GL_R16F,
GL_R32F,
GL_RG16F,
GL_RG32F,
GL_R8I,
GL_R8UI,
GL_R16I,
GL_R16UI,
GL_R32I,
GL_R32UI,
GL_RG8I,
GL_RG8UI,
GL_RG16I,
GL_RG16UI,
GL_RG32I,
GL_RG32UI,
GL_VERTEX_ARRAY_BINDING,
GL_R8_SNORM,
GL_RG8_SNORM,
GL_RGB8_SNORM,
GL_RGBA8_SNORM,
GL_SIGNED_NORMALIZED,
GL_PRIMITIVE_RESTART_FIXED_INDEX,
GL_COPY_READ_BUFFER,
GL_COPY_WRITE_BUFFER,
GL_COPY_READ_BUFFER_BINDING,
GL_COPY_WRITE_BUFFER_BINDING,
GL_UNIFORM_BUFFER,
GL_UNIFORM_BUFFER_BINDING,
GL_UNIFORM_BUFFER_START,
GL_UNIFORM_BUFFER_SIZE,
GL_MAX_VERTEX_UNIFORM_BLOCKS,
GL_MAX_FRAGMENT_UNIFORM_BLOCKS,
GL_MAX_COMBINED_UNIFORM_BLOCKS,
GL_MAX_UNIFORM_BUFFER_BINDINGS,
GL_MAX_UNIFORM_BLOCK_SIZE,
GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS,
GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS,
GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT,
GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH,
GL_ACTIVE_UNIFORM_BLOCKS,
GL_UNIFORM_TYPE,
GL_UNIFORM_SIZE,
GL_UNIFORM_NAME_LENGTH,
GL_UNIFORM_BLOCK_INDEX,
GL_UNIFORM_OFFSET,
GL_UNIFORM_ARRAY_STRIDE,
GL_UNIFORM_MATRIX_STRIDE,
GL_UNIFORM_IS_ROW_MAJOR,
GL_UNIFORM_BLOCK_BINDING,
GL_UNIFORM_BLOCK_DATA_SIZE,
GL_UNIFORM_BLOCK_NAME_LENGTH,
GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS,
GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES,
GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER,
GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER,
GL_INVALID_INDEX,
GL_MAX_VERTEX_OUTPUT_COMPONENTS,
GL_MAX_FRAGMENT_INPUT_COMPONENTS,
GL_MAX_SERVER_WAIT_TIMEOUT,
GL_OBJECT_TYPE,
GL_SYNC_CONDITION,
GL_SYNC_STATUS,
GL_SYNC_FLAGS,
GL_SYNC_FENCE,
GL_SYNC_GPU_COMMANDS_COMPLETE,
GL_UNSIGNALED,
GL_SIGNALED,
GL_ALREADY_SIGNALED,
GL_TIMEOUT_EXPIRED,
GL_CONDITION_SATISFIED,
GL_WAIT_FAILED,
GL_SYNC_FLUSH_COMMANDS_BIT,
GL_TIMEOUT_IGNORED,
GL_VERTEX_ATTRIB_ARRAY_DIVISOR,
GL_ANY_SAMPLES_PASSED,
GL_ANY_SAMPLES_PASSED_CONSERVATIVE,
GL_SAMPLER_BINDING,
GL_RGB10_A2UI,
GL_TEXTURE_SWIZZLE_R,
GL_TEXTURE_SWIZZLE_G,
GL_TEXTURE_SWIZZLE_B,
GL_TEXTURE_SWIZZLE_A,
GL_GREEN,
GL_BLUE,
GL_INT_2_10_10_10_REV,
GL_TRANSFORM_FEEDBACK,
GL_TRANSFORM_FEEDBACK_PAUSED,
GL_TRANSFORM_FEEDBACK_ACTIVE,
GL_TRANSFORM_FEEDBACK_BINDING,
GL_PROGRAM_BINARY_RETRIEVABLE_HINT,
GL_PROGRAM_BINARY_LENGTH,
GL_NUM_PROGRAM_BINARY_FORMATS,
GL_PROGRAM_BINARY_FORMATS,
GL_COMPRESSED_R11_EAC,
GL_COMPRESSED_SIGNED_R11_EAC,
GL_COMPRESSED_RG11_EAC,
GL_COMPRESSED_SIGNED_RG11_EAC,
GL_COMPRESSED_RGB8_ETC2,
GL_COMPRESSED_SRGB8_ETC2,
GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2,
GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2,
GL_COMPRESSED_RGBA8_ETC2_EAC,
GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC,
GL_TEXTURE_IMMUTABLE_FORMAT,
GL_MAX_ELEMENT_INDEX,
GL_NUM_SAMPLE_COUNTS,
GL_TEXTURE_IMMUTABLE_LEVELS: extern const UInt

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
