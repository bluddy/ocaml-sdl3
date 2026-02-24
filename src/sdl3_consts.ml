(** SDL3 constants. Values match SDL3 headers.
    Matched SDL version: 3.2.0+ (verify against your installed SDL). *)

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

(** {1 Gamepad} (SDL_gamepad.h) *)
(* SDL_GamepadButton *)
let sdl_gamepad_button_invalid = -1
let sdl_gamepad_button_south = 0
let sdl_gamepad_button_east = 1
let sdl_gamepad_button_west = 2
let sdl_gamepad_button_north = 3
let sdl_gamepad_button_back = 4
let sdl_gamepad_button_guide = 5
let sdl_gamepad_button_start = 6
let sdl_gamepad_button_left_stick = 7
let sdl_gamepad_button_right_stick = 8
let sdl_gamepad_button_left_shoulder = 9
let sdl_gamepad_button_right_shoulder = 10
let sdl_gamepad_button_dpad_up = 11
let sdl_gamepad_button_dpad_down = 12
let sdl_gamepad_button_dpad_left = 13
let sdl_gamepad_button_dpad_right = 14
let sdl_gamepad_button_misc1 = 15
let sdl_gamepad_button_right_paddle1 = 16
let sdl_gamepad_button_left_paddle1 = 17
let sdl_gamepad_button_right_paddle2 = 18
let sdl_gamepad_button_left_paddle2 = 19
let sdl_gamepad_button_touchpad = 20
let sdl_gamepad_button_misc2 = 21
let sdl_gamepad_button_misc3 = 22
let sdl_gamepad_button_misc4 = 23
let sdl_gamepad_button_misc5 = 24
let sdl_gamepad_button_misc6 = 25

(* SDL_GamepadAxis *)
let sdl_gamepad_axis_invalid = -1
let sdl_gamepad_axis_left_x = 0
let sdl_gamepad_axis_left_y = 1
let sdl_gamepad_axis_right_x = 2
let sdl_gamepad_axis_right_y = 3
let sdl_gamepad_axis_left_trigger = 4
let sdl_gamepad_axis_right_trigger = 5

(* SDL_Joystick axis range *)
let sdl_joystick_axis_min = -32768
let sdl_joystick_axis_max = 32767

