open Ctypes

type rect_tag
let rect_tag : rect_tag structure typ = structure "SDL_Rect"
let rect_x = field rect_tag "x" int
let rect_y = field rect_tag "y" int
let rect_w = field rect_tag "w" int
let rect_h = field rect_tag "h" int
let () = seal rect_tag

type window_tag
let window_tag : window_tag structure typ = structure "SDL_Window"
type window = window_tag structure ptr
let window : window typ = ptr window_tag

type renderer_tag
let renderer_tag : renderer_tag structure typ = structure "SDL_Renderer"
type renderer = renderer_tag structure ptr
let renderer : renderer typ = ptr renderer_tag

type texture_tag
let texture_tag : texture_tag structure typ = structure "SDL_Texture"
type texture = texture_tag structure ptr
let texture : texture typ = ptr texture_tag

type surface_tag
let surface_tag : surface_tag structure typ = structure "SDL_Surface"
type surface_ptr = surface_tag structure ptr
let surface_ptr : surface_ptr typ = ptr surface_tag

type stream_tag
let stream_tag : stream_tag structure typ = structure "SDL_AudioStream"
type stream = stream_tag structure ptr
let stream : stream typ = ptr stream_tag

type gamepad_tag
let gamepad_tag : gamepad_tag structure typ = structure "SDL_Gamepad"
type gamepad = gamepad_tag structure ptr
let gamepad : gamepad typ = ptr gamepad_tag

(* GPU Tags *)

type gpu_device_tag
let gpu_device_tag : gpu_device_tag structure typ = structure "SDL_GPUDevice"
type gpu_device = gpu_device_tag structure ptr
let gpu_device : gpu_device typ = ptr gpu_device_tag

type gpu_buffer_tag
let gpu_buffer_tag : gpu_buffer_tag structure typ = structure "SDL_GPUBuffer"
type gpu_buffer = gpu_buffer_tag structure ptr
let gpu_buffer : gpu_buffer typ = ptr gpu_buffer_tag

type gpu_texture_tag
let gpu_texture_tag : gpu_texture_tag structure typ = structure "SDL_GPUTexture"
type gpu_texture = gpu_texture_tag structure ptr
let gpu_texture : gpu_texture typ = ptr gpu_texture_tag

type gpu_sampler_tag
let gpu_sampler_tag : gpu_sampler_tag structure typ = structure "SDL_GPUSampler"
type gpu_sampler = gpu_sampler_tag structure ptr
let gpu_sampler : gpu_sampler typ = ptr gpu_sampler_tag

type gpu_shader_tag
let gpu_shader_tag : gpu_shader_tag structure typ = structure "SDL_GPUShader"
type gpu_shader = gpu_shader_tag structure ptr
let gpu_shader : gpu_shader typ = ptr gpu_shader_tag

type gpu_compute_pipeline_tag
let gpu_compute_pipeline_tag : gpu_compute_pipeline_tag structure typ = structure "SDL_GPUComputePipeline"
type gpu_compute_pipeline = gpu_compute_pipeline_tag structure ptr
let gpu_compute_pipeline : gpu_compute_pipeline typ = ptr gpu_compute_pipeline_tag

type gpu_graphics_pipeline_tag
let gpu_graphics_pipeline_tag : gpu_graphics_pipeline_tag structure typ = structure "SDL_GPUGraphicsPipeline"
type gpu_graphics_pipeline = gpu_graphics_pipeline_tag structure ptr
let gpu_graphics_pipeline : gpu_graphics_pipeline typ = ptr gpu_graphics_pipeline_tag

type gpu_command_buffer_tag
let gpu_command_buffer_tag : gpu_command_buffer_tag structure typ = structure "SDL_GPUCommandBuffer"
type gpu_command_buffer = gpu_command_buffer_tag structure ptr
let gpu_command_buffer : gpu_command_buffer typ = ptr gpu_command_buffer_tag

type gpu_render_pass_tag
let gpu_render_pass_tag : gpu_render_pass_tag structure typ = structure "SDL_GPURenderPass"
type gpu_render_pass = gpu_render_pass_tag structure ptr
let gpu_render_pass : gpu_render_pass typ = ptr gpu_render_pass_tag

type gpu_compute_pass_tag
let gpu_compute_pass_tag : gpu_compute_pass_tag structure typ = structure "SDL_GPUComputePass"
type gpu_compute_pass = gpu_compute_pass_tag structure ptr
let gpu_compute_pass : gpu_compute_pass typ = ptr gpu_compute_pass_tag

type gpu_copy_pass_tag
let gpu_copy_pass_tag : gpu_copy_pass_tag structure typ = structure "SDL_GPUCopyPass"
type gpu_copy_pass = gpu_copy_pass_tag structure ptr
let gpu_copy_pass : gpu_copy_pass typ = ptr gpu_copy_pass_tag

type gpu_fence_tag
let gpu_fence_tag : gpu_fence_tag structure typ = structure "SDL_GPUFence"
type gpu_fence = gpu_fence_tag structure ptr
let gpu_fence : gpu_fence typ = ptr gpu_fence_tag

type scale_mode =
  | Scale_nearest
  | Scale_linear
  | Scale_pixelart
  | Scale_unknown of int

let sdl_scalemode_nearest = 0
let sdl_scalemode_linear = 1
let sdl_scalemode_pixelart = 2

let scale_mode_to_int = function
  | Scale_nearest -> sdl_scalemode_nearest
  | Scale_linear -> sdl_scalemode_linear
  | Scale_pixelart -> sdl_scalemode_pixelart
  | Scale_unknown i -> i

let scale_mode_of_int i =
  if i = sdl_scalemode_nearest then Scale_nearest
  else if i = sdl_scalemode_linear then Scale_linear
  else if i = sdl_scalemode_pixelart then Scale_pixelart
  else Scale_unknown i

let sdl3_ptr_addr = Foreign.foreign "sdl3_ptr_addr" (ptr void @-> returning int64_t)

external sdl3_bigarray_of_ptr :
  nativeint ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  = "sdl3_bigarray_of_ptr"

let sdl_free = Foreign.foreign "SDL_free" (ptr void @-> returning void)

let consume_c_string p_opt =
  match p_opt with
  | None -> None
  | Some p ->
      let s = coerce (ptr char) string p in
      sdl_free (to_voidp p);
      Some s
