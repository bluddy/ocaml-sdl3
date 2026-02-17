(** SDL3 constants: init flags, hints, log categories. *)

(** {1 Init flags} *)
val sdl_init_audio : int
val sdl_init_video : int
val sdl_init_joystick : int
val sdl_init_haptic : int
val sdl_init_gamepad : int
val sdl_init_events : int
val sdl_init_sensor : int
val sdl_init_camera : int

(** {1 Hints} *)
val sdl_hint_framebuffer_acceleration : string
val sdl_hint_audio_driver : string
val sdl_hint_video_driver : string

val sdl_hint_default : int
val sdl_hint_normal : int
val sdl_hint_override : int

(** {1 Log} *)
val sdl_log_category_application : int
val sdl_log_category_error : int
val sdl_log_category_system : int
val sdl_log_category_audio : int
val sdl_log_category_video : int
val sdl_log_category_render : int
val sdl_log_category_input : int
val sdl_log_category_test : int

val sdl_log_priority_verbose : int
val sdl_log_priority_debug : int
val sdl_log_priority_info : int
val sdl_log_priority_warn : int
val sdl_log_priority_error : int
val sdl_log_priority_critical : int
