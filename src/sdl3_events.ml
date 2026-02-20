(** SDL3 event queue. *)

open Ctypes
open Sdl3_consts

(** Event buffer (128 bytes, opaque). Type is stored in first 4 bytes (little-endian). *)
type t = bytes

let event_size = 128

external poll_event_stub : bytes -> bool = "sdl3_poll_event_stub"
external wait_event_stub : bytes -> bool = "sdl3_wait_event_stub"
external get_window_from_event_stub : bytes -> nativeint = "sdl3_get_window_from_event_stub"

let get_type buf =
  assert (Bytes.length buf >= 4);
  let b0 = int_of_char (Bytes.get buf 0) in
  let b1 = int_of_char (Bytes.get buf 1) in
  let b2 = int_of_char (Bytes.get buf 2) in
  let b3 = int_of_char (Bytes.get buf 3) in
  b0 lor (b1 lsl 8) lor (b2 lsl 16) lor (b3 lsl 24)

let poll_event () =
  let buf = Bytes.create event_size in
  if poll_event_stub buf then Some buf else None

let wait_event () =
  let buf = Bytes.create event_size in
  if wait_event_stub buf then buf else raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let get_window_from_event (buf : t) : Sdl3_video.window option =
  let ptr = get_window_from_event_stub buf in
  if ptr = 0n then None else Some (Sdl3_video.window_of_ptr (ptr_of_raw_address ptr))

