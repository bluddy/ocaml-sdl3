(** SDL3 event queue. Uses Ctypes to define SDL_Event layout and Foreign for SDL calls. *)

open Ctypes
open Foreign
open Sdl3_consts

(* ---- Ctypes event structures (SDL3 layout) ---- *)

module Keyboard_event = struct
  type t
  let t : t structure typ = structure "SDL_KeyboardEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let _which = field t "which" uint32_t
  let scancode = field t "scancode" int32_t
  let key = field t "key" int32_t
  let keymod = field t "mod" uint16_t
  let _raw = field t "raw" uint16_t
  let down = field t "down" bool
  let repeat = field t "repeat" bool
  let () = seal t
end

module Mouse_motion_event = struct
  type t
  let t : t structure typ = structure "SDL_MouseMotionEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let _which = field t "which" uint32_t
  let state = field t "state" uint32_t
  let x = field t "x" float
  let y = field t "y" float
  let xrel = field t "xrel" float
  let yrel = field t "yrel" float
  let () = seal t
end

module Mouse_button_event = struct
  type t
  let t : t structure typ = structure "SDL_MouseButtonEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let _which = field t "which" uint32_t
  let button = field t "button" uint8_t
  let down = field t "down" bool
  let clicks = field t "clicks" uint8_t
  let _padding = field t "padding" uint8_t
  let x = field t "x" float
  let y = field t "y" float
  let () = seal t
end

module Mouse_wheel_event = struct
  type t
  let t : t structure typ = structure "SDL_MouseWheelEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let _which = field t "which" uint32_t
  let x = field t "x" float
  let y = field t "y" float
  let direction = field t "direction" int32_t
  let mouse_x = field t "mouse_x" float
  let mouse_y = field t "mouse_y" float
  let _integer_x = field t "integer_x" int32_t
  let _integer_y = field t "integer_y" int32_t
  let () = seal t
end

module Window_event = struct
  type t
  let t : t structure typ = structure "SDL_WindowEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let data1 = field t "data1" int32_t
  let data2 = field t "data2" int32_t
  let () = seal t
end

module Drop_event = struct
  type t
  let t : t structure typ = structure "SDL_DropEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let timestamp = field t "timestamp" uint64_t
  let window_id = field t "windowID" uint32_t
  let x = field t "x" float
  let y = field t "y" float
  let _source = field t "source" (ptr char)
  let data = field t "data" (ptr char)
  let () = seal t
end

(* SDL_CommonEvent - shared header for all events *)
module Common_event = struct
  type t
  let t : t structure typ = structure "SDL_CommonEvent"
  let _type = field t "type" uint32_t
  let _reserved = field t "reserved" uint32_t
  let _timestamp = field t "timestamp" uint64_t
  let () = seal t
end

external sdl_event_size : unit -> int = "sdl3_event_size"

