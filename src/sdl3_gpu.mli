(** SDL3 GPU API. *)

type device
type buffer
type texture
type sampler
type shader
type compute_pipeline
type graphics_pipeline
type command_buffer
type render_pass
type compute_pass
type copy_pass
type fence

val create_device : format_flags:int -> debug_mode:bool -> ?name:string -> unit -> device
val destroy_device : device -> unit

val claim_window : device -> Sdl3_video.window -> unit
val release_window : device -> Sdl3_video.window -> unit

type swapchain_composition =
  | Comp_sdr
  | Comp_sdr_linear
  | Comp_hdr_extended_linear
  | Comp_hdr10_st2084

type present_mode =
  | Present_vsync
  | Present_immediate
  | Present_mailbox

val set_swapchain_parameters : device -> Sdl3_video.window -> swapchain_composition -> present_mode -> unit
val get_swapchain_texture_format : device -> Sdl3_video.window -> int

val acquire_command_buffer : device -> command_buffer
val submit_command_buffer : command_buffer -> unit

val wait_and_acquire_swapchain_texture : command_buffer -> Sdl3_video.window -> texture * int * int
