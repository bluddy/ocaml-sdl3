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

let poll = poll_event

let wait_event () =
  let ev = make () in
  if sdl_wait_event (addr ev) then ev
  else raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let wait = wait_event

let get_type_raw (ev : t) = Unsigned.UInt32.to_int (getf ev ev_type)

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

let event_type_of_int = function
  | 0x100 -> Quit
  | 0x101 -> Terminating
  | 0x102 -> Low_memory
  | 0x103 -> Will_enter_background
  | 0x104 -> Did_enter_background
  | 0x105 -> Will_enter_foreground
  | 0x106 -> Did_enter_foreground
  | 0x107 -> Locale_changed
  | 0x108 -> System_theme_changed
  | 0x151 -> Display_orientation
  | 0x152 -> Display_added
  | 0x153 -> Display_removed
  | 0x154 -> Display_moved
  | 0x155 -> Display_desktop_mode_changed
  | 0x156 -> Display_current_mode_changed
  | 0x157 -> Display_content_scale_changed
  | 0x158 -> Display_usable_bounds_changed
  | 0x202 -> Window_shown
  | 0x203 -> Window_hidden
  | 0x204 -> Window_exposed
  | 0x205 -> Window_moved
  | 0x206 -> Window_resized
  | 0x207 -> Window_pixel_size_changed
  | 0x208 -> Window_metal_view_resized
  | 0x209 -> Window_minimized
  | 0x20a -> Window_maximized
  | 0x20b -> Window_restored
  | 0x20c -> Window_mouse_enter
  | 0x20d -> Window_mouse_leave
  | 0x20e -> Window_focus_gained
  | 0x20f -> Window_focus_lost
  | 0x210 -> Window_close_requested
  | 0x211 -> Window_hit_test
  | 0x212 -> Window_iccprof_changed
  | 0x213 -> Window_display_changed
  | 0x214 -> Window_display_scale_changed
  | 0x215 -> Window_safe_area_changed
  | 0x216 -> Window_occluded
  | 0x217 -> Window_enter_fullscreen
  | 0x218 -> Window_leave_fullscreen
  | 0x219 -> Window_destroyed
  | 0x21a -> Window_hdr_state_changed
  | 0x300 -> Key_down
  | 0x301 -> Key_up
  | 0x302 -> Text_editing
  | 0x303 -> Text_input
  | 0x304 -> Keymap_changed
  | 0x305 -> Keyboard_added
  | 0x306 -> Keyboard_removed
  | 0x307 -> Text_editing_candidates
  | 0x308 -> Screen_keyboard_shown
  | 0x309 -> Screen_keyboard_hidden
  | 0x400 -> Mouse_motion
  | 0x401 -> Mouse_button_down
  | 0x402 -> Mouse_button_up
  | 0x403 -> Mouse_wheel
  | 0x404 -> Mouse_added
  | 0x405 -> Mouse_removed
  | 0x600 -> Joystick_axis_motion
  | 0x601 -> Joystick_ball_motion
  | 0x602 -> Joystick_hat_motion
  | 0x603 -> Joystick_button_down
  | 0x604 -> Joystick_button_up
  | 0x605 -> Joystick_added
  | 0x606 -> Joystick_removed
  | 0x607 -> Joystick_battery_updated
  | 0x608 -> Joystick_update_complete
  | 0x650 -> Gamepad_axis_motion
  | 0x651 -> Gamepad_button_down
  | 0x652 -> Gamepad_button_up
  | 0x653 -> Gamepad_added
  | 0x654 -> Gamepad_removed
  | 0x655 -> Gamepad_remapped
  | 0x656 -> Gamepad_touchpad_down
  | 0x657 -> Gamepad_touchpad_motion
  | 0x658 -> Gamepad_touchpad_up
  | 0x659 -> Gamepad_sensor_update
  | 0x65a -> Gamepad_update_complete
  | 0x65b -> Gamepad_steam_handle_updated
  | 0x700 -> Finger_down
  | 0x701 -> Finger_up
  | 0x702 -> Finger_motion
  | 0x703 -> Finger_canceled
  | 0x710 -> Pinch_begin
  | 0x711 -> Pinch_update
  | 0x712 -> Pinch_end
  | 0x900 -> Clipboard_update
  | 0x1000 -> Drop_file
  | 0x1001 -> Drop_text
  | 0x1002 -> Drop_begin
  | 0x1003 -> Drop_complete
  | 0x1004 -> Drop_position
  | 0x1100 -> Audio_device_added
  | 0x1101 -> Audio_device_removed
  | 0x1102 -> Audio_device_format_changed
  | 0x1200 -> Sensor_update
  | 0x1300 -> Pen_proximity_in
  | 0x1301 -> Pen_proximity_out
  | 0x1302 -> Pen_down
  | 0x1303 -> Pen_up
  | 0x1304 -> Pen_button_down
  | 0x1305 -> Pen_button_up
  | 0x1306 -> Pen_motion
  | 0x1307 -> Pen_axis
  | 0x1400 -> Camera_device_added
  | 0x1401 -> Camera_device_removed
  | 0x1402 -> Camera_device_approved
  | 0x1403 -> Camera_device_denied
  | 0x2000 -> Render_targets_reset
  | 0x2001 -> Render_device_reset
  | 0x2002 -> Render_device_lost
  | i when i >= sdl_event_user -> User_event i
  | i -> Unknown i

