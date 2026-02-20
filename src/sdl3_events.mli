(** SDL3 event queue. *)

type t = bytes

val poll_event : unit -> t option
(** [poll_event ()] returns the next event if available, [None] if the queue is empty. *)

val wait_event : unit -> t
(** [wait_event ()] blocks until an event is available. @raises Sdl_error on failure. *)

val get_type : t -> int
(** [get_type e] returns the event type (SDL_EventType). *)

val get_window_from_event : t -> Sdl3_video.window option
(** [get_window_from_event e] returns the window associated with the event, if any. *)

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
