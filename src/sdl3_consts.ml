(** SDL3 constants. Values match SDL3 headers. *)

let sdl_init_audio = 0x00000010
let sdl_init_video = 0x00000020
let sdl_init_joystick = 0x00000200
let sdl_init_haptic = 0x00001000
let sdl_init_gamepad = 0x00002000
let sdl_init_events = 0x00004000
let sdl_init_sensor = 0x00008000
let sdl_init_camera = 0x00010000

let sdl_hint_framebuffer_acceleration = "SDL_FRAMEBUFFER_ACCELERATION"
let sdl_hint_audio_driver = "SDL_AUDIO_DRIVER"
let sdl_hint_video_driver = "SDL_VIDEO_DRIVER"

let sdl_hint_default = 0
let sdl_hint_normal = 1
let sdl_hint_override = 2

let sdl_log_category_application = 0
let sdl_log_category_error = 1
let sdl_log_category_system = 2
let sdl_log_category_audio = 3
let sdl_log_category_video = 4
let sdl_log_category_render = 5
let sdl_log_category_input = 6
let sdl_log_category_test = 7

let sdl_log_priority_verbose = 2
let sdl_log_priority_debug = 3
let sdl_log_priority_info = 4
let sdl_log_priority_warn = 5
let sdl_log_priority_error = 6
let sdl_log_priority_critical = 7

(** {1 Window flags} (SDL uses Uint64) *)
let sdl_window_fullscreen = 0x0000000000000001L
let sdl_window_opengl = 0x0000000000000002L
let sdl_window_hidden = 0x0000000000000008L
let sdl_window_borderless = 0x0000000000000010L
let sdl_window_resizable = 0x0000000000000020L
let sdl_window_minimized = 0x0000000000000040L
let sdl_window_maximized = 0x0000000000000080L
let sdl_window_vulkan = 0x0000000010000000L
let sdl_window_metal = 0x0000000020000000L