(* SDL_Event union - all event types overlay at the same address.
   Pad to SDL_Event size so SDL_PollEvent doesn't overflow our buffer. *)
type event_union
let event_t : event_union union typ = union "SDL_Event"
let ev_type = field event_t "type" uint32_t
let _common = field event_t "common" Common_event.t
let key = field event_t "key" Keyboard_event.t
let motion = field event_t "motion" Mouse_motion_event.t
let button = field event_t "button" Mouse_button_event.t
let wheel = field event_t "wheel" Mouse_wheel_event.t
let window = field event_t "window" Window_event.t
let drop = field event_t "drop" Drop_event.t
let _padding =
  field event_t "padding"
    (abstract ~name:"SDL_Event_padding" ~size:(sdl_event_size ()) ~alignment:1)
let () = seal event_t

(* ---- SDL bindings ---- *)

let sdl_poll_event = foreign "SDL_PollEvent" (ptr event_t @-> returning bool)
let sdl_wait_event =
  foreign ~release_runtime_lock:true
    "SDL_WaitEvent" (ptr event_t @-> returning bool)
let sdl_get_window_from_event =
  foreign "SDL_GetWindowFromEvent" (ptr event_t @-> returning (ptr void))

(* ---- Public API ---- *)

type t = event_union union

let make () = make event_t
let addr ev = addr ev

let poll_event () =
  let ev = make () in
  if sdl_poll_event (addr ev) then Some ev else None

let wait_event () =
  let ev = make () in
  if sdl_wait_event (addr ev) then ev
  else raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let get_type (ev : t) = Unsigned.UInt32.to_int (getf ev ev_type)

let get_window_from_event (ev : t) : Sdl3_video.window option =
  let w = sdl_get_window_from_event (addr ev) in
  if is_null w then None else Some (Obj.magic w : Sdl3_video.window)

(* ---- Payload accessors ---- *)

let get_key (ev : t) =
  let k = getf ev key in
  ( Unsigned.UInt64.to_int (getf k Keyboard_event.timestamp),
    Unsigned.UInt32.to_int32 (getf k Keyboard_event.window_id),
    Signed.Int32.to_int (getf k Keyboard_event.scancode),
    Signed.Int32.to_int (getf k Keyboard_event.key),
    Unsigned.UInt16.to_int (getf k Keyboard_event.keymod),
    getf k Keyboard_event.down,
    getf k Keyboard_event.repeat )

let get_mouse_motion (ev : t) =
  let m = getf ev motion in
  ( Unsigned.UInt64.to_int (getf m Mouse_motion_event.timestamp),
    Unsigned.UInt32.to_int32 (getf m Mouse_motion_event.window_id),
    Unsigned.UInt32.to_int (getf m Mouse_motion_event.state),
    getf m Mouse_motion_event.x,
    getf m Mouse_motion_event.y,
    getf m Mouse_motion_event.xrel,
    getf m Mouse_motion_event.yrel )

let get_mouse_button (ev : t) =
  let b = getf ev button in
  ( Unsigned.UInt64.to_int (getf b Mouse_button_event.timestamp),
    Unsigned.UInt32.to_int32 (getf b Mouse_button_event.window_id),
    Unsigned.UInt8.to_int (getf b Mouse_button_event.button),
    getf b Mouse_button_event.down,
    Unsigned.UInt8.to_int (getf b Mouse_button_event.clicks),
    getf b Mouse_button_event.x,
    getf b Mouse_button_event.y )

let get_mouse_wheel (ev : t) =
  let w = getf ev wheel in
  ( Unsigned.UInt64.to_int (getf w Mouse_wheel_event.timestamp),
    Unsigned.UInt32.to_int32 (getf w Mouse_wheel_event.window_id),
    getf w Mouse_wheel_event.x,
    getf w Mouse_wheel_event.y,
    Signed.Int32.to_int (getf w Mouse_wheel_event.direction),
    getf w Mouse_wheel_event.mouse_x,
    getf w Mouse_wheel_event.mouse_y )

let get_window_event (ev : t) =
  let w = getf ev window in
  ( Unsigned.UInt64.to_int (getf w Window_event.timestamp),
    Unsigned.UInt32.to_int32 (getf w Window_event.window_id),
    Signed.Int32.to_int (getf w Window_event.data1),
    Signed.Int32.to_int (getf w Window_event.data2) )

let get_drop (ev : t) =
  let d = getf ev drop in
  let data_ptr = getf d Drop_event.data in
  let data_str = if is_null data_ptr then None else Some (coerce (ptr char) string data_ptr) in
  ( Unsigned.UInt64.to_int (getf d Drop_event.timestamp),
    Unsigned.UInt32.to_int32 (getf d Drop_event.window_id),
    getf d Drop_event.x,
    getf d Drop_event.y,
    data_str )

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

module Wheel = struct
  let normal = sdl_mousewheel_normal
  let flipped = sdl_mousewheel_flipped
end