(** {1 Event types} (SDL_EventType, from SDL_events.h) *)
(* Application *)
let sdl_event_first = 0
let sdl_event_quit = 0x100
let sdl_event_terminating = 0x101
let sdl_event_low_memory = 0x102
let sdl_event_will_enter_background = 0x103
let sdl_event_did_enter_background = 0x104
let sdl_event_will_enter_foreground = 0x105
let sdl_event_did_enter_foreground = 0x106
let sdl_event_locale_changed = 0x107
let sdl_event_system_theme_changed = 0x108
(* Display *)
let sdl_event_display_orientation = 0x151
let sdl_event_display_added = 0x152
let sdl_event_display_removed = 0x153
let sdl_event_display_moved = 0x154
let sdl_event_display_desktop_mode_changed = 0x155
let sdl_event_display_current_mode_changed = 0x156
let sdl_event_display_content_scale_changed = 0x157
let sdl_event_display_usable_bounds_changed = 0x158
(* Window *)
let sdl_event_window_shown = 0x202
let sdl_event_window_hidden = 0x203
let sdl_event_window_exposed = 0x204
let sdl_event_window_moved = 0x205
let sdl_event_window_resized = 0x206
let sdl_event_window_pixel_size_changed = 0x207
let sdl_event_window_metal_view_resized = 0x208
let sdl_event_window_minimized = 0x209
let sdl_event_window_maximized = 0x20a
let sdl_event_window_restored = 0x20b
let sdl_event_window_mouse_enter = 0x20c
let sdl_event_window_mouse_leave = 0x20d
let sdl_event_window_focus_gained = 0x20e
let sdl_event_window_focus_lost = 0x20f
let sdl_event_window_close_requested = 0x210
let sdl_event_window_hit_test = 0x211
let sdl_event_window_iccprof_changed = 0x212
let sdl_event_window_display_changed = 0x213
let sdl_event_window_display_scale_changed = 0x214
let sdl_event_window_safe_area_changed = 0x215
let sdl_event_window_occluded = 0x216
let sdl_event_window_enter_fullscreen = 0x217
let sdl_event_window_leave_fullscreen = 0x218
let sdl_event_window_destroyed = 0x219
let sdl_event_window_hdr_state_changed = 0x21a
(* Keyboard *)
let sdl_event_key_down = 0x300
let sdl_event_key_up = 0x301
let sdl_event_text_editing = 0x302
let sdl_event_text_input = 0x303
let sdl_event_keymap_changed = 0x304
let sdl_event_keyboard_added = 0x305
let sdl_event_keyboard_removed = 0x306
let sdl_event_text_editing_candidates = 0x307
let sdl_event_screen_keyboard_shown = 0x308
let sdl_event_screen_keyboard_hidden = 0x309
(* Mouse *)
let sdl_event_mouse_motion = 0x400
let sdl_event_mouse_button_down = 0x401
let sdl_event_mouse_button_up = 0x402
let sdl_event_mouse_wheel = 0x403
let sdl_event_mouse_added = 0x404
let sdl_event_mouse_removed = 0x405
(* Joystick *)
let sdl_event_joystick_axis_motion = 0x600
let sdl_event_joystick_ball_motion = 0x601
let sdl_event_joystick_hat_motion = 0x602
let sdl_event_joystick_button_down = 0x603
let sdl_event_joystick_button_up = 0x604
let sdl_event_joystick_added = 0x605
let sdl_event_joystick_removed = 0x606
let sdl_event_joystick_battery_updated = 0x607
let sdl_event_joystick_update_complete = 0x608
(* Gamepad *)
let sdl_event_gamepad_axis_motion = 0x650
let sdl_event_gamepad_button_down = 0x651
let sdl_event_gamepad_button_up = 0x652
let sdl_event_gamepad_added = 0x653
let sdl_event_gamepad_removed = 0x654
let sdl_event_gamepad_remapped = 0x655
let sdl_event_gamepad_touchpad_down = 0x656
let sdl_event_gamepad_touchpad_motion = 0x657
let sdl_event_gamepad_touchpad_up = 0x658
let sdl_event_gamepad_sensor_update = 0x659
let sdl_event_gamepad_update_complete = 0x65a
let sdl_event_gamepad_steam_handle_updated = 0x65b
(* Touch *)
let sdl_event_finger_down = 0x700
let sdl_event_finger_up = 0x701
let sdl_event_finger_motion = 0x702
let sdl_event_finger_canceled = 0x703
(* Pinch *)
let sdl_event_pinch_begin = 0x710
let sdl_event_pinch_update = 0x711
let sdl_event_pinch_end = 0x712
(* Clipboard *)
let sdl_event_clipboard_update = 0x900
(* Drag and drop *)
let sdl_event_drop_file = 0x1000
let sdl_event_drop_text = 0x1001
let sdl_event_drop_begin = 0x1002
let sdl_event_drop_complete = 0x1003
let sdl_event_drop_position = 0x1004
(* Audio *)
let sdl_event_audio_device_added = 0x1100
let sdl_event_audio_device_removed = 0x1101
let sdl_event_audio_device_format_changed = 0x1102
(* Sensor *)
let sdl_event_sensor_update = 0x1200
(* Pen *)
let sdl_event_pen_proximity_in = 0x1300
let sdl_event_pen_proximity_out = 0x1301
let sdl_event_pen_down = 0x1302
let sdl_event_pen_up = 0x1303
let sdl_event_pen_button_down = 0x1304
let sdl_event_pen_button_up = 0x1305
let sdl_event_pen_motion = 0x1306
let sdl_event_pen_axis = 0x1307
(* Camera *)
let sdl_event_camera_device_added = 0x1400
let sdl_event_camera_device_removed = 0x1401
let sdl_event_camera_device_approved = 0x1402
let sdl_event_camera_device_denied = 0x1403
(* Render *)
let sdl_event_render_targets_reset = 0x2000
let sdl_event_render_device_reset = 0x2001
let sdl_event_render_device_lost = 0x2002
(* User *)
let sdl_event_user = 0x8000
let sdl_event_last = 0xffff

