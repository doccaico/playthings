{.compile: "./sokol/sokol_gfx_impl.c".}

type
  uint8_t = uint8
  uint32_t = uint32

type
  sg_buffer* {.bycopy.} = object
    id*: uint32_t

  sg_image* {.bycopy.} = object
    id*: uint32_t

  sg_shader* {.bycopy.} = object
    id*: uint32_t

  sg_pipeline* {.bycopy.} = object
    id*: uint32_t

  sg_pass* {.bycopy.} = object
    id*: uint32_t

  sg_context* {.bycopy.} = object
    id*: uint32_t

type
  sg_range* {.bycopy.} = object
    `ptr`*: pointer
    size*: csize_t

const
  SG_INVALID_ID* = 0
  SG_NUM_SHADER_STAGES* = 2
  SG_NUM_INFLIGHT_FRAMES* = 2
  SG_MAX_COLOR_ATTACHMENTS* = 4
  SG_MAX_SHADERSTAGE_BUFFERS* = 8
  SG_MAX_SHADERSTAGE_IMAGES* = 12
  SG_MAX_SHADERSTAGE_UBS* = 4
  SG_MAX_UB_MEMBERS* = 16
  SG_MAX_VERTEX_ATTRIBUTES* = 16 ##  NOTE: actual max vertex attrs can be less on GLES2, see sg_limits!
  SG_MAX_MIPMAPS* = 16
  SG_MAX_TEXTUREARRAY_LAYERS* = 128

