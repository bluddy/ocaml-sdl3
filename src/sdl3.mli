(** SDL3 OCaml bindings.

    [open Sdl3] to use the bindings. Most functions raise [Sdl3.Sdl_error] on
    SDL failure. SDL has main-thread requirements on some platforms; prefer
    init/quit and window ops on the main thread.
*)

exception Sdl_error of string

(** {1 Error handling} *)
val get_error : unit -> string
val clear_error : unit -> unit
val set_error : string -> unit

val set_main_ready : unit -> unit
(** Call before [init] when SDL is used from a non-main thread.
    Required on some platforms (e.g. bundled apps). *)

(** {1 Init} *)
module Init : sig
  type t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val test : t -> t -> bool
  val nothing : t
  val audio : t
  val video : t
  val joystick : t
  val haptic : t
  val gamepad : t
  val events : t
  val sensor : t
  val camera : t
end
val init : Init.t -> unit
val init_subsystem : Init.t -> unit
val quit : unit -> unit
val quit_subsystem : Init.t -> unit
val was_init : Init.t option -> Init.t
(** [was_init None] returns currently initialized flags.
    [was_init (Some mask)] returns flags matching [mask]. *)

(** {1 Hints} *)
module Hint : sig
  type t = string
  type priority = int
  val framebuffer_acceleration : t
  val audio_driver : t
  val video_driver : t
  val default : priority
  val normal : priority
  val override : priority
end
val reset_hints : unit -> unit
val get_hint : string -> string option
val get_hint_boolean : string -> bool -> bool
val set_hint : string -> string -> bool
val set_hint_with_priority : string -> string -> Hint.priority -> bool

(** {1 Log} *)
module Log : sig
  type category = int
  val category_application : category
  val category_error : category
  val category_system : category
  val category_audio : category
  val category_video : category
  val category_render : category
  val category_input : category
  val category_test : category

  type priority = int
  val priority_verbose : priority
  val priority_debug : priority
  val priority_info : priority
  val priority_warn : priority
  val priority_error : priority
  val priority_critical : priority
end
val log : string -> unit
val log_message : int -> int -> string -> unit
val log_get_priority : int -> int
val log_reset_priorities : unit -> unit
val log_set_all_priority : int -> unit
val log_set_priority : int -> int -> unit

(** {1 Version} *)
val get_version : unit -> int * int * int
val get_revision : unit -> string

(** {1 Video}

    [create_window] raises [Sdl_error] on failure. [destroy_window] invalidates
    the window; using it afterwards is undefined behaviour. *)
module Video : sig
  type rect = Sdl3_video.rect
  type display_id = Sdl3_video.display_id
  type window
  type window_flags = Sdl3_video.window_flags

  val get_displays : unit -> display_id list
  val get_display_name : display_id -> string option
  val get_display_bounds : display_id -> rect option

  module Window : sig
    val ( + ) : window_flags -> window_flags -> window_flags
    val none : window_flags
    val fullscreen : window_flags
    val opengl : window_flags
    val hidden : window_flags
    val borderless : window_flags
    val resizable : window_flags
    val vulkan : window_flags
    val metal : window_flags
  end

  val create_window : string -> int -> int -> window_flags -> window
  val destroy_window : window -> unit
  val get_window_id : window -> int32
  val get_window_from_id : int32 -> window option
  val get_window_display : window -> display_id
  val display_id_to_int32 : display_id -> int32
end

(** {1 Events} *)
module Event : sig
  type t = bytes
  val poll : unit -> t option
  val wait : unit -> t
  val get_type : t -> int
  val get_window_from_event : t -> Video.window option
  module Type : sig
    val first : int
    val quit : int
    val terminating : int
    val low_memory : int
    val will_enter_background : int
    val did_enter_background : int
    val will_enter_foreground : int
    val did_enter_foreground : int
    val locale_changed : int
    val system_theme_changed : int
    val display_orientation : int
    val display_added : int
    val display_removed : int
    val display_moved : int
    val display_desktop_mode_changed : int
    val display_current_mode_changed : int
    val display_content_scale_changed : int
    val display_usable_bounds_changed : int
    val window_shown : int
    val window_hidden : int
    val window_exposed : int
    val window_moved : int
    val window_resized : int
    val window_pixel_size_changed : int
    val window_metal_view_resized : int
    val window_minimized : int
    val window_maximized : int
    val window_restored : int
    val window_mouse_enter : int
    val window_mouse_leave : int
    val window_focus_gained : int
    val window_focus_lost : int
    val window_close_requested : int
    val window_hit_test : int
    val window_iccprof_changed : int
    val window_display_changed : int
    val window_display_scale_changed : int
    val window_safe_area_changed : int
    val window_occluded : int
    val window_enter_fullscreen : int
    val window_leave_fullscreen : int
    val window_destroyed : int
    val window_hdr_state_changed : int
    val key_down : int
    val key_up : int
    val text_editing : int
    val text_input : int
    val keymap_changed : int
    val keyboard_added : int
    val keyboard_removed : int
    val text_editing_candidates : int
    val screen_keyboard_shown : int
    val screen_keyboard_hidden : int
    val mouse_motion : int
    val mouse_button_down : int
    val mouse_button_up : int
    val mouse_wheel : int
    val mouse_added : int
    val mouse_removed : int
    val joystick_axis_motion : int
    val joystick_ball_motion : int
    val joystick_hat_motion : int
    val joystick_button_down : int
    val joystick_button_up : int
    val joystick_added : int
    val joystick_removed : int
    val joystick_battery_updated : int
    val joystick_update_complete : int
    val gamepad_axis_motion : int
    val gamepad_button_down : int
    val gamepad_button_up : int
    val gamepad_added : int
    val gamepad_removed : int
    val gamepad_remapped : int
    val gamepad_touchpad_down : int
    val gamepad_touchpad_motion : int
    val gamepad_touchpad_up : int
    val gamepad_sensor_update : int
    val gamepad_update_complete : int
    val gamepad_steam_handle_updated : int
    val finger_down : int
    val finger_up : int
    val finger_motion : int
    val finger_canceled : int
    val pinch_begin : int
    val pinch_update : int
    val pinch_end : int
    val clipboard_update : int
    val drop_file : int
    val drop_text : int
    val drop_begin : int
    val drop_complete : int
    val drop_position : int
    val audio_device_added : int
    val audio_device_removed : int
    val audio_device_format_changed : int
    val sensor_update : int
    val pen_proximity_in : int
    val pen_proximity_out : int
    val pen_down : int
    val pen_up : int
    val pen_button_down : int
    val pen_button_up : int
    val pen_motion : int
    val pen_axis : int
    val camera_device_added : int
    val camera_device_removed : int
    val camera_device_approved : int
    val camera_device_denied : int
    val render_targets_reset : int
    val render_device_reset : int
    val render_device_lost : int
    val user : int
    val last : int
  end
end