(** Mouse wheel direction (SDL_MouseWheelDirection) *)
let sdl_mousewheel_normal = 0
let sdl_mousewheel_flipped = 1

(** {1 Audio}
    SDL default-device sentinels (SDL_AudioDeviceID). Use with
    [Unsigned.UInt32.of_int32] to pass to SDL; e.g. 0xFFFFFFFFl -> playback. *)
let sdl_audio_device_default_playback = 0xFFFFFFFFl
let sdl_audio_device_default_recording = 0xFFFFFFFEl

(** Audio formats (SDL_AudioFormat) *)
let sdl_audio_unknown = 0x0000
let sdl_audio_u8 = 0x0008
let sdl_audio_s8 = 0x8008
let sdl_audio_s16le = 0x8010
let sdl_audio_s16be = 0x9010
let sdl_audio_s32le = 0x8020
let sdl_audio_s32be = 0x9020
let sdl_audio_f32le = 0x8120
let sdl_audio_f32be = 0x9120
let sdl_audio_s16 = 0x8010
let sdl_audio_s32 = 0x8020
let sdl_audio_f32 = 0x8120

(** {1 Pixel formats} (SDL_PixelFormat, Uint32) *)
let sdl_pixelformat_unknown = 0
let sdl_pixelformat_rgba8888 = 0x16462004
let sdl_pixelformat_argb8888 = 0x16362004
let sdl_pixelformat_rgb24 = 0x17101803
let sdl_pixelformat_bgr24 = 0x17401803
let sdl_pixelformat_rgb565 = 0x15151002
let sdl_pixelformat_bgr565 = 0x15551002

(** {1 Texture access} (SDL_TextureAccess) *)
let sdl_textureaccess_static = 0
let sdl_textureaccess_streaming = 1
let sdl_textureaccess_target = 2

(** {1 Blend modes} (SDL_BlendMode, Uint32) *)
let sdl_blendmode_none = 0x00000000
let sdl_blendmode_blend = 0x00000001
let sdl_blendmode_blend_premultiplied = 0x00000010
let sdl_blendmode_add = 0x00000002
let sdl_blendmode_add_premultiplied = 0x00000020
let sdl_blendmode_mod = 0x00000004
let sdl_blendmode_mul = 0x00000008
let sdl_blendmode_invalid = 0x7FFFFFFF

(** {1 Scale modes} (SDL_ScaleMode) *)
let sdl_scalemode_invalid = -1
let sdl_scalemode_nearest = 0
let sdl_scalemode_linear = 1
let sdl_scalemode_pixelart = 2

(** {1 Flip modes} (SDL_FlipMode) *)
let sdl_flip_none = 0
let sdl_flip_horizontal = 0x1
let sdl_flip_vertical = 0x2
let sdl_flip_horizontal_and_vertical = 0x3

(** {1 Renderer names} (strings) *)
let sdl_software_renderer = "software"
let sdl_gpu_renderer = "gpu"

(** {1 Renderer logical presentation} (SDL_RendererLogicalPresentation) *)
let sdl_logical_presentation_disabled = 0
let sdl_logical_presentation_stretch = 1
let sdl_logical_presentation_letterbox = 2
let sdl_logical_presentation_overscan = 3
let sdl_logical_presentation_integer_scale = 4

(** {1 VSync} *)
let sdl_renderer_vsync_disabled = 0
let sdl_renderer_vsync_adaptive = -1

(** {1 Texture address mode} (SDL_TextureAddressMode) *)
let sdl_texture_address_invalid = -1
let sdl_texture_address_auto = 0
let sdl_texture_address_clamp = 1
let sdl_texture_address_wrap = 2