type
  sg_color* {.bycopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

type
  sg_backend* = enum
    SG_BACKEND_GLCORE33, SG_BACKEND_GLES2, SG_BACKEND_GLES3, SG_BACKEND_D3D11,
    SG_BACKEND_METAL_IOS, SG_BACKEND_METAL_MACOS, SG_BACKEND_METAL_SIMULATOR,
    SG_BACKEND_WGPU, SG_BACKEND_DUMMY

type
  sg_pixel_format* = enum
    SG_PIXELFORMAT_DEFAULT,  ##  value 0 reserved for default-init
    SG_PIXELFORMAT_NONE, SG_PIXELFORMAT_R8, SG_PIXELFORMAT_R8SN,
    SG_PIXELFORMAT_R8UI, SG_PIXELFORMAT_R8SI, SG_PIXELFORMAT_R16,
    SG_PIXELFORMAT_R16SN, SG_PIXELFORMAT_R16UI, SG_PIXELFORMAT_R16SI,
    SG_PIXELFORMAT_R16F, SG_PIXELFORMAT_RG8, SG_PIXELFORMAT_RG8SN,
    SG_PIXELFORMAT_RG8UI, SG_PIXELFORMAT_RG8SI, SG_PIXELFORMAT_R32UI,
    SG_PIXELFORMAT_R32SI, SG_PIXELFORMAT_R32F, SG_PIXELFORMAT_RG16,
    SG_PIXELFORMAT_RG16SN, SG_PIXELFORMAT_RG16UI, SG_PIXELFORMAT_RG16SI,
    SG_PIXELFORMAT_RG16F, SG_PIXELFORMAT_RGBA8, SG_PIXELFORMAT_RGBA8SN,
    SG_PIXELFORMAT_RGBA8UI, SG_PIXELFORMAT_RGBA8SI, SG_PIXELFORMAT_BGRA8,
    SG_PIXELFORMAT_RGB10A2, SG_PIXELFORMAT_RG11B10F, SG_PIXELFORMAT_RG32UI,
    SG_PIXELFORMAT_RG32SI, SG_PIXELFORMAT_RG32F, SG_PIXELFORMAT_RGBA16,
    SG_PIXELFORMAT_RGBA16SN, SG_PIXELFORMAT_RGBA16UI, SG_PIXELFORMAT_RGBA16SI,
    SG_PIXELFORMAT_RGBA16F, SG_PIXELFORMAT_RGBA32UI, SG_PIXELFORMAT_RGBA32SI,
    SG_PIXELFORMAT_RGBA32F, SG_PIXELFORMAT_DEPTH, SG_PIXELFORMAT_DEPTH_STENCIL,
    SG_PIXELFORMAT_BC1_RGBA, SG_PIXELFORMAT_BC2_RGBA, SG_PIXELFORMAT_BC3_RGBA,
    SG_PIXELFORMAT_BC4_R, SG_PIXELFORMAT_BC4_RSN, SG_PIXELFORMAT_BC5_RG,
    SG_PIXELFORMAT_BC5_RGSN, SG_PIXELFORMAT_BC6H_RGBF, SG_PIXELFORMAT_BC6H_RGBUF,
    SG_PIXELFORMAT_BC7_RGBA, SG_PIXELFORMAT_PVRTC_RGB_2BPP,
    SG_PIXELFORMAT_PVRTC_RGB_4BPP, SG_PIXELFORMAT_PVRTC_RGBA_2BPP,
    SG_PIXELFORMAT_PVRTC_RGBA_4BPP, SG_PIXELFORMAT_ETC2_RGB8,
    SG_PIXELFORMAT_ETC2_RGB8A1, SG_PIXELFORMAT_ETC2_RGBA8,
    SG_PIXELFORMAT_ETC2_RG11, SG_PIXELFORMAT_ETC2_RG11SN, SG_PIXELFORMAT_NUM,
    SG_PIXELFORMAT_FORCE_U32 = 0x7FFFFFFF

type
  sg_pixelformat_info* {.bycopy.} = object
    sample*: bool              ##  pixel format can be sampled in shaders
    filter*: bool              ##  pixel format can be sampled with filtering
    render*: bool              ##  pixel format can be used as render target
    blend*: bool               ##  alpha-blending is supported
    msaa*: bool                ##  pixel format can be used as MSAA render target
    depth*: bool               ##  pixel format is a depth format
    # when defined(SOKOL_ZIG_BINDINGS):
    #   var __pad*: array[3, uint32_t]

type
  sg_features* {.bycopy.} = object
    instancing*: bool          ##  hardware instancing supported
    origin_top_left*: bool     ##  framebuffer and texture origin is in top left corner
    multiple_render_targets*: bool ##  offscreen render passes can have multiple render targets attached
    msaa_render_targets*: bool ##  offscreen render passes support MSAA antialiasing
    imagetype_3d*: bool        ##  creation of SG_IMAGETYPE_3D images is supported
    imagetype_array*: bool     ##  creation of SG_IMAGETYPE_ARRAY images is supported
    image_clamp_to_border*: bool ##  border color and clamp-to-border UV-wrap mode is supported
    mrt_independent_blend_state*: bool ##  multiple-render-target rendering can use per-render-target blend state
    mrt_independent_write_mask*: bool ##  multiple-render-target rendering can use per-render-target color write masks
    # when defined(SOKOL_ZIG_BINDINGS):
    #   var __pad*: array[3, uint32_t]

type
  sg_limits* {.bycopy.} = object
    max_image_size_2d*: cint   ##  max width/height of SG_IMAGETYPE_2D images
    max_image_size_cube*: cint ##  max width/height of SG_IMAGETYPE_CUBE images
    max_image_size_3d*: cint   ##  max width/height/depth of SG_IMAGETYPE_3D images
    max_image_size_array*: cint ##  max width/height of SG_IMAGETYPE_ARRAY images
    max_image_array_layers*: cint ##  max number of layers in SG_IMAGETYPE_ARRAY images
    max_vertex_attrs*: cint    ##  <= SG_MAX_VERTEX_ATTRIBUTES (only on some GLES2 impls)

type
  sg_resource_state* = enum
    SG_RESOURCESTATE_INITIAL, SG_RESOURCESTATE_ALLOC, SG_RESOURCESTATE_VALID,
    SG_RESOURCESTATE_FAILED, SG_RESOURCESTATE_INVALID,
    SG_RESOURCESTATE_FORCE_U32 = 0x7FFFFFFF

type
  sg_usage* = enum
    SG_USAGE_DEFAULT,        ##  value 0 reserved for default-init
    SG_USAGE_IMMUTABLE, SG_USAGE_DYNAMIC, SG_USAGE_STREAM, SG_USAGE_NUM,
    SG_USAGE_FORCE_U32 = 0x7FFFFFFF

type
  sg_buffer_type* = enum
    SG_BUFFERTYPE_DEFAULT,   ##  value 0 reserved for default-init
    SG_BUFFERTYPE_VERTEXBUFFER, SG_BUFFERTYPE_INDEXBUFFER, SG_BUFFERTYPE_NUM,
    SG_BUFFERTYPE_FORCE_U32 = 0x7FFFFFFF

type
  sg_index_type* = enum
    SG_INDEXTYPE_DEFAULT,    ##  value 0 reserved for default-init
    SG_INDEXTYPE_NONE, SG_INDEXTYPE_UINT16, SG_INDEXTYPE_UINT32, SG_INDEXTYPE_NUM,
    SG_INDEXTYPE_FORCE_U32 = 0x7FFFFFFF

type
  sg_image_type* = enum
    SG_IMAGETYPE_DEFAULT,    ##  value 0 reserved for default-init
    SG_IMAGETYPE_2D, SG_IMAGETYPE_CUBE, SG_IMAGETYPE_3D, SG_IMAGETYPE_ARRAY,
    SG_IMAGETYPE_NUM, SG_IMAGETYPE_FORCE_U32 = 0x7FFFFFFF

type
  sg_sampler_type* = enum
    SG_SAMPLERTYPE_DEFAULT,  ##  value 0 reserved for default-init
    SG_SAMPLERTYPE_FLOAT, SG_SAMPLERTYPE_SINT, SG_SAMPLERTYPE_UINT

type
  sg_cube_face* = enum
    SG_CUBEFACE_POS_X, SG_CUBEFACE_NEG_X, SG_CUBEFACE_POS_Y, SG_CUBEFACE_NEG_Y,
    SG_CUBEFACE_POS_Z, SG_CUBEFACE_NEG_Z, SG_CUBEFACE_NUM,
    SG_CUBEFACE_FORCE_U32 = 0x7FFFFFFF

type
  sg_shader_stage* = enum
    SG_SHADERSTAGE_VS, SG_SHADERSTAGE_FS, SG_SHADERSTAGE_FORCE_U32 = 0x7FFFFFFF

type
  sg_primitive_type* = enum
    SG_PRIMITIVETYPE_DEFAULT, ##  value 0 reserved for default-init
    SG_PRIMITIVETYPE_POINTS, SG_PRIMITIVETYPE_LINES, SG_PRIMITIVETYPE_LINE_STRIP,
    SG_PRIMITIVETYPE_TRIANGLES, SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    SG_PRIMITIVETYPE_NUM, SG_PRIMITIVETYPE_FORCE_U32 = 0x7FFFFFFF

type
  sg_filter* = enum
    SG_FILTER_DEFAULT,       ##  value 0 reserved for default-init
    SG_FILTER_NEAREST, SG_FILTER_LINEAR, SG_FILTER_NEAREST_MIPMAP_NEAREST,
    SG_FILTER_NEAREST_MIPMAP_LINEAR, SG_FILTER_LINEAR_MIPMAP_NEAREST,
    SG_FILTER_LINEAR_MIPMAP_LINEAR, SG_FILTER_NUM,
    SG_FILTER_FORCE_U32 = 0x7FFFFFFF

type
  sg_wrap* = enum
    SG_WRAP_DEFAULT,         ##  value 0 reserved for default-init
    SG_WRAP_REPEAT, SG_WRAP_CLAMP_TO_EDGE, SG_WRAP_CLAMP_TO_BORDER,
    SG_WRAP_MIRRORED_REPEAT, SG_WRAP_NUM, SG_WRAP_FORCE_U32 = 0x7FFFFFFF

type
  sg_border_color* = enum
    SG_BORDERCOLOR_DEFAULT,  ##  value 0 reserved for default-init
    SG_BORDERCOLOR_TRANSPARENT_BLACK, SG_BORDERCOLOR_OPAQUE_BLACK,
    SG_BORDERCOLOR_OPAQUE_WHITE, SG_BORDERCOLOR_NUM,
    SG_BORDERCOLOR_FORCE_U32 = 0x7FFFFFFF

type
  sg_vertex_format* = enum
    SG_VERTEXFORMAT_INVALID, SG_VERTEXFORMAT_FLOAT, SG_VERTEXFORMAT_FLOAT2,
    SG_VERTEXFORMAT_FLOAT3, SG_VERTEXFORMAT_FLOAT4, SG_VERTEXFORMAT_BYTE4,
    SG_VERTEXFORMAT_BYTE4N, SG_VERTEXFORMAT_UBYTE4, SG_VERTEXFORMAT_UBYTE4N,
    SG_VERTEXFORMAT_SHORT2, SG_VERTEXFORMAT_SHORT2N, SG_VERTEXFORMAT_USHORT2N,
    SG_VERTEXFORMAT_SHORT4, SG_VERTEXFORMAT_SHORT4N, SG_VERTEXFORMAT_USHORT4N,
    SG_VERTEXFORMAT_UINT10_N2, SG_VERTEXFORMAT_NUM,
    SG_VERTEXFORMAT_FORCE_U32 = 0x7FFFFFFF

type
  sg_vertex_step* = enum
    SG_VERTEXSTEP_DEFAULT,   ##  value 0 reserved for default-init
    SG_VERTEXSTEP_PER_VERTEX, SG_VERTEXSTEP_PER_INSTANCE, SG_VERTEXSTEP_NUM,
    SG_VERTEXSTEP_FORCE_U32 = 0x7FFFFFFF

type
  sg_uniform_type* = enum
    SG_UNIFORMTYPE_INVALID, SG_UNIFORMTYPE_FLOAT, SG_UNIFORMTYPE_FLOAT2,
    SG_UNIFORMTYPE_FLOAT3, SG_UNIFORMTYPE_FLOAT4, SG_UNIFORMTYPE_MAT4,
    SG_UNIFORMTYPE_NUM, SG_UNIFORMTYPE_FORCE_U32 = 0x7FFFFFFF

type
  sg_cull_mode* = enum
    SG_CULLMODE_DEFAULT,     ##  value 0 reserved for default-init
    SG_CULLMODE_NONE, SG_CULLMODE_FRONT, SG_CULLMODE_BACK, SG_CULLMODE_NUM,
    SG_CULLMODE_FORCE_U32 = 0x7FFFFFFF

type
  sg_face_winding* = enum
    SG_FACEWINDING_DEFAULT,  ##  value 0 reserved for default-init
    SG_FACEWINDING_CCW, SG_FACEWINDING_CW, SG_FACEWINDING_NUM,
    SG_FACEWINDING_FORCE_U32 = 0x7FFFFFFF

type
  sg_compare_func* = enum
    SG_COMPAREFUNC_DEFAULT,  ##  value 0 reserved for default-init
    SG_COMPAREFUNC_NEVER, SG_COMPAREFUNC_LESS, SG_COMPAREFUNC_EQUAL,
    SG_COMPAREFUNC_LESS_EQUAL, SG_COMPAREFUNC_GREATER, SG_COMPAREFUNC_NOT_EQUAL,
    SG_COMPAREFUNC_GREATER_EQUAL, SG_COMPAREFUNC_ALWAYS, SG_COMPAREFUNC_NUM,
    SG_COMPAREFUNC_FORCE_U32 = 0x7FFFFFFF

type
  sg_stencil_op* = enum
    SG_STENCILOP_DEFAULT,    ##  value 0 reserved for default-init
    SG_STENCILOP_KEEP, SG_STENCILOP_ZERO, SG_STENCILOP_REPLACE,
    SG_STENCILOP_INCR_CLAMP, SG_STENCILOP_DECR_CLAMP, SG_STENCILOP_INVERT,
    SG_STENCILOP_INCR_WRAP, SG_STENCILOP_DECR_WRAP, SG_STENCILOP_NUM,
    SG_STENCILOP_FORCE_U32 = 0x7FFFFFFF

type
  sg_blend_factor* = enum
    SG_BLENDFACTOR_DEFAULT,  ##  value 0 reserved for default-init
    SG_BLENDFACTOR_ZERO, SG_BLENDFACTOR_ONE, SG_BLENDFACTOR_SRC_COLOR,
    SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR, SG_BLENDFACTOR_SRC_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA, SG_BLENDFACTOR_DST_COLOR,
    SG_BLENDFACTOR_ONE_MINUS_DST_COLOR, SG_BLENDFACTOR_DST_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA, SG_BLENDFACTOR_SRC_ALPHA_SATURATED,
    SG_BLENDFACTOR_BLEND_COLOR, SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR,
    SG_BLENDFACTOR_BLEND_ALPHA, SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA,
    SG_BLENDFACTOR_NUM, SG_BLENDFACTOR_FORCE_U32 = 0x7FFFFFFF

type
  sg_blend_op* = enum
    SG_BLENDOP_DEFAULT,      ##  value 0 reserved for default-init
    SG_BLENDOP_ADD, SG_BLENDOP_SUBTRACT, SG_BLENDOP_REVERSE_SUBTRACT,
    SG_BLENDOP_NUM, SG_BLENDOP_FORCE_U32 = 0x7FFFFFFF

type
  sg_color_mask* = enum
    SG_COLORMASK_DEFAULT = 0,  ##  value 0 reserved for default-init
    SG_COLORMASK_R = 0x00000001, SG_COLORMASK_G = 0x00000002,
    SG_COLORMASK_RG = 0x00000003, SG_COLORMASK_B = 0x00000004,
    SG_COLORMASK_RB = 0x00000005, SG_COLORMASK_GB = 0x00000006,
    SG_COLORMASK_RGB = 0x00000007, SG_COLORMASK_A = 0x00000008,
    SG_COLORMASK_RA = 0x00000009, SG_COLORMASK_GA = 0x0000000A,
    SG_COLORMASK_RGA = 0x0000000B, SG_COLORMASK_BA = 0x0000000C,
    SG_COLORMASK_RBA = 0x0000000D, SG_COLORMASK_GBA = 0x0000000E,
    SG_COLORMASK_RGBA = 0x0000000F, SG_COLORMASK_NONE = 0x00000010, ##  special value for 'all channels disabled
    SG_COLORMASK_FORCE_U32 = 0x7FFFFFFF

type
  sg_action* = enum
    SG_ACTION_DEFAULT, SG_ACTION_CLEAR, SG_ACTION_LOAD, SG_ACTION_DONTCARE,
    SG_ACTION_NUM, SG_ACTION_FORCE_U32 = 0x7FFFFFFF

type
  sg_color_attachment_action* {.bycopy.} = object
    action*: sg_action
    value*: sg_color

  sg_depth_attachment_action* {.bycopy.} = object
    action*: sg_action
    value*: cfloat

  sg_stencil_attachment_action* {.bycopy.} = object
    action*: sg_action
    value*: uint8_t

  sg_pass_action* {.bycopy.} = object
    start_canary*: uint32_t
    colors*: array[SG_MAX_COLOR_ATTACHMENTS, sg_color_attachment_action]
    depth*: sg_depth_attachment_action
    stencil*: sg_stencil_attachment_action
    end_canary*: uint32_t

type
  sg_bindings* {.bycopy.} = object
    start_canary*: uint32_t
    vertex_buffers*: array[SG_MAX_SHADERSTAGE_BUFFERS, sg_buffer]
    vertex_buffer_offsets*: array[SG_MAX_SHADERSTAGE_BUFFERS, cint]
    index_buffer*: sg_buffer
    index_buffer_offset*: cint
    vs_images*: array[SG_MAX_SHADERSTAGE_IMAGES, sg_image]
    fs_images*: array[SG_MAX_SHADERSTAGE_IMAGES, sg_image]
    end_canary*: uint32_t

type
  sg_buffer_desc* {.bycopy.} = object
    start_canary*: uint32_t
    size*: csize_t
    `type`*: sg_buffer_type
    usage*: sg_usage
    data*: sg_range
    label*: cstring            ##  GL specific
    gl_buffers*: array[SG_NUM_INFLIGHT_FRAMES, uint32_t] ##  Metal specific
    mtl_buffers*: array[SG_NUM_INFLIGHT_FRAMES, pointer] ##  D3D11 specific
    d3d11_buffer*: pointer     ##  WebGPU specific
    wgpu_buffer*: pointer
    end_canary*: uint32_t

type
  sg_image_data* {.bycopy.} = object
    subimage*: array[SG_CUBEFACE_NUM.ord, array[SG_MAX_MIPMAPS.ord, sg_range]]

type
  sg_image_desc* {.bycopy.} = object
    start_canary*: uint32_t
    `type`*: sg_image_type
    render_target*: bool
    width*: cint
    height*: cint
    num_slices*: cint
    num_mipmaps*: cint
    usage*: sg_usage
    pixel_format*: sg_pixel_format
    sample_count*: cint
    min_filter*: sg_filter
    mag_filter*: sg_filter
    wrap_u*: sg_wrap
    wrap_v*: sg_wrap
    wrap_w*: sg_wrap
    border_color*: sg_border_color
    max_anisotropy*: uint32_t
    min_lod*: cfloat
    max_lod*: cfloat
    data*: sg_image_data
    label*: cstring            ##  GL specific
    gl_textures*: array[SG_NUM_INFLIGHT_FRAMES, uint32_t]
    gl_texture_target*: uint32_t ##  Metal specific
    mtl_textures*: array[SG_NUM_INFLIGHT_FRAMES, pointer] ##  D3D11 specific
    d3d11_texture*: pointer
    d3d11_shader_resource_view*: pointer ##  WebGPU specific
    wgpu_texture*: pointer
    end_canary*: uint32_t

type
  sg_shader_attr_desc* {.bycopy.} = object
    name*: cstring             ##  GLSL vertex attribute name (only strictly required for GLES2)
    sem_name*: cstring         ##  HLSL semantic name
    sem_index*: cint           ##  HLSL semantic index

  sg_shader_uniform_desc* {.bycopy.} = object
    name*: cstring
    `type`*: sg_uniform_type
    array_count*: cint

  sg_shader_uniform_block_desc* {.bycopy.} = object
    size*: csize_t
    uniforms*: array[SG_MAX_UB_MEMBERS, sg_shader_uniform_desc]

  sg_shader_image_desc* {.bycopy.} = object
    name*: cstring
    image_type*: sg_image_type
    sampler_type*: sg_sampler_type

  sg_shader_stage_desc* {.bycopy.} = object
    source*: cstring
    bytecode*: sg_range
    entry*: cstring
    d3d11_target*: cstring
    uniform_blocks*: array[SG_MAX_SHADERSTAGE_UBS, sg_shader_uniform_block_desc]
    images*: array[SG_MAX_SHADERSTAGE_IMAGES, sg_shader_image_desc]

  sg_shader_desc* {.bycopy.} = object
    start_canary*: uint32_t
    attrs*: array[SG_MAX_VERTEX_ATTRIBUTES, sg_shader_attr_desc]
    vs*: sg_shader_stage_desc
    fs*: sg_shader_stage_desc
    label*: cstring
    end_canary*: uint32_t

type
  sg_buffer_layout_desc* {.bycopy.} = object
    stride*: cint
    step_func*: sg_vertex_step
    step_rate*: cint
    # when defined(SOKOL_ZIG_BINDINGS):
    #   var __pad*: array[2, uint32_t]

  sg_vertex_attr_desc* {.bycopy.} = object
    buffer_index*: cint
    offset*: cint
    format*: sg_vertex_format
    # when defined(SOKOL_ZIG_BINDINGS):
    #   var __pad*: array[2, uint32_t]

  sg_layout_desc* {.bycopy.} = object
    buffers*: array[SG_MAX_SHADERSTAGE_BUFFERS, sg_buffer_layout_desc]
    attrs*: array[SG_MAX_VERTEX_ATTRIBUTES, sg_vertex_attr_desc]

  sg_stencil_face_state* {.bycopy.} = object
    compare*: sg_compare_func
    fail_op*: sg_stencil_op
    depth_fail_op*: sg_stencil_op
    pass_op*: sg_stencil_op

  sg_stencil_state* {.bycopy.} = object
    enabled*: bool
    front*: sg_stencil_face_state
    back*: sg_stencil_face_state
    read_mask*: uint8_t
    write_mask*: uint8_t
    `ref`*: uint8_t

  sg_depth_state* {.bycopy.} = object
    pixel_format*: sg_pixel_format
    compare*: sg_compare_func
    write_enabled*: bool
    bias*: cfloat
    bias_slope_scale*: cfloat
    bias_clamp*: cfloat

  sg_blend_state* {.bycopy.} = object
    enabled*: bool
    src_factor_rgb*: sg_blend_factor
    dst_factor_rgb*: sg_blend_factor
    op_rgb*: sg_blend_op
    src_factor_alpha*: sg_blend_factor
    dst_factor_alpha*: sg_blend_factor
    op_alpha*: sg_blend_op

  sg_color_state* {.bycopy.} = object
    pixel_format*: sg_pixel_format
    write_mask*: sg_color_mask
    blend*: sg_blend_state

  sg_pipeline_desc* {.bycopy.} = object
    start_canary*: uint32_t
    shader*: sg_shader
    layout*: sg_layout_desc
    depth*: sg_depth_state
    stencil*: sg_stencil_state
    color_count*: cint
    colors*: array[SG_MAX_COLOR_ATTACHMENTS, sg_color_state]
    primitive_type*: sg_primitive_type
    index_type*: sg_index_type
    cull_mode*: sg_cull_mode
    face_winding*: sg_face_winding
    sample_count*: cint
    blend_color*: sg_color
    alpha_to_coverage_enabled*: bool
    label*: cstring
    end_canary*: uint32_t

type
  sg_pass_attachment_desc* {.bycopy.} = object
    image*: sg_image
    mip_level*: cint
    slice*: cint               ##  cube texture: face; array texture: layer; 3D texture: slice

  sg_pass_desc* {.bycopy.} = object
    start_canary*: uint32_t
    color_attachments*: array[SG_MAX_COLOR_ATTACHMENTS, sg_pass_attachment_desc]
    depth_stencil_attachment*: sg_pass_attachment_desc
    label*: cstring
    end_canary*: uint32_t

type
  sg_trace_hooks* {.bycopy.} = object
    user_data*: pointer
    reset_state_cache*: proc (user_data: pointer)
    make_buffer*: proc (desc: ptr sg_buffer_desc; result: sg_buffer; user_data: pointer)
    make_image*: proc (desc: ptr sg_image_desc; result: sg_image; user_data: pointer)
    make_shader*: proc (desc: ptr sg_shader_desc; result: sg_shader; user_data: pointer)
    make_pipeline*: proc (desc: ptr sg_pipeline_desc; result: sg_pipeline;
                        user_data: pointer)
    make_pass*: proc (desc: ptr sg_pass_desc; result: sg_pass; user_data: pointer)
    destroy_buffer*: proc (buf: sg_buffer; user_data: pointer)
    destroy_image*: proc (img: sg_image; user_data: pointer)
    destroy_shader*: proc (shd: sg_shader; user_data: pointer)
    destroy_pipeline*: proc (pip: sg_pipeline; user_data: pointer)
    destroy_pass*: proc (pass: sg_pass; user_data: pointer)
    update_buffer*: proc (buf: sg_buffer; data: ptr sg_range; user_data: pointer)
    update_image*: proc (img: sg_image; data: ptr sg_image_data; user_data: pointer)
    append_buffer*: proc (buf: sg_buffer; data: ptr sg_range; result: cint;
                        user_data: pointer)
    begin_default_pass*: proc (pass_action: ptr sg_pass_action; width: cint;
                             height: cint; user_data: pointer)
    begin_pass*: proc (pass: sg_pass; pass_action: ptr sg_pass_action;
                     user_data: pointer)
    apply_viewport*: proc (x: cint; y: cint; width: cint; height: cint;
                         origin_top_left: bool; user_data: pointer)
    apply_scissor_rect*: proc (x: cint; y: cint; width: cint; height: cint;
                             origin_top_left: bool; user_data: pointer)
    apply_pipeline*: proc (pip: sg_pipeline; user_data: pointer)
    apply_bindings*: proc (bindings: ptr sg_bindings; user_data: pointer)
    apply_uniforms*: proc (stage: sg_shader_stage; ub_index: cint; data: ptr sg_range;
                         user_data: pointer)
    draw*: proc (base_element: cint; num_elements: cint; num_instances: cint;
               user_data: pointer)
    end_pass*: proc (user_data: pointer)
    commit*: proc (user_data: pointer)
    alloc_buffer*: proc (result: sg_buffer; user_data: pointer)
    alloc_image*: proc (result: sg_image; user_data: pointer)
    alloc_shader*: proc (result: sg_shader; user_data: pointer)
    alloc_pipeline*: proc (result: sg_pipeline; user_data: pointer)
    alloc_pass*: proc (result: sg_pass; user_data: pointer)
    dealloc_buffer*: proc (buf_id: sg_buffer; user_data: pointer)
    dealloc_image*: proc (img_id: sg_image; user_data: pointer)
    dealloc_shader*: proc (shd_id: sg_shader; user_data: pointer)
    dealloc_pipeline*: proc (pip_id: sg_pipeline; user_data: pointer)
    dealloc_pass*: proc (pass_id: sg_pass; user_data: pointer)
    init_buffer*: proc (buf_id: sg_buffer; desc: ptr sg_buffer_desc; user_data: pointer)
    init_image*: proc (img_id: sg_image; desc: ptr sg_image_desc; user_data: pointer)
    init_shader*: proc (shd_id: sg_shader; desc: ptr sg_shader_desc; user_data: pointer)
    init_pipeline*: proc (pip_id: sg_pipeline; desc: ptr sg_pipeline_desc;
                        user_data: pointer)
    init_pass*: proc (pass_id: sg_pass; desc: ptr sg_pass_desc; user_data: pointer)
    uninit_buffer*: proc (buf_id: sg_buffer; user_data: pointer)
    uninit_image*: proc (img_id: sg_image; user_data: pointer)
    uninit_shader*: proc (shd_id: sg_shader; user_data: pointer)
    uninit_pipeline*: proc (pip_id: sg_pipeline; user_data: pointer)
    uninit_pass*: proc (pass_id: sg_pass; user_data: pointer)
    fail_buffer*: proc (buf_id: sg_buffer; user_data: pointer)
    fail_image*: proc (img_id: sg_image; user_data: pointer)
    fail_shader*: proc (shd_id: sg_shader; user_data: pointer)
    fail_pipeline*: proc (pip_id: sg_pipeline; user_data: pointer)
    fail_pass*: proc (pass_id: sg_pass; user_data: pointer)
    push_debug_group*: proc (name: cstring; user_data: pointer)
    pop_debug_group*: proc (user_data: pointer)
    err_buffer_pool_exhausted*: proc (user_data: pointer)
    err_image_pool_exhausted*: proc (user_data: pointer)
    err_shader_pool_exhausted*: proc (user_data: pointer)
    err_pipeline_pool_exhausted*: proc (user_data: pointer)
    err_pass_pool_exhausted*: proc (user_data: pointer)
    err_context_mismatch*: proc (user_data: pointer)
    err_pass_invalid*: proc (user_data: pointer)
    err_draw_invalid*: proc (user_data: pointer)
    err_bindings_invalid*: proc (user_data: pointer)

type
  sg_slot_info* {.bycopy.} = object
    state*: sg_resource_state  ##  the current state of this resource slot
    res_id*: uint32_t          ##  type-neutral resource if (e.g. sg_buffer.id)
    ctx_id*: uint32_t          ##  the context this resource belongs to

  sg_buffer_info* {.bycopy.} = object
    slot*: sg_slot_info        ##  resource pool slot info
    update_frame_index*: uint32_t ##  frame index of last sg_update_buffer()
    append_frame_index*: uint32_t ##  frame index of last sg_append_buffer()
    append_pos*: cint          ##  current position in buffer for sg_append_buffer()
    append_overflow*: bool     ##  is buffer in overflow state (due to sg_append_buffer)
    num_slots*: cint           ##  number of renaming-slots for dynamically updated buffers
    active_slot*: cint         ##  currently active write-slot for dynamically updated buffers

  sg_image_info* {.bycopy.} = object
    slot*: sg_slot_info        ##  resource pool slot info
    upd_frame_index*: uint32_t ##  frame index of last sg_update_image()
    num_slots*: cint           ##  number of renaming-slots for dynamically updated images
    active_slot*: cint         ##  currently active write-slot for dynamically updated images
    width*: cint               ##  image width
    height*: cint              ##  image height

  sg_shader_info* {.bycopy.} = object
    slot*: sg_slot_info        ##  resoure pool slot info

  sg_pipeline_info* {.bycopy.} = object
    slot*: sg_slot_info        ##  resource pool slot info

  sg_pass_info* {.bycopy.} = object
    slot*: sg_slot_info        ##  resource pool slot info

type
  sg_gl_context_desc* {.bycopy.} = object
    force_gles2*: bool

  sg_metal_context_desc* {.bycopy.} = object
    device*: pointer
    renderpass_descriptor_cb*: proc (): pointer
    renderpass_descriptor_userdata_cb*: proc (a1: pointer): pointer
    drawable_cb*: proc (): pointer
    drawable_userdata_cb*: proc (a1: pointer): pointer
    user_data*: pointer

  sg_d3d11_context_desc* {.bycopy.} = object
    device*: pointer
    device_context*: pointer
    render_target_view_cb*: proc (): pointer
    render_target_view_userdata_cb*: proc (a1: pointer): pointer
    depth_stencil_view_cb*: proc (): pointer
    depth_stencil_view_userdata_cb*: proc (a1: pointer): pointer
    user_data*: pointer

  sg_wgpu_context_desc* {.bycopy.} = object
    device*: pointer           ##  WGPUDevice
    render_view_cb*: proc (): pointer ##  returns WGPUTextureView
    render_view_userdata_cb*: proc (a1: pointer): pointer
    resolve_view_cb*: proc (): pointer ##  returns WGPUTextureView
    resolve_view_userdata_cb*: proc (a1: pointer): pointer
    depth_stencil_view_cb*: proc (): pointer ##  returns WGPUTextureView, must be WGPUTextureFormat_Depth24Plus8
    depth_stencil_view_userdata_cb*: proc (a1: pointer): pointer
    user_data*: pointer

  sg_context_desc* {.bycopy.} = object
    color_format*: sg_pixel_format
    depth_format*: sg_pixel_format
    sample_count*: cint
    gl*: sg_gl_context_desc
    metal*: sg_metal_context_desc
    d3d11*: sg_d3d11_context_desc
    wgpu*: sg_wgpu_context_desc

  sg_desc* {.bycopy.} = object
    start_canary*: uint32_t
    buffer_pool_size*: cint
    image_pool_size*: cint
    shader_pool_size*: cint
    pipeline_pool_size*: cint
    pass_pool_size*: cint
    context_pool_size*: cint
    uniform_buffer_size*: cint
    staging_buffer_size*: cint
    sampler_cache_size*: cint
    context*: sg_context_desc
    end_canary*: uint32_t


{.push cdecl, importc, header: "./sokol/sokol_gfx.h".}

##  setup and misc functions
proc sg_setup*(desc: ptr sg_desc)
proc sg_shutdown*()
proc sg_isvalid*(): bool
proc sg_reset_state_cache*()
proc sg_install_trace_hooks*(trace_hooks: ptr sg_trace_hooks): sg_trace_hooks
proc sg_push_debug_group*(name: cstring)
proc sg_pop_debug_group*()

##  resource creation, destruction and updating
proc sg_make_buffer*(desc: ptr sg_buffer_desc): sg_buffer
proc sg_make_image*(desc: ptr sg_image_desc): sg_image
proc sg_make_shader*(desc: ptr sg_shader_desc): sg_shader
proc sg_make_pipeline*(desc: ptr sg_pipeline_desc): sg_pipeline
proc sg_make_pass*(desc: ptr sg_pass_desc): sg_pass
proc sg_destroy_buffer*(buf: sg_buffer)
proc sg_destroy_image*(img: sg_image)
proc sg_destroy_shader*(shd: sg_shader)
proc sg_destroy_pipeline*(pip: sg_pipeline)
proc sg_destroy_pass*(pass: sg_pass)
proc sg_update_buffer*(buf: sg_buffer; data: ptr sg_range)
proc sg_update_image*(img: sg_image; data: ptr sg_image_data)
proc sg_append_buffer*(buf: sg_buffer; data: ptr sg_range): cint
proc sg_query_buffer_overflow*(buf: sg_buffer): bool

##  rendering functions
proc sg_begin_default_pass*(pass_action: ptr sg_pass_action; width: cint; height: cint)
proc sg_begin_default_passf*(pass_action: ptr sg_pass_action; width: cfloat;
                            height: cfloat)
proc sg_begin_pass*(pass: sg_pass; pass_action: ptr sg_pass_action)
proc sg_apply_viewport*(x: cint; y: cint; width: cint; height: cint;
                       origin_top_left: bool)
proc sg_apply_viewportf*(x: cfloat; y: cfloat; width: cfloat; height: cfloat;
                        origin_top_left: bool)
proc sg_apply_scissor_rect*(x: cint; y: cint; width: cint; height: cint;
                           origin_top_left: bool)
proc sg_apply_scissor_rectf*(x: cfloat; y: cfloat; width: cfloat; height: cfloat;
                            origin_top_left: bool)
proc sg_apply_pipeline*(pip: sg_pipeline)
proc sg_apply_bindings*(bindings: ptr sg_bindings)
proc sg_apply_uniforms*(stage: sg_shader_stage; ub_index: cint; data: ptr sg_range)
proc sg_draw*(base_element: cint; num_elements: cint; num_instances: cint)
proc sg_end_pass*()
proc sg_commit*()

##  getting information
proc sg_query_desc*(): sg_desc
proc sg_query_backend*(): sg_backend
proc sg_query_features*(): sg_features
proc sg_query_limits*(): sg_limits
proc sg_query_pixelformat*(fmt: sg_pixel_format): sg_pixelformat_info

##  get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID)
proc sg_query_buffer_state*(buf: sg_buffer): sg_resource_state
proc sg_query_image_state*(img: sg_image): sg_resource_state
proc sg_query_shader_state*(shd: sg_shader): sg_resource_state
proc sg_query_pipeline_state*(pip: sg_pipeline): sg_resource_state
proc sg_query_pass_state*(pass: sg_pass): sg_resource_state

##  get runtime information about a resource
proc sg_query_buffer_info*(buf: sg_buffer): sg_buffer_info
proc sg_query_image_info*(img: sg_image): sg_image_info
proc sg_query_shader_info*(shd: sg_shader): sg_shader_info
proc sg_query_pipeline_info*(pip: sg_pipeline): sg_pipeline_info
proc sg_query_pass_info*(pass: sg_pass): sg_pass_info

##  get resource creation desc struct with their default values replaced
proc sg_query_buffer_defaults*(desc: ptr sg_buffer_desc): sg_buffer_desc
proc sg_query_image_defaults*(desc: ptr sg_image_desc): sg_image_desc
proc sg_query_shader_defaults*(desc: ptr sg_shader_desc): sg_shader_desc
proc sg_query_pipeline_defaults*(desc: ptr sg_pipeline_desc): sg_pipeline_desc
proc sg_query_pass_defaults*(desc: ptr sg_pass_desc): sg_pass_desc

##  separate resource allocation and initialization (for async setup)
proc sg_alloc_buffer*(): sg_buffer
proc sg_alloc_image*(): sg_image
proc sg_alloc_shader*(): sg_shader
proc sg_alloc_pipeline*(): sg_pipeline
proc sg_alloc_pass*(): sg_pass
proc sg_dealloc_buffer*(buf_id: sg_buffer)
proc sg_dealloc_image*(img_id: sg_image)
proc sg_dealloc_shader*(shd_id: sg_shader)
proc sg_dealloc_pipeline*(pip_id: sg_pipeline)
proc sg_dealloc_pass*(pass_id: sg_pass)
proc sg_init_buffer*(buf_id: sg_buffer; desc: ptr sg_buffer_desc)
proc sg_init_image*(img_id: sg_image; desc: ptr sg_image_desc)
proc sg_init_shader*(shd_id: sg_shader; desc: ptr sg_shader_desc)
proc sg_init_pipeline*(pip_id: sg_pipeline; desc: ptr sg_pipeline_desc)
proc sg_init_pass*(pass_id: sg_pass; desc: ptr sg_pass_desc)
proc sg_uninit_buffer*(buf_id: sg_buffer): bool
proc sg_uninit_image*(img_id: sg_image): bool
proc sg_uninit_shader*(shd_id: sg_shader): bool
proc sg_uninit_pipeline*(pip_id: sg_pipeline): bool
proc sg_uninit_pass*(pass_id: sg_pass): bool
proc sg_fail_buffer*(buf_id: sg_buffer)
proc sg_fail_image*(img_id: sg_image)
proc sg_fail_shader*(shd_id: sg_shader)
proc sg_fail_pipeline*(pip_id: sg_pipeline)
proc sg_fail_pass*(pass_id: sg_pass)

##  rendering contexts (optional)
proc sg_setup_context*(): sg_context
proc sg_activate_context*(ctx_id: sg_context)
proc sg_discard_context*(ctx_id: sg_context)

##  Backend-specific helper functions, these may come in handy for mixing
##    sokol-gfx rendering with 'native backend' rendering functions.
##
##    This group of functions will be expanded as needed.
##
##  D3D11: return ID3D11Device
proc sg_d3d11_device*(): pointer

##  Metal: return __bridge-casted MTLDevice
proc sg_mtl_device*(): pointer

##  Metal: return __bridge-casted MTLRenderCommandEncoder in current pass (or zero if outside pass)
proc sg_mtl_render_command_encoder*(): pointer


{.pop.}
