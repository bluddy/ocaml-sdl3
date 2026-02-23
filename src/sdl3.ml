open Ctypes
open Foreign
open Sdl3_consts

exception Sdl_error = Sdl3_error.Sdl_error
let get_error = Sdl3_error.get_error
let clear_error = Sdl3_error.clear_error
let set_error = Sdl3_error.set_error

type init_flag =
  | Audio
  | Video
  | Joystick
  | Haptic
  | Gamepad
  | Events
  | Sensor
  | Camera

let init_flag_to_int = function
  | Audio -> sdl_init_audio
  | Video -> sdl_init_video
  | Joystick -> sdl_init_joystick
  | Haptic -> sdl_init_haptic
  | Gamepad -> sdl_init_gamepad
  | Events -> sdl_init_events
  | Sensor -> sdl_init_sensor
  | Camera -> sdl_init_camera

let init_flags_to_uint32 flags =
  List.fold_left
    (fun acc f ->
      Unsigned.UInt32.logor acc (Unsigned.UInt32.of_int (init_flag_to_int f)))
    Unsigned.UInt32.zero flags

let init_flags_of_uint32 v =
  let all =
    [ Audio; Video; Joystick; Haptic; Gamepad; Events; Sensor; Camera ]
  in
  List.filter
    (fun f ->
      Unsigned.UInt32.(compare (logand v (of_int (init_flag_to_int f))) zero <> 0))
    all

module Init = struct
  type flag = init_flag

  let all : flag list =
    [ Audio; Video; Joystick; Haptic; Gamepad; Events; Sensor; Camera ]

  let test flags flag =
    List.mem flag flags

  let nothing = Unsigned.UInt32.zero
  let audio = Audio
  let video = Video
  let joystick = Joystick
  let haptic = Haptic
  let gamepad = Gamepad
  let events = Events
  let sensor = Sensor
  let camera = Camera
end

let sdl_init = foreign "SDL_Init" (uint32_t @-> returning bool)
let sdl_init_subsystem = foreign "SDL_InitSubSystem" (uint32_t @-> returning bool)
let init flags =
  if not (sdl_init (init_flags_to_uint32 flags))
  then raise (Sdl_error (get_error ()))
let init_subsystem flags =
  if not (sdl_init_subsystem (init_flags_to_uint32 flags))
  then raise (Sdl_error (get_error ()))
let quit = foreign "SDL_Quit" (void @-> returning void)
let sdl_quit_subsystem = foreign "SDL_QuitSubSystem" (uint32_t @-> returning void)
let quit_subsystem flags =
  sdl_quit_subsystem (init_flags_to_uint32 flags)
let sdl_was_init = foreign "SDL_WasInit" (uint32_t @-> returning uint32_t)
let was_init = function
  | None -> init_flags_of_uint32 (sdl_was_init Init.nothing)
  | Some flags -> init_flags_of_uint32 (sdl_was_init (init_flags_to_uint32 flags))

type hint_priority = Hint_default | Hint_normal | Hint_override

let hint_priority_to_int = function
  | Hint_default -> sdl_hint_default
  | Hint_normal -> sdl_hint_normal
  | Hint_override -> sdl_hint_override

module Hint = struct
  type t = string
  type priority = hint_priority
  let framebuffer_acceleration = sdl_hint_framebuffer_acceleration
  let audio_driver = sdl_hint_audio_driver
  let video_driver = sdl_hint_video_driver
  let default = Hint_default
  let normal = Hint_normal
  let override = Hint_override
end
let reset_hints = foreign "SDL_ResetHints" (void @-> returning void)
let get_hint = foreign "SDL_GetHint" (string @-> returning string_opt)
let get_hint_boolean = foreign "SDL_GetHintBoolean" (string @-> bool @-> returning bool)
let set_hint = foreign "SDL_SetHint" (string @-> string @-> returning bool)
let sdl_set_hint_with_priority = foreign "SDL_SetHintWithPriority" (string @-> string @-> int @-> returning bool)
let set_hint_with_priority name value priority =
  sdl_set_hint_with_priority name value (hint_priority_to_int priority)

let set_main_ready = foreign "SDL_SetMainReady" (void @-> returning void)

type log_category =
  | Log_application
  | Log_error
  | Log_system
  | Log_audio
  | Log_video
  | Log_render
  | Log_input
  | Log_test

let log_category_to_int = function
  | Log_application -> sdl_log_category_application
  | Log_error -> sdl_log_category_error
  | Log_system -> sdl_log_category_system
  | Log_audio -> sdl_log_category_audio
  | Log_video -> sdl_log_category_video
  | Log_render -> sdl_log_category_render
  | Log_input -> sdl_log_category_input
  | Log_test -> sdl_log_category_test

type log_priority =
  | Log_verbose
  | Log_debug
  | Log_info
  | Log_warn
  | Log_error_priority
  | Log_critical

let log_priority_to_int = function
  | Log_verbose -> sdl_log_priority_verbose
  | Log_debug -> sdl_log_priority_debug
  | Log_info -> sdl_log_priority_info
  | Log_warn -> sdl_log_priority_warn
  | Log_error_priority -> sdl_log_priority_error
  | Log_critical -> sdl_log_priority_critical

let log_priority_of_int = function
  | 2 -> Log_verbose
  | 3 -> Log_debug
  | 4 -> Log_info
  | 5 -> Log_warn
  | 6 -> Log_error_priority
  | 7 -> Log_critical
  | _ -> Log_info

module Log = struct
  type category = log_category
  let category_application = Log_application
  let category_error = Log_error
  let category_system = Log_system
  let category_audio = Log_audio
  let category_video = Log_video
  let category_render = Log_render
  let category_input = Log_input
  let category_test = Log_test

  type priority = log_priority
  let priority_verbose = Log_verbose
  let priority_debug = Log_debug
  let priority_info = Log_info
  let priority_warn = Log_warn
  let priority_error = Log_error_priority
  let priority_critical = Log_critical
end

external log_message_stub : int -> int -> string -> unit = "sdl3_log_message_stub"

let log_message category priority msg =
  log_message_stub (log_category_to_int category) (log_priority_to_int priority) msg
let log msg = log_message Log_application Log_info msg

let log_get_priority_raw = foreign "SDL_GetLogPriority" (int @-> returning int)
let log_get_priority cat = log_priority_of_int (log_get_priority_raw (log_category_to_int cat))
let log_reset_priorities = foreign "SDL_ResetLogPriorities" (void @-> returning void)
let log_set_all_priority = foreign "SDL_SetLogPriorities" (int @-> returning void)
let sdl_set_log_priority = foreign "SDL_SetLogPriority" (int @-> int @-> returning void)
let log_set_priority cat pri =
  sdl_set_log_priority (log_category_to_int cat) (log_priority_to_int pri)

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

(** {1 Audio} *)
module Audio = Sdl3_audio

module Surface = Sdl3_surface
module Render = Sdl3_render

(** {1 Video} *)
module Video = struct
  type rect = Sdl3_video.rect
  type display_id = Sdl3_video.display_id
  type window = Sdl3_video.window
  type window_flag = Sdl3_video.window_flag

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
