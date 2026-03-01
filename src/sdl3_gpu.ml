open Ctypes
open Foreign
open Sdl3_internal

type device = gpu_device
type buffer = gpu_buffer
type texture = gpu_texture
type sampler = gpu_sampler
type shader = gpu_shader
type compute_pipeline = gpu_compute_pipeline
type graphics_pipeline = gpu_graphics_pipeline
type command_buffer = gpu_command_buffer
type render_pass = gpu_render_pass
type compute_pass = gpu_compute_pass
type copy_pass = gpu_copy_pass
type fence = gpu_fence

let sdl_create_gpu_device = foreign "SDL_CreateGPUDevice" (uint32_t @-> bool @-> string_opt @-> returning gpu_device)
let sdl_destroy_gpu_device = foreign "SDL_DestroyGPUDevice" (gpu_device @-> returning void)

let destroy_device = sdl_destroy_gpu_device

let create_device ~format_flags ~debug_mode ?name () =
  let dev = sdl_create_gpu_device (Unsigned.UInt32.of_int format_flags) debug_mode name in
  if is_null dev then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Gc.finalise destroy_device dev;
  dev

let sdl_claim_window_for_gpu_device = foreign "SDL_ClaimWindowForGPUDevice" (gpu_device @-> window @-> returning bool)
let claim_window dev win =
  if not (sdl_claim_window_for_gpu_device dev win) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_release_window_from_gpu_device = foreign "SDL_ReleaseWindowFromGPUDevice" (gpu_device @-> window @-> returning void)
let release_window = sdl_release_window_from_gpu_device

type swapchain_composition =
  | Comp_sdr
  | Comp_sdr_linear
  | Comp_hdr_extended_linear
  | Comp_hdr10_st2084

let composition_to_int = function
  | Comp_sdr -> 0
  | Comp_sdr_linear -> 1
  | Comp_hdr_extended_linear -> 2
  | Comp_hdr10_st2084 -> 3

type present_mode =
  | Present_vsync
  | Present_immediate
  | Present_mailbox

let present_mode_to_int = function
  | Present_vsync -> 0
  | Present_immediate -> 1
  | Present_mailbox -> 2

let sdl_set_gpu_swapchain_parameters = foreign "SDL_SetGPUSwapchainParameters" (gpu_device @-> window @-> int @-> int @-> returning bool)
let set_swapchain_parameters dev win comp mode =
  if not (sdl_set_gpu_swapchain_parameters dev win (composition_to_int comp) (present_mode_to_int mode)) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_gpu_swapchain_texture_format = foreign "SDL_GetGPUSwapchainTextureFormat" (gpu_device @-> window @-> returning uint32_t)
let get_swapchain_texture_format dev win =
  Unsigned.UInt32.to_int (sdl_get_gpu_swapchain_texture_format dev win)

let sdl_acquire_gpu_command_buffer = foreign "SDL_AcquireGPUCommandBuffer" (gpu_device @-> returning gpu_command_buffer)
let acquire_command_buffer dev =
  let cb = sdl_acquire_gpu_command_buffer dev in
  if is_null cb then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  cb

let sdl_submit_gpu_command_buffer = foreign "SDL_SubmitGPUCommandBuffer" (gpu_command_buffer @-> returning bool)
let submit_command_buffer cb =
  if not (sdl_submit_gpu_command_buffer cb) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_wait_and_acquire_gpu_swapchain_texture = foreign "SDL_WaitAndAcquireGPUSwapchainTexture" (gpu_command_buffer @-> window @-> ptr gpu_texture @-> ptr uint32_t @-> ptr uint32_t @-> returning bool)
let wait_and_acquire_swapchain_texture cb win =
  let tex = allocate gpu_texture (coerce (ptr void) gpu_texture null) in
  let w = allocate uint32_t Unsigned.UInt32.zero in
  let h = allocate uint32_t Unsigned.UInt32.zero in
  if not (sdl_wait_and_acquire_gpu_swapchain_texture cb win tex w h) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (!@ tex, Unsigned.UInt32.to_int !@ w, Unsigned.UInt32.to_int !@ h)