module Type = struct
  let first = sdl_event_first
  let quit = sdl_event_quit
  let terminating = sdl_event_terminating
  let low_memory = sdl_event_low_memory
  let will_enter_background = sdl_event_will_enter_background
  let did_enter_background = sdl_event_did_enter_background
  let will_enter_foreground = sdl_event_will_enter_foreground
  let did_enter_foreground = sdl_event_did_enter_foreground
  let locale_changed = sdl_event_locale_changed
  let system_theme_changed = sdl_event_system_theme_changed
  let display_orientation = sdl_event_display_orientation
  let display_added = sdl_event_display_added
  let display_removed = sdl_event_display_removed
  let display_moved = sdl_event_display_moved
  let display_desktop_mode_changed = sdl_event_display_desktop_mode_changed
  let display_current_mode_changed = sdl_event_display_current_mode_changed
  let display_content_scale_changed = sdl_event_display_content_scale_changed
  let display_usable_bounds_changed = sdl_event_display_usable_bounds_changed
  let window_shown = sdl_event_window_shown
  let window_hidden = sdl_event_window_hidden
  let window_exposed = sdl_event_window_exposed
  let window_moved = sdl_event_window_moved
  let window_resized = sdl_event_window_resized
  let window_pixel_size_changed = sdl_event_window_pixel_size_changed
  let window_metal_view_resized = sdl_event_window_metal_view_resized
  let window_minimized = sdl_event_window_minimized
  let window_maximized = sdl_event_window_maximized
  let window_restored = sdl_event_window_restored
  let window_mouse_enter = sdl_event_window_mouse_enter
  let window_mouse_leave = sdl_event_window_mouse_leave
  let window_focus_gained = sdl_event_window_focus_gained
  let window_focus_lost = sdl_event_window_focus_lost
  let window_close_requested = sdl_event_window_close_requested
  let window_hit_test = sdl_event_window_hit_test
  let window_iccprof_changed = sdl_event_window_iccprof_changed
  let window_display_changed = sdl_event_window_display_changed
  let window_display_scale_changed = sdl_event_window_display_scale_changed
  let window_safe_area_changed = sdl_event_window_safe_area_changed
  let window_occluded = sdl_event_window_occluded
  let window_enter_fullscreen = sdl_event_window_enter_fullscreen
  let window_leave_fullscreen = sdl_event_window_leave_fullscreen
  let window_destroyed = sdl_event_window_destroyed
  let window_hdr_state_changed = sdl_event_window_hdr_state_changed
  let key_down = sdl_event_key_down
  let key_up = sdl_event_key_up
  let text_editing = sdl_event_text_editing
  let text_input = sdl_event_text_input
  let keymap_changed = sdl_event_keymap_changed
  let keyboard_added = sdl_event_keyboard_added
  let keyboard_removed = sdl_event_keyboard_removed
  let text_editing_candidates = sdl_event_text_editing_candidates
  let screen_keyboard_shown = sdl_event_screen_keyboard_shown
  let screen_keyboard_hidden = sdl_event_screen_keyboard_hidden
  let mouse_motion = sdl_event_mouse_motion
  let mouse_button_down = sdl_event_mouse_button_down
  let mouse_button_up = sdl_event_mouse_button_up
  let mouse_wheel = sdl_event_mouse_wheel
  let mouse_added = sdl_event_mouse_added
  let mouse_removed = sdl_event_mouse_removed
  let joystick_axis_motion = sdl_event_joystick_axis_motion
  let joystick_ball_motion = sdl_event_joystick_ball_motion
  let joystick_hat_motion = sdl_event_joystick_hat_motion
  let joystick_button_down = sdl_event_joystick_button_down
  let joystick_button_up = sdl_event_joystick_button_up
  let joystick_added = sdl_event_joystick_added
  let joystick_removed = sdl_event_joystick_removed
  let joystick_battery_updated = sdl_event_joystick_battery_updated
  let joystick_update_complete = sdl_event_joystick_update_complete
  let gamepad_axis_motion = sdl_event_gamepad_axis_motion
  let gamepad_button_down = sdl_event_gamepad_button_down
  let gamepad_button_up = sdl_event_gamepad_button_up
  let gamepad_added = sdl_event_gamepad_added
  let gamepad_removed = sdl_event_gamepad_removed
  let gamepad_remapped = sdl_event_gamepad_remapped
  let gamepad_touchpad_down = sdl_event_gamepad_touchpad_down
  let gamepad_touchpad_motion = sdl_event_gamepad_touchpad_motion
  let gamepad_touchpad_up = sdl_event_gamepad_touchpad_up
  let gamepad_sensor_update = sdl_event_gamepad_sensor_update
  let gamepad_update_complete = sdl_event_gamepad_update_complete
  let gamepad_steam_handle_updated = sdl_event_gamepad_steam_handle_updated
  let finger_down = sdl_event_finger_down
  let finger_up = sdl_event_finger_up
  let finger_motion = sdl_event_finger_motion
  let finger_canceled = sdl_event_finger_canceled
  let pinch_begin = sdl_event_pinch_begin
  let pinch_update = sdl_event_pinch_update
  let pinch_end = sdl_event_pinch_end
  let clipboard_update = sdl_event_clipboard_update
  let drop_file = sdl_event_drop_file
  let drop_text = sdl_event_drop_text
  let drop_begin = sdl_event_drop_begin
  let drop_complete = sdl_event_drop_complete
  let drop_position = sdl_event_drop_position
  let audio_device_added = sdl_event_audio_device_added
  let audio_device_removed = sdl_event_audio_device_removed
  let audio_device_format_changed = sdl_event_audio_device_format_changed
  let sensor_update = sdl_event_sensor_update
  let pen_proximity_in = sdl_event_pen_proximity_in
  let pen_proximity_out = sdl_event_pen_proximity_out
  let pen_down = sdl_event_pen_down
  let pen_up = sdl_event_pen_up
  let pen_button_down = sdl_event_pen_button_down
  let pen_button_up = sdl_event_pen_button_up
  let pen_motion = sdl_event_pen_motion
  let pen_axis = sdl_event_pen_axis
  let camera_device_added = sdl_event_camera_device_added
  let camera_device_removed = sdl_event_camera_device_removed
  let camera_device_approved = sdl_event_camera_device_approved
  let camera_device_denied = sdl_event_camera_device_denied
  let render_targets_reset = sdl_event_render_targets_reset
  let render_device_reset = sdl_event_render_device_reset
  let render_device_lost = sdl_event_render_device_lost
  let user = sdl_event_user
  let last = sdl_event_last
end
