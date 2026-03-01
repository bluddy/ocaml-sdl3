open Ctypes

type rect_tag
val rect_tag : rect_tag structure typ
val rect_x : (int, rect_tag structure) field
val rect_y : (int, rect_tag structure) field
val rect_w : (int, rect_tag structure) field
val rect_h : (int, rect_tag structure) field

type window_tag
val window_tag : window_tag structure typ
type window = window_tag structure ptr
val window : window typ

type renderer_tag
val renderer_tag : renderer_tag structure typ
type renderer = renderer_tag structure ptr
val renderer : renderer typ

type texture_tag
val texture_tag : texture_tag structure typ
type texture = texture_tag structure ptr
val texture : texture typ

type surface_tag
val surface_tag : surface_tag structure typ
type surface_ptr = surface_tag structure ptr
val surface_ptr : surface_ptr typ

type stream_tag
val stream_tag : stream_tag structure typ
type stream = stream_tag structure ptr
val stream : stream typ

type gamepad_tag
val gamepad_tag : gamepad_tag structure typ
type gamepad = gamepad_tag structure ptr
val gamepad : gamepad typ

(* GPU Types *)

type gpu_device_tag
val gpu_device_tag : gpu_device_tag structure typ
type gpu_device = gpu_device_tag structure ptr
val gpu_device : gpu_device typ

type gpu_buffer_tag
val gpu_buffer_tag : gpu_buffer_tag structure typ
type gpu_buffer = gpu_buffer_tag structure ptr
val gpu_buffer : gpu_buffer typ

type gpu_texture_tag
val gpu_texture_tag : gpu_texture_tag structure typ
type gpu_texture = gpu_texture_tag structure ptr
val gpu_texture : gpu_texture typ

type gpu_sampler_tag
val gpu_sampler_tag : gpu_sampler_tag structure typ
type gpu_sampler = gpu_sampler_tag structure ptr
val gpu_sampler : gpu_sampler typ

type gpu_shader_tag
val gpu_shader_tag : gpu_shader_tag structure typ
type gpu_shader = gpu_shader_tag structure ptr
val gpu_shader : gpu_shader typ

type gpu_compute_pipeline_tag
val gpu_compute_pipeline_tag : gpu_compute_pipeline_tag structure typ
type gpu_compute_pipeline = gpu_compute_pipeline_tag structure ptr
val gpu_compute_pipeline : gpu_compute_pipeline typ

type gpu_graphics_pipeline_tag
val gpu_graphics_pipeline_tag : gpu_graphics_pipeline_tag structure typ
type gpu_graphics_pipeline = gpu_graphics_pipeline_tag structure ptr
val gpu_graphics_pipeline : gpu_graphics_pipeline typ

type gpu_command_buffer_tag
val gpu_command_buffer_tag : gpu_command_buffer_tag structure typ
type gpu_command_buffer = gpu_command_buffer_tag structure ptr
val gpu_command_buffer : gpu_command_buffer typ

type gpu_render_pass_tag
val gpu_render_pass_tag : gpu_render_pass_tag structure typ
type gpu_render_pass = gpu_render_pass_tag structure ptr
val gpu_render_pass : gpu_render_pass typ

type gpu_compute_pass_tag
val gpu_compute_pass_tag : gpu_compute_pass_tag structure typ
type gpu_compute_pass = gpu_compute_pass_tag structure ptr
val gpu_compute_pass : gpu_compute_pass typ

type gpu_copy_pass_tag
val gpu_copy_pass_tag : gpu_copy_pass_tag structure typ
type gpu_copy_pass = gpu_copy_pass_tag structure ptr
val gpu_copy_pass : gpu_copy_pass typ

type gpu_fence_tag
val gpu_fence_tag : gpu_fence_tag structure typ
type gpu_fence = gpu_fence_tag structure ptr
val gpu_fence : gpu_fence typ

type scale_mode =
  | Scale_nearest
  | Scale_linear
  | Scale_pixelart
  | Scale_unknown of int

val scale_mode_to_int : scale_mode -> int
val scale_mode_of_int : int -> scale_mode

val sdl3_ptr_addr : unit ptr -> int64

external sdl3_bigarray_of_ptr :
  nativeint ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  = "sdl3_bigarray_of_ptr"

val sdl_free : unit ptr -> unit

val consume_c_string : char ptr option -> string option
