open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_internal

(** Opaque gamepad handle. *)
type t = Sdl3_internal.gamepad

(** Joystick instance ID (SDL_JoystickID = Uint32). Use for gamepad_added/removed events. *)
type instance_id = int32

let instance_id_of_uint32 = Unsigned.UInt32.to_int32
let instance_id_to_uint32 = Unsigned.UInt32.of_int32

type gamepad_button =
  | South
  | East
  | West
  | North
  | Back
  | Guide
  | Start
  | Left_stick
  | Right_stick
  | Left_shoulder
  | Right_shoulder
  | Dpad_up
  | Dpad_down
  | Dpad_left
  | Dpad_right
  | Misc1
  | Right_paddle1
  | Left_paddle1
  | Right_paddle2
  | Left_paddle2
  | Touchpad
  | Misc2
  | Misc3
  | Misc4
  | Misc5
  | Misc6
  | Invalid

let gamepad_button_to_int = function
  | South -> sdl_gamepad_button_south
  | East -> sdl_gamepad_button_east
  | West -> sdl_gamepad_button_west
  | North -> sdl_gamepad_button_north
  | Back -> sdl_gamepad_button_back
  | Guide -> sdl_gamepad_button_guide
  | Start -> sdl_gamepad_button_start
  | Left_stick -> sdl_gamepad_button_left_stick
  | Right_stick -> sdl_gamepad_button_right_stick
  | Left_shoulder -> sdl_gamepad_button_left_shoulder
  | Right_shoulder -> sdl_gamepad_button_right_shoulder
  | Dpad_up -> sdl_gamepad_button_dpad_up
  | Dpad_down -> sdl_gamepad_button_dpad_down
  | Dpad_left -> sdl_gamepad_button_dpad_left
  | Dpad_right -> sdl_gamepad_button_dpad_right
  | Misc1 -> sdl_gamepad_button_misc1
  | Right_paddle1 -> sdl_gamepad_button_right_paddle1
  | Left_paddle1 -> sdl_gamepad_button_left_paddle1
  | Right_paddle2 -> sdl_gamepad_button_right_paddle2
  | Left_paddle2 -> sdl_gamepad_button_left_paddle2
  | Touchpad -> sdl_gamepad_button_touchpad
  | Misc2 -> sdl_gamepad_button_misc2
  | Misc3 -> sdl_gamepad_button_misc3
  | Misc4 -> sdl_gamepad_button_misc4
  | Misc5 -> sdl_gamepad_button_misc5
  | Misc6 -> sdl_gamepad_button_misc6
  | Invalid -> sdl_gamepad_button_invalid

let gamepad_button_of_int = function
  | 0 -> South
  | 1 -> East
  | 2 -> West
  | 3 -> North
  | 4 -> Back
  | 5 -> Guide
  | 6 -> Start
  | 7 -> Left_stick
  | 8 -> Right_stick
  | 9 -> Left_shoulder
  | 10 -> Right_shoulder
  | 11 -> Dpad_up
  | 12 -> Dpad_down
  | 13 -> Dpad_left
  | 14 -> Dpad_right
  | 15 -> Misc1
  | 16 -> Right_paddle1
  | 17 -> Left_paddle1
  | 18 -> Right_paddle2
  | 19 -> Left_paddle2
  | 20 -> Touchpad
  | 21 -> Misc2
  | 22 -> Misc3
  | 23 -> Misc4
  | 24 -> Misc5
  | 25 -> Misc6
  | _ -> Invalid

type gamepad_axis =
  | Left_x
  | Left_y
  | Right_x
  | Right_y
  | Left_trigger
  | Right_trigger
  | Invalid_axis

let gamepad_axis_to_int = function
  | Left_x -> sdl_gamepad_axis_left_x
  | Left_y -> sdl_gamepad_axis_left_y
  | Right_x -> sdl_gamepad_axis_right_x
  | Right_y -> sdl_gamepad_axis_right_y
  | Left_trigger -> sdl_gamepad_axis_left_trigger
  | Right_trigger -> sdl_gamepad_axis_right_trigger
  | Invalid_axis -> sdl_gamepad_axis_invalid

let gamepad_axis_of_int = function
  | 0 -> Left_x
  | 1 -> Left_y
  | 2 -> Right_x
  | 3 -> Right_y
  | 4 -> Left_trigger
  | 5 -> Right_trigger
  | _ -> Invalid_axis

