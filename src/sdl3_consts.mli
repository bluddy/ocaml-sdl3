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

(** {1 Window flags} (SDL uses Uint64) *)
val sdl_window_fullscreen : int64
val sdl_window_opengl : int64
val sdl_window_hidden : int64
val sdl_window_borderless : int64
val sdl_window_resizable : int64
val sdl_window_minimized : int64
val sdl_window_maximized : int64
val sdl_window_vulkan : int64
val sdl_window_metal : int64

(** {1 Event types} (SDL_EventType) *)
val sdl_event_first : int
val sdl_event_quit : int
val sdl_event_terminating : int
val sdl_event_low_memory : int
val sdl_event_will_enter_background : int
val sdl_event_did_enter_background : int
val sdl_event_will_enter_foreground : int
val sdl_event_did_enter_foreground : int
val sdl_event_locale_changed : int
val sdl_event_system_theme_changed : int
val sdl_event_display_orientation : int
val sdl_event_display_added : int
val sdl_event_display_removed : int
val sdl_event_display_moved : int
val sdl_event_display_desktop_mode_changed : int
val sdl_event_display_current_mode_changed : int
val sdl_event_display_content_scale_changed : int
val sdl_event_display_usable_bounds_changed : int
val sdl_event_window_shown : int
val sdl_event_window_hidden : int
val sdl_event_window_exposed : int
val sdl_event_window_moved : int
val sdl_event_window_resized : int
val sdl_event_window_pixel_size_changed : int
val sdl_event_window_metal_view_resized : int
val sdl_event_window_minimized : int
val sdl_event_window_maximized : int
val sdl_event_window_restored : int
val sdl_event_window_mouse_enter : int
val sdl_event_window_mouse_leave : int
val sdl_event_window_focus_gained : int
val sdl_event_window_focus_lost : int
val sdl_event_window_close_requested : int
val sdl_event_window_hit_test : int
val sdl_event_window_iccprof_changed : int
val sdl_event_window_display_changed : int
val sdl_event_window_display_scale_changed : int
val sdl_event_window_safe_area_changed : int
val sdl_event_window_occluded : int
val sdl_event_window_enter_fullscreen : int
val sdl_event_window_leave_fullscreen : int
val sdl_event_window_destroyed : int
val sdl_event_window_hdr_state_changed : int
val sdl_event_key_down : int
val sdl_event_key_up : int
val sdl_event_text_editing : int
val sdl_event_text_input : int
val sdl_event_keymap_changed : int
val sdl_event_keyboard_added : int
val sdl_event_keyboard_removed : int
val sdl_event_text_editing_candidates : int
val sdl_event_screen_keyboard_shown : int
val sdl_event_screen_keyboard_hidden : int
val sdl_event_mouse_motion : int
val sdl_event_mouse_button_down : int
val sdl_event_mouse_button_up : int
val sdl_event_mouse_wheel : int
val sdl_event_mouse_added : int
val sdl_event_mouse_removed : int
val sdl_event_joystick_axis_motion : int
val sdl_event_joystick_ball_motion : int
val sdl_event_joystick_hat_motion : int
val sdl_event_joystick_button_down : int
val sdl_event_joystick_button_up : int
val sdl_event_joystick_added : int
val sdl_event_joystick_removed : int
val sdl_event_joystick_battery_updated : int
val sdl_event_joystick_update_complete : int
val sdl_event_gamepad_axis_motion : int
val sdl_event_gamepad_button_down : int
val sdl_event_gamepad_button_up : int
val sdl_event_gamepad_added : int
val sdl_event_gamepad_removed : int
val sdl_event_gamepad_remapped : int
val sdl_event_gamepad_touchpad_down : int
val sdl_event_gamepad_touchpad_motion : int
val sdl_event_gamepad_touchpad_up : int
val sdl_event_gamepad_sensor_update : int
val sdl_event_gamepad_update_complete : int
val sdl_event_gamepad_steam_handle_updated : int
val sdl_event_finger_down : int
val sdl_event_finger_up : int
val sdl_event_finger_motion : int
val sdl_event_finger_canceled : int
val sdl_event_pinch_begin : int
val sdl_event_pinch_update : int
val sdl_event_pinch_end : int
val sdl_event_clipboard_update : int
val sdl_event_drop_file : int
val sdl_event_drop_text : int
val sdl_event_drop_begin : int
val sdl_event_drop_complete : int
val sdl_event_drop_position : int
val sdl_event_audio_device_added : int
val sdl_event_audio_device_removed : int
val sdl_event_audio_device_format_changed : int
val sdl_event_sensor_update : int
val sdl_event_pen_proximity_in : int
val sdl_event_pen_proximity_out : int
val sdl_event_pen_down : int
val sdl_event_pen_up : int
val sdl_event_pen_button_down : int
val sdl_event_pen_button_up : int
val sdl_event_pen_motion : int
val sdl_event_pen_axis : int
val sdl_event_camera_device_added : int
val sdl_event_camera_device_removed : int
val sdl_event_camera_device_approved : int
val sdl_event_camera_device_denied : int
val sdl_event_render_targets_reset : int
val sdl_event_render_device_reset : int
val sdl_event_render_device_lost : int
val sdl_event_user : int
val sdl_event_last : int

(** Mouse wheel direction (SDL_MouseWheelDirection) *)
val sdl_mousewheel_normal : int
val sdl_mousewheel_flipped : int

(** {1 Audio}
    Default-device sentinels: 0xFFFFFFFF and 0xFFFFFFFE as int32. *)
val sdl_audio_device_default_playback : int32
val sdl_audio_device_default_recording : int32

val sdl_audio_unknown : int
val sdl_audio_u8 : int
val sdl_audio_s8 : int
val sdl_audio_s16le : int
val sdl_audio_s16be : int
val sdl_audio_s32le : int
val sdl_audio_s32be : int
val sdl_audio_f32le : int
val sdl_audio_f32be : int
val sdl_audio_s16 : int
val sdl_audio_s32 : int
val sdl_audio_f32 : int

(** {1 Pixel formats} (SDL_PixelFormat) *)
val sdl_pixelformat_unknown : int
val sdl_pixelformat_rgba8888 : int
val sdl_pixelformat_argb8888 : int
val sdl_pixelformat_rgb24 : int
val sdl_pixelformat_bgr24 : int
val sdl_pixelformat_rgb565 : int
val sdl_pixelformat_bgr565 : int

(** {1 Texture access} (SDL_TextureAccess) *)
val sdl_textureaccess_static : int
val sdl_textureaccess_streaming : int
val sdl_textureaccess_target : int

(** {1 Blend modes} (SDL_BlendMode) *)
val sdl_blendmode_none : int
val sdl_blendmode_blend : int
val sdl_blendmode_blend_premultiplied : int
val sdl_blendmode_add : int
val sdl_blendmode_add_premultiplied : int
val sdl_blendmode_mod : int
val sdl_blendmode_mul : int
val sdl_blendmode_invalid : int

(** {1 Scale modes} (SDL_ScaleMode) *)
val sdl_scalemode_invalid : int
val sdl_scalemode_nearest : int
val sdl_scalemode_linear : int
val sdl_scalemode_pixelart : int

(** {1 Flip modes} (SDL_FlipMode) *)
val sdl_flip_none : int
val sdl_flip_horizontal : int
val sdl_flip_vertical : int
val sdl_flip_horizontal_and_vertical : int

(** {1 Renderer names} *)
val sdl_software_renderer : string
val sdl_gpu_renderer : string
