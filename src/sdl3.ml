open Ctypes
open Foreign
open Sdl3_consts

exception Sdl_error = Sdl3_error.Sdl_error
let get_error = Sdl3_error.get_error
let clear_error = Sdl3_error.clear_error
let set_error = Sdl3_error.set_error

module Init = struct
  type t = Unsigned.UInt32.t
  let of_int = Unsigned.UInt32.of_int
  let ( + ) = Unsigned.UInt32.logor
  let ( - ) f f' = Unsigned.UInt32.(logand f (lognot f'))
  let test f m = Unsigned.UInt32.(compare (logand f m) zero <> 0)
  let nothing = of_int 0
  let audio = of_int sdl_init_audio
  let video = of_int sdl_init_video
  let joystick = of_int sdl_init_joystick
  let haptic = of_int sdl_init_haptic
  let gamepad = of_int sdl_init_gamepad
  let events = of_int sdl_init_events
  let sensor = of_int sdl_init_sensor
  let camera = of_int sdl_init_camera
end

let sdl_init = foreign "SDL_Init" (uint32_t @-> returning bool)
let sdl_init_subsystem = foreign "SDL_InitSubSystem" (uint32_t @-> returning bool)
let init flags = if not (sdl_init flags) then raise (Sdl_error (get_error ()))
let init_subsystem flags = if not (sdl_init_subsystem flags) then raise (Sdl_error (get_error ()))
let quit = foreign "SDL_Quit" (void @-> returning void)
let quit_subsystem = foreign "SDL_QuitSubSystem" (uint32_t @-> returning void)
let sdl_was_init = foreign "SDL_WasInit" (uint32_t @-> returning uint32_t)
let was_init = function None -> sdl_was_init Init.nothing | Some f -> sdl_was_init f

module Hint = struct
  type t = string
  type priority = int
  let framebuffer_acceleration = sdl_hint_framebuffer_acceleration
  let audio_driver = sdl_hint_audio_driver
  let video_driver = sdl_hint_video_driver
  let default = sdl_hint_default
  let normal = sdl_hint_normal
  let override = sdl_hint_override
end
let reset_hints = foreign "SDL_ResetHints" (void @-> returning void)
let get_hint = foreign "SDL_GetHint" (string @-> returning string_opt)
let get_hint_boolean = foreign "SDL_GetHintBoolean" (string @-> bool @-> returning bool)
let set_hint = foreign "SDL_SetHint" (string @-> string @-> returning bool)
let set_hint_with_priority = foreign "SDL_SetHintWithPriority" (string @-> string @-> int @-> returning bool)

let set_main_ready = foreign "SDL_SetMainReady" (void @-> returning void)

module Log = struct
  type category = int
  let category_application = sdl_log_category_application
  let category_error = sdl_log_category_error
  let category_system = sdl_log_category_system
  let category_audio = sdl_log_category_audio
  let category_video = sdl_log_category_video
  let category_render = sdl_log_category_render
  let category_input = sdl_log_category_input
  let category_test = sdl_log_category_test

  type priority = int
  let priority_verbose = sdl_log_priority_verbose
  let priority_debug = sdl_log_priority_debug
  let priority_info = sdl_log_priority_info
  let priority_warn = sdl_log_priority_warn
  let priority_error = sdl_log_priority_error
  let priority_critical = sdl_log_priority_critical
end

external log_message_stub : int -> int -> string -> unit = "sdl3_log_message_stub"

let log_message category priority msg = log_message_stub category priority msg
let log msg = log_message_stub Log.category_application Log.priority_info msg

let log_get_priority = foreign "SDL_GetLogPriority" (int @-> returning int)
let log_reset_priorities = foreign "SDL_ResetLogPriorities" (void @-> returning void)
let log_set_all_priority = foreign "SDL_SetLogPriorities" (int @-> returning void)
let log_set_priority = foreign "SDL_SetLogPriority" (int @-> int @-> returning void)

let sdl_get_version = foreign "SDL_GetVersion" (void @-> returning int)
let get_revision = foreign "SDL_GetRevision" (void @-> returning string)

let version_num_major v = v / 1_000_000
let version_num_minor v = (v / 1_000) mod 1_000
let version_num_micro v = v mod 1_000

let get_version () =
  let v = sdl_get_version () in
  (version_num_major v, version_num_minor v, version_num_micro v)

(** {1 Events} *)
module Event = Sdl3_events

(** {1 Audio} *)o

module Surface = Sdl3_surface
module Render = Sdl3_render

(** {1 Video} *)
module Video = struct
  type rect = Sdl3_video.rect
  type display_id = Sdl3_video.display_id
  type window = Sdl3_video.window
  type window_flags = Sdl3_video.window_flags

  let get_displays = Sdl3_video.get_displays
  let get_display_name = Sdl3_video.get_display_name
  let get_display_bounds = Sdl3_video.get_display_bounds

  module Rect = Sdl3_video.Rect
  module Window = Sdl3_video.Window
  let create_window = Sdl3_video.create_window
  let destroy_window = Sdl3_video.destroy_window
  let get_window_id = Sdl3_video.get_window_id
  let get_window_from_id = Sdl3_video.get_window_from_id
  let get_window_display = Sdl3_video.get_window_display
  let display_id_to_int32 = Sdl3_video.display_id_to_int32
end