type gamepad_type =
  | Unknown
  | Standard
  | Xbox360
  | XboxOne
  | PS3
  | PS4
  | PS5
  | Nintendo_switch_pro
  | Nintendo_switch_joycon_left
  | Nintendo_switch_joycon_right
  | Nintendo_switch_joycon_pair
  | Gamecube
  | Unknown_type of int

let gamepad_type_to_int [@warning "-32"] = function
  | Unknown -> sdl_gamepad_type_unknown
  | Standard -> sdl_gamepad_type_standard
  | Xbox360 -> sdl_gamepad_type_xbox360
  | XboxOne -> sdl_gamepad_type_xboxone
  | PS3 -> sdl_gamepad_type_ps3
  | PS4 -> sdl_gamepad_type_ps4
  | PS5 -> sdl_gamepad_type_ps5
  | Nintendo_switch_pro -> sdl_gamepad_type_nintendo_switch_pro
  | Nintendo_switch_joycon_left -> sdl_gamepad_type_nintendo_switch_joycon_left
  | Nintendo_switch_joycon_right -> sdl_gamepad_type_nintendo_switch_joycon_right
  | Nintendo_switch_joycon_pair -> sdl_gamepad_type_nintendo_switch_joycon_pair
  | Gamecube -> sdl_gamepad_type_gamecube
  | Unknown_type i -> i

let gamepad_type_of_int = function
  | 0 -> Unknown
  | 1 -> Standard
  | 2 -> Xbox360
  | 3 -> XboxOne
  | 4 -> PS3
  | 5 -> PS4
  | 6 -> PS5
  | 7 -> Nintendo_switch_pro
  | 8 -> Nintendo_switch_joycon_left
  | 9 -> Nintendo_switch_joycon_right
  | 10 -> Nintendo_switch_joycon_pair
  | 11 -> Gamecube
  | i -> Unknown_type i

let sdl_get_gamepads = foreign "SDL_GetGamepads" (ptr int @-> returning (ptr uint32_t))

let get_gamepads () =
  let count = allocate int 0 in
  let arr = sdl_get_gamepads count in
  if is_null arr then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let n = !@ count in
  let ids =
    List.init n (fun i ->
      instance_id_of_uint32 (CArray.get (CArray.from_ptr arr n) i))
  in
  sdl_free (to_voidp arr);
  ids

let sdl_is_gamepad = foreign "SDL_IsGamepad" (uint32_t @-> returning bool)

let is_gamepad id =
  sdl_is_gamepad (instance_id_to_uint32 id)

let sdl_open_gamepad = foreign "SDL_OpenGamepad" (uint32_t @-> returning (ptr gamepad_tag))

let sdl_close_gamepad = foreign "SDL_CloseGamepad" (ptr gamepad_tag @-> returning void)

let close = sdl_close_gamepad

let open_gamepad id =
  let p = sdl_open_gamepad (instance_id_to_uint32 id) in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Gc.finalise close p;
  p

let sdl_get_gamepad_button =
  foreign "SDL_GetGamepadButton" (ptr gamepad_tag @-> int @-> returning bool)

let get_button gamepad button =
  sdl_get_gamepad_button gamepad (gamepad_button_to_int button)

let sdl_get_gamepad_axis =
  foreign "SDL_GetGamepadAxis" (ptr gamepad_tag @-> int @-> returning int)

let get_axis gamepad axis =
  sdl_get_gamepad_axis gamepad (gamepad_axis_to_int axis)

let sdl_gamepad_connected = foreign "SDL_GamepadConnected" (ptr gamepad_tag @-> returning bool)

let connected = sdl_gamepad_connected

let sdl_get_gamepad_from_id = foreign "SDL_GetGamepadFromID" (uint32_t @-> returning (ptr gamepad_tag))

let get_from_instance_id id =
  let p = sdl_get_gamepad_from_id (instance_id_to_uint32 id) in
  if is_null p then None else Some p

let sdl_get_gamepad_id = foreign "SDL_GetGamepadID" (ptr gamepad_tag @-> returning uint32_t)

let get_instance_id gamepad =
  instance_id_of_uint32 (sdl_get_gamepad_id gamepad)

let sdl_get_gamepad_name = foreign "SDL_GetGamepadName" (ptr gamepad_tag @-> returning string_opt)