let event_type_to_int : event_type -> int = function
  | Quit -> sdl_event_quit
  | Terminating -> sdl_event_terminating
  | Low_memory -> sdl_event_low_memory
  | Will_enter_background -> sdl_event_will_enter_background
  | Did_enter_background -> sdl_event_did_enter_background
  | Will_enter_foreground -> sdl_event_will_enter_foreground
  | Did_enter_foreground -> sdl_event_did_enter_foreground
  | Locale_changed -> sdl_event_locale_changed
  | System_theme_changed -> sdl_event_system_theme_changed
  | Display_orientation -> sdl_event_display_orientation
  | Display_added -> sdl_event_display_added
  | Display_removed -> sdl_event_display_removed
  | Display_moved -> sdl_event_display_moved
  | Display_desktop_mode_changed -> sdl_event_display_desktop_mode_changed
  | Display_current_mode_changed -> sdl_event_display_current_mode_changed
  | Display_content_scale_changed -> sdl_event_display_content_scale_changed
  | Display_usable_bounds_changed -> sdl_event_display_usable_bounds_changed
  | Window_shown -> sdl_event_window_shown
  | Window_hidden -> sdl_event_window_hidden
  | Window_exposed -> sdl_event_window_exposed
  | Window_moved -> sdl_event_window_moved
  | Window_resized -> sdl_event_window_resized
  | Window_pixel_size_changed -> sdl_event_window_pixel_size_changed
  | Window_metal_view_resized -> sdl_event_window_metal_view_resized
  | Window_minimized -> sdl_event_window_minimized
  | Window_maximized -> sdl_event_window_maximized
  | Window_restored -> sdl_event_window_restored
  | Window_mouse_enter -> sdl_event_window_mouse_enter
  | Window_mouse_leave -> sdl_event_window_mouse_leave
  | Window_focus_gained -> sdl_event_window_focus_gained
  | Window_focus_lost -> sdl_event_window_focus_lost
  | Window_close_requested -> sdl_event_window_close_requested
  | Window_hit_test -> sdl_event_window_hit_test
  | Window_iccprof_changed -> sdl_event_window_iccprof_changed
  | Window_display_changed -> sdl_event_window_display_changed
  | Window_display_scale_changed -> sdl_event_window_display_scale_changed
  | Window_safe_area_changed -> sdl_event_window_safe_area_changed
  | Window_occluded -> sdl_event_window_occluded
  | Window_enter_fullscreen -> sdl_event_window_enter_fullscreen
  | Window_leave_fullscreen -> sdl_event_window_leave_fullscreen
  | Window_destroyed -> sdl_event_window_destroyed
  | Window_hdr_state_changed -> sdl_event_window_hdr_state_changed
  | Key_down -> sdl_event_key_down
  | Key_up -> sdl_event_key_up
  | Text_editing -> sdl_event_text_editing
  | Text_input -> sdl_event_text_input
  | Keymap_changed -> sdl_event_keymap_changed
  | Keyboard_added -> sdl_event_keyboard_added
  | Keyboard_removed -> sdl_event_keyboard_removed
  | Text_editing_candidates -> sdl_event_text_editing_candidates
  | Screen_keyboard_shown -> sdl_event_screen_keyboard_shown
  | Screen_keyboard_hidden -> sdl_event_screen_keyboard_hidden
  | Mouse_motion -> sdl_event_mouse_motion
  | Mouse_button_down -> sdl_event_mouse_button_down
  | Mouse_button_up -> sdl_event_mouse_button_up
  | Mouse_wheel -> sdl_event_mouse_wheel
  | Mouse_added -> sdl_event_mouse_added
  | Mouse_removed -> sdl_event_mouse_removed
  | Joystick_axis_motion -> sdl_event_joystick_axis_motion
  | Joystick_ball_motion -> sdl_event_joystick_ball_motion
  | Joystick_hat_motion -> sdl_event_joystick_hat_motion
  | Joystick_button_down -> sdl_event_joystick_button_down
  | Joystick_button_up -> sdl_event_joystick_button_up
  | Joystick_added -> sdl_event_joystick_added
  | Joystick_removed -> sdl_event_joystick_removed
  | Joystick_battery_updated -> sdl_event_joystick_battery_updated
  | Joystick_update_complete -> sdl_event_joystick_update_complete
  | Gamepad_axis_motion -> sdl_event_gamepad_axis_motion
  | Gamepad_button_down -> sdl_event_gamepad_button_down
  | Gamepad_button_up -> sdl_event_gamepad_button_up
  | Gamepad_added -> sdl_event_gamepad_added
  | Gamepad_removed -> sdl_event_gamepad_removed
  | Gamepad_remapped -> sdl_event_gamepad_remapped
  | Gamepad_touchpad_down -> sdl_event_gamepad_touchpad_down
  | Gamepad_touchpad_motion -> sdl_event_gamepad_touchpad_motion
  | Gamepad_touchpad_up -> sdl_event_gamepad_touchpad_up
  | Gamepad_sensor_update -> sdl_event_gamepad_sensor_update
  | Gamepad_update_complete -> sdl_event_gamepad_update_complete
  | Gamepad_steam_handle_updated -> sdl_event_gamepad_steam_handle_updated
  | Finger_down -> sdl_event_finger_down
  | Finger_up -> sdl_event_finger_up
  | Finger_motion -> sdl_event_finger_motion
  | Finger_canceled -> sdl_event_finger_canceled
  | Pinch_begin -> sdl_event_pinch_begin
  | Pinch_update -> sdl_event_pinch_update
  | Pinch_end -> sdl_event_pinch_end
  | Clipboard_update -> sdl_event_clipboard_update
  | Drop_file -> sdl_event_drop_file
  | Drop_text -> sdl_event_drop_text
  | Drop_begin -> sdl_event_drop_begin
  | Drop_complete -> sdl_event_drop_complete
  | Drop_position -> sdl_event_drop_position
  | Audio_device_added -> sdl_event_audio_device_added
  | Audio_device_removed -> sdl_event_audio_device_removed
  | Audio_device_format_changed -> sdl_event_audio_device_format_changed
  | Sensor_update -> sdl_event_sensor_update
  | Pen_proximity_in -> sdl_event_pen_proximity_in
  | Pen_proximity_out -> sdl_event_pen_proximity_out
  | Pen_down -> sdl_event_pen_down
  | Pen_up -> sdl_event_pen_up
  | Pen_button_down -> sdl_event_pen_button_down
  | Pen_button_up -> sdl_event_pen_button_up
  | Pen_motion -> sdl_event_pen_motion
  | Pen_axis -> sdl_event_pen_axis
  | Camera_device_added -> sdl_event_camera_device_added
  | Camera_device_removed -> sdl_event_camera_device_removed
  | Camera_device_approved -> sdl_event_camera_device_approved
  | Camera_device_denied -> sdl_event_camera_device_denied
  | Render_targets_reset -> sdl_event_render_targets_reset
  | Render_device_reset -> sdl_event_render_device_reset
  | Render_device_lost -> sdl_event_render_device_lost
  | User_event i -> i
  | Unknown i -> i

