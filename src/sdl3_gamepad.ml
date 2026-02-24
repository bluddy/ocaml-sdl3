open Ctypes
open Foreign
open Sdl3_consts

(** Opaque gamepad handle. *)
type t = unit ptr

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

let sdl_free = foreign "SDL_free" (ptr void @-> returning void)

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

let sdl_open_gamepad = foreign "SDL_OpenGamepad" (uint32_t @-> returning (ptr void))

let open_gamepad id =
  let p = sdl_open_gamepad (instance_id_to_uint32 id) in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let sdl_close_gamepad = foreign "SDL_CloseGamepad" (ptr void @-> returning void)

let close = sdl_close_gamepad

let sdl_get_gamepad_button =
  foreign "SDL_GetGamepadButton" (ptr void @-> int @-> returning bool)

let get_button gamepad button =
  sdl_get_gamepad_button gamepad (gamepad_button_to_int button)

let sdl_get_gamepad_axis =
  foreign "SDL_GetGamepadAxis" (ptr void @-> int @-> returning int)

let get_axis gamepad axis =
  sdl_get_gamepad_axis gamepad (gamepad_axis_to_int axis)

let sdl_gamepad_connected = foreign "SDL_GamepadConnected" (ptr void @-> returning bool)

let connected = sdl_gamepad_connected

let sdl_get_gamepad_from_id = foreign "SDL_GetGamepadFromID" (uint32_t @-> returning (ptr void))

let get_from_instance_id id =
  let p = sdl_get_gamepad_from_id (instance_id_to_uint32 id) in
  if is_null p then None else Some p

let sdl_get_gamepad_id = foreign "SDL_GetGamepadID" (ptr void @-> returning uint32_t)

let get_instance_id gamepad =
  instance_id_of_uint32 (sdl_get_gamepad_id gamepad)

let sdl_get_gamepad_name = foreign "SDL_GetGamepadName" (ptr void @-> returning string_opt)

let get_name gamepad =
  sdl_get_gamepad_name gamepad

let sdl_get_gamepad_path = foreign "SDL_GetGamepadPath" (ptr void @-> returning string_opt)

let get_path gamepad =
  sdl_get_gamepad_path gamepad

let sdl_get_gamepad_type =
  foreign "SDL_GetGamepadType" (ptr void @-> returning int)

let get_type gamepad =
  gamepad_type_of_int (sdl_get_gamepad_type gamepad)

let sdl_gamepad_has_button =
  foreign "SDL_GamepadHasButton" (ptr void @-> int @-> returning bool)

let has_button gamepad button =
  sdl_gamepad_has_button gamepad (gamepad_button_to_int button)

let sdl_gamepad_has_axis =
  foreign "SDL_GamepadHasAxis" (ptr void @-> int @-> returning bool)

let has_axis gamepad axis =
  sdl_gamepad_has_axis gamepad (gamepad_axis_to_int axis)

let sdl_get_gamepad_player_index =
  foreign "SDL_GetGamepadPlayerIndex" (ptr void @-> returning int)

let get_player_index gamepad =
  sdl_get_gamepad_player_index gamepad

let sdl_set_gamepad_player_index =
  foreign "SDL_SetGamepadPlayerIndex" (ptr void @-> int @-> returning void)

let set_player_index gamepad index =
  sdl_set_gamepad_player_index gamepad index

let sdl_get_gamepad_from_player_index =
  foreign "SDL_GetGamepadFromPlayerIndex" (int @-> returning (ptr void))

let get_from_player_index index =
  let p = sdl_get_gamepad_from_player_index index in
  if is_null p then None else Some p