let get_name gamepad =
  sdl_get_gamepad_name gamepad

let sdl_get_gamepad_path = foreign "SDL_GetGamepadPath" (ptr gamepad_tag @-> returning string_opt)

let get_path gamepad =
  sdl_get_gamepad_path gamepad

let sdl_get_gamepad_type =
  foreign "SDL_GetGamepadType" (ptr gamepad_tag @-> returning int)

let get_type gamepad =
  gamepad_type_of_int (sdl_get_gamepad_type gamepad)

let sdl_gamepad_has_button =
  foreign "SDL_GamepadHasButton" (ptr gamepad_tag @-> int @-> returning bool)

let has_button gamepad button =
  sdl_gamepad_has_button gamepad (gamepad_button_to_int button)

let sdl_gamepad_has_axis =
  foreign "SDL_GamepadHasAxis" (ptr gamepad_tag @-> int @-> returning bool)

let has_axis gamepad axis =
  sdl_gamepad_has_axis gamepad (gamepad_axis_to_int axis)

let sdl_get_gamepad_player_index =
  foreign "SDL_GetGamepadPlayerIndex" (ptr gamepad_tag @-> returning int)

let get_player_index gamepad =
  sdl_get_gamepad_player_index gamepad

let sdl_set_gamepad_player_index =
  foreign "SDL_SetGamepadPlayerIndex" (ptr gamepad_tag @-> int @-> returning void)

let set_player_index gamepad index =
  sdl_set_gamepad_player_index gamepad index

let sdl_get_gamepad_from_player_index =
  foreign "SDL_GetGamepadFromPlayerIndex" (int @-> returning (ptr gamepad_tag))

let get_from_player_index index =
  let p = sdl_get_gamepad_from_player_index index in
  if is_null p then None else Some p

(* Phase 6.4: Rumble, LED, Mappings *)

let rumble_intensity f =
  (* Clamp float 0.0-1.0 to Uint16 0-0xFFFF *)
  let v = int_of_float (f *. 65535.0) in
  min 65535 (max 0 v)
  |> Unsigned.UInt16.of_int

let sdl_rumble_gamepad =
  foreign "SDL_RumbleGamepad"
    (ptr gamepad_tag @-> uint16_t @-> uint16_t @-> uint32_t @-> returning bool)

let rumble gamepad ~low ~high ~duration_ms =
  let low_u = rumble_intensity low and high_u = rumble_intensity high in
  let duration = Unsigned.UInt32.of_int duration_ms in
  if not (sdl_rumble_gamepad gamepad low_u high_u duration) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_rumble_gamepad_triggers =
  foreign "SDL_RumbleGamepadTriggers"
    (ptr gamepad_tag @-> uint16_t @-> uint16_t @-> uint32_t @-> returning bool)

let rumble_triggers gamepad ~left ~right ~duration_ms =
  let left_u = rumble_intensity left and right_u = rumble_intensity right in
  let duration = Unsigned.UInt32.of_int duration_ms in
  if not (sdl_rumble_gamepad_triggers gamepad left_u right_u duration) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_set_gamepad_led =
  foreign "SDL_SetGamepadLED"
    (ptr gamepad_tag @-> uint8_t @-> uint8_t @-> uint8_t @-> returning bool)

let set_led gamepad ~r ~g ~b =
  let r' = Unsigned.UInt8.of_int (min 255 (max 0 r))
  and g' = Unsigned.UInt8.of_int (min 255 (max 0 g))
  and b' = Unsigned.UInt8.of_int (min 255 (max 0 b)) in
  if not (sdl_set_gamepad_led gamepad r' g' b') then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_add_gamepad_mapping =
  foreign "SDL_AddGamepadMapping" (string @-> returning int)

let add_mapping mapping =
  let r = sdl_add_gamepad_mapping mapping in
  if r < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r = 1

let sdl_add_gamepad_mappings_from_file =
  foreign "SDL_AddGamepadMappingsFromFile" (string @-> returning int)

let add_mappings_from_file path =
  let r = sdl_add_gamepad_mappings_from_file path in
  if r < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

let sdl_get_gamepad_mapping =
  foreign "SDL_GetGamepadMapping" (ptr gamepad_tag @-> returning (ptr char))

let get_mapping gamepad =
  consume_c_string (Some (sdl_get_gamepad_mapping gamepad))