let get_type ev = event_type_of_int (get_type_raw ev)

let get_window_from_event (ev : t) : Sdl3_video.window option =
  let w = sdl_get_window_from_event (addr ev) in
  if is_null w then None else Some (Obj.magic w : Sdl3_video.window)

(* ---- Per-field accessors (zero allocation, reads only requested field) ---- *)

module Field = struct
  type _ field =
    F : (('a structure, event_union union) Ctypes.field * ('b, 'a structure) Ctypes.field)
        -> 'b field

  let get e (F (s, f)) = getf (getf e s) f

  (* Keyboard *)
  let key_timestamp = F (key, Keyboard_event.timestamp)
  let key_window_id = F (key, Keyboard_event.window_id)
  let key_scancode = F (key, Keyboard_event.scancode)
  let key_key = F (key, Keyboard_event.key)
  let key_modifiers = F (key, Keyboard_event.keymod)
  let key_down = F (key, Keyboard_event.down)
  let key_repeat = F (key, Keyboard_event.repeat)

  (* Mouse motion *)
  let mouse_motion_timestamp = F (motion, Mouse_motion_event.timestamp)
  let mouse_motion_window_id = F (motion, Mouse_motion_event.window_id)
  let mouse_motion_state = F (motion, Mouse_motion_event.state)
  let mouse_motion_x = F (motion, Mouse_motion_event.x)
  let mouse_motion_y = F (motion, Mouse_motion_event.y)
  let mouse_motion_xrel = F (motion, Mouse_motion_event.xrel)
  let mouse_motion_yrel = F (motion, Mouse_motion_event.yrel)

  (* Mouse button *)
  let mouse_button_timestamp = F (button, Mouse_button_event.timestamp)
  let mouse_button_window_id = F (button, Mouse_button_event.window_id)
  let mouse_button_button = F (button, Mouse_button_event.button)
  let mouse_button_down = F (button, Mouse_button_event.down)
  let mouse_button_clicks = F (button, Mouse_button_event.clicks)
  let mouse_button_x = F (button, Mouse_button_event.x)
  let mouse_button_y = F (button, Mouse_button_event.y)

  (* Mouse wheel *)
  let mouse_wheel_timestamp = F (wheel, Mouse_wheel_event.timestamp)
  let mouse_wheel_window_id = F (wheel, Mouse_wheel_event.window_id)
  let mouse_wheel_x = F (wheel, Mouse_wheel_event.x)
  let mouse_wheel_y = F (wheel, Mouse_wheel_event.y)
  let mouse_wheel_direction = F (wheel, Mouse_wheel_event.direction)
  let mouse_wheel_mouse_x = F (wheel, Mouse_wheel_event.mouse_x)
  let mouse_wheel_mouse_y = F (wheel, Mouse_wheel_event.mouse_y)

  (* Window *)
  let window_timestamp = F (window, Window_event.timestamp)
  let window_window_id = F (window, Window_event.window_id)
  let window_data1 = F (window, Window_event.data1)
  let window_data2 = F (window, Window_event.data2)

  (* Drop *)
  let drop_timestamp = F (drop, Drop_event.timestamp)
  let drop_window_id = F (drop, Drop_event.window_id)
  let drop_x = F (drop, Drop_event.x)
  let drop_y = F (drop, Drop_event.y)
  let drop_data = F (drop, Drop_event.data)
end

(** Accessors by event kind. Only the requested field is read; no allocation. *)
module Key = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.key_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.key_window_id)
  let scancode e = Signed.Int32.to_int (Field.get e Field.key_scancode)
  let key e = Signed.Int32.to_int (Field.get e Field.key_key)
  let modifiers e = Unsigned.UInt16.to_int (Field.get e Field.key_modifiers)
  let down e = Field.get e Field.key_down
  let repeat e = Field.get e Field.key_repeat
end

module Mouse_motion = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.mouse_motion_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.mouse_motion_window_id)
  let state e = Unsigned.UInt32.to_int (Field.get e Field.mouse_motion_state)
  let x e = Field.get e Field.mouse_motion_x
  let y e = Field.get e Field.mouse_motion_y
  let xrel e = Field.get e Field.mouse_motion_xrel
  let yrel e = Field.get e Field.mouse_motion_yrel
