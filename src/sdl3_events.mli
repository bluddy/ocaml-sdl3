(** SDL3 event queue. Uses Ctypes to define SDL_Event layout; no C stubs for events. *)

type t
(** An SDL event. Use [get_type] to dispatch and per-field accessors for payload. *)

val poll : unit -> t option
(** [poll ()] returns the next event if available, [None] if the queue is empty. *)

val poll_event : unit -> t option
val wait : unit -> t
val wait_event : unit -> t

type event_type =
  | Quit
  | Terminating
  | Low_memory
  | Will_enter_background
  | Did_enter_background
  | Will_enter_foreground
  | Did_enter_foreground
  | Locale_changed
  | System_theme_changed
  | Display_orientation
  | Display_added
  | Display_removed
  | Display_moved
  | Display_desktop_mode_changed
  | Display_current_mode_changed
  | Display_content_scale_changed
  | Display_usable_bounds_changed
  | Window_shown
  | Window_hidden
  | Window_exposed
  | Window_moved
  | Window_resized
  | Window_pixel_size_changed
  | Window_metal_view_resized
  | Window_minimized
  | Window_maximized
  | Window_restored
  | Window_mouse_enter
  | Window_mouse_leave
  | Window_focus_gained
  | Window_focus_lost
  | Window_close_requested
  | Window_hit_test
  | Window_iccprof_changed
  | Window_display_changed
  | Window_display_scale_changed
  | Window_safe_area_changed
  | Window_occluded
  | Window_enter_fullscreen
  | Window_leave_fullscreen
  | Window_destroyed
  | Window_hdr_state_changed
  | Key_down
  | Key_up
  | Text_editing
  | Text_input
  | Keymap_changed
  | Keyboard_added
  | Keyboard_removed
  | Text_editing_candidates
  | Screen_keyboard_shown
  | Screen_keyboard_hidden
  | Mouse_motion
  | Mouse_button_down
  | Mouse_button_up
  | Mouse_wheel
  | Mouse_added
  | Mouse_removed
  | Joystick_axis_motion
  | Joystick_ball_motion
  | Joystick_hat_motion
  | Joystick_button_down
  | Joystick_button_up
  | Joystick_added
  | Joystick_removed
  | Joystick_battery_updated
  | Joystick_update_complete
  | Gamepad_axis_motion
  | Gamepad_button_down
  | Gamepad_button_up
  | Gamepad_added
  | Gamepad_removed
  | Gamepad_remapped
  | Gamepad_touchpad_down
  | Gamepad_touchpad_motion
  | Gamepad_touchpad_up
  | Gamepad_sensor_update
  | Gamepad_update_complete
  | Gamepad_steam_handle_updated
  | Finger_down
  | Finger_up
  | Finger_motion
  | Finger_canceled
  | Pinch_begin
  | Pinch_update
  | Pinch_end
  | Clipboard_update
  | Drop_file
  | Drop_text
  | Drop_begin
  | Drop_complete
  | Drop_position
  | Audio_device_added
  | Audio_device_removed
  | Audio_device_format_changed
  | Sensor_update
  | Pen_proximity_in
  | Pen_proximity_out
  | Pen_down
  | Pen_up
  | Pen_button_down
  | Pen_button_up
  | Pen_motion
  | Pen_axis
  | Camera_device_added
  | Camera_device_removed
  | Camera_device_approved
  | Camera_device_denied
  | Render_targets_reset
  | Render_device_reset
  | Render_device_lost
  | User_event of int
  | Unknown of int

val get_type : t -> event_type
(** [get_type e] returns the event type. Use pattern matching for exhaustive dispatch. *)

val get_type_raw : t -> int
(** [get_type_raw e] returns the raw SDL event type value (SDL_EventType). *)

val event_type_of_int : int -> event_type
val event_type_to_int : event_type -> int

val get_window_from_event : t -> Sdl3_video.window option
(** [get_window_from_event e] returns the window associated with the event, if any. *)

(** {2 Per-field accessors (zero allocation)}

    Only reads and converts the requested field. No record allocation.
    Use [get_type] to dispatch, then the accessors for that event kind.

    {[
      match Event.get_type e with
      | Key_down ->
          let scancode = Event.Key.scancode e in
          let repeat = Event.Key.repeat e in
          if not repeat then handle_key scancode
      | _ -> ()
    ]} *)

module Key : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val scancode : t -> int
  val key : t -> int
  val modifiers : t -> int
  val down : t -> bool
  val repeat : t -> bool
end

module Mouse_motion : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val state : t -> int
  val x : t -> float
  val y : t -> float
  val xrel : t -> float
  val yrel : t -> float
end

module Mouse_button : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val button : t -> int
  val down : t -> bool
  val clicks : t -> int
  val x : t -> float
  val y : t -> float
end

type wheel_direction = Normal | Flipped

module Mouse_wheel : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val x : t -> float
  val y : t -> float
  val direction : t -> wheel_direction
  val mouse_x : t -> float
  val mouse_y : t -> float
end

module Window : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val data1 : t -> int
  val data2 : t -> int
end

module Drop : sig
  val timestamp : t -> int
  val window_id : t -> int32
  val x : t -> float
  val y : t -> float
  val data : t -> string option
end

module Gamepad_button : sig
  val timestamp : t -> int
  val which : t -> Sdl3_gamepad.instance_id
  val button : t -> Sdl3_gamepad.gamepad_button
  val down : t -> bool
end

module Gamepad_axis : sig
  val timestamp : t -> int
  val which : t -> Sdl3_gamepad.instance_id
  val axis : t -> Sdl3_gamepad.gamepad_axis
  val value : t -> int
end
(** [value] is in [-32768, 32767]. *)

module Gamepad_device : sig
  val timestamp : t -> int
  val which : t -> Sdl3_gamepad.instance_id
end