end

module Mouse_button = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.mouse_button_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.mouse_button_window_id)
  let button e = Unsigned.UInt8.to_int (Field.get e Field.mouse_button_button)
  let down e = Field.get e Field.mouse_button_down
  let clicks e = Unsigned.UInt8.to_int (Field.get e Field.mouse_button_clicks)
  let x e = Field.get e Field.mouse_button_x
  let y e = Field.get e Field.mouse_button_y
end

type wheel_direction = Normal | Flipped

let wheel_direction_of_int = function
  | 0 -> Normal
  | _ -> Flipped

module Mouse_wheel = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.mouse_wheel_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.mouse_wheel_window_id)
  let x e = Field.get e Field.mouse_wheel_x
  let y e = Field.get e Field.mouse_wheel_y
  let direction e = wheel_direction_of_int (Signed.Int32.to_int (Field.get e Field.mouse_wheel_direction))
  let mouse_x e = Field.get e Field.mouse_wheel_mouse_x
  let mouse_y e = Field.get e Field.mouse_wheel_mouse_y
end

module Window = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.window_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.window_window_id)
  let data1 e = Signed.Int32.to_int (Field.get e Field.window_data1)
  let data2 e = Signed.Int32.to_int (Field.get e Field.window_data2)
end

module Drop = struct
  let timestamp e = Unsigned.UInt64.to_int (Field.get e Field.drop_timestamp)
  let window_id e = Unsigned.UInt32.to_int32 (Field.get e Field.drop_window_id)
  let x e = Field.get e Field.drop_x
  let y e = Field.get e Field.drop_y
  let data e =
    let p = Field.get e Field.drop_data in
    if is_null p then None else Some (coerce (ptr char) string p)
end

