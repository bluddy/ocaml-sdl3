(** SDL3 Gamepad API. Call [Sdl3.init] with [Init.gamepad] before use. *)

type t = Sdl3_internal.gamepad
(** Opaque gamepad handle. *)

type instance_id = int32
(** Joystick instance ID. Used in Gamepad_added/removed events. *)

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

val gamepad_button_of_int : int -> gamepad_button

type gamepad_axis =
  | Left_x
  | Left_y
  | Right_x
  | Right_y
  | Left_trigger
  | Right_trigger
  | Invalid_axis

val gamepad_axis_of_int : int -> gamepad_axis

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

val gamepad_type_of_int : int -> gamepad_type
val gamepad_type_to_int : gamepad_type -> int

val get_gamepads : unit -> instance_id list
(** [get_gamepads ()] returns connected gamepad instance IDs. *)

val is_gamepad : instance_id -> bool
(** [is_gamepad id] returns true if the joystick at [id] is a supported gamepad. *)

val open_gamepad : instance_id -> t
(** [open_gamepad id] opens a gamepad. Raises [Sdl_error] on failure. *)

val close : t -> unit

val get_button : t -> gamepad_button -> bool
(** [get_button g b] returns true if button [b] is pressed. *)

val get_axis : t -> gamepad_axis -> int
(** [get_axis g a] returns axis value in [-32768, 32767]. *)

val connected : t -> bool
(** [connected g] returns true if the gamepad is still connected. *)

val get_from_instance_id : instance_id -> t option
(** [get_from_instance_id id] returns the gamepad for [id] if open, None otherwise. *)

val get_instance_id : t -> instance_id

val get_name : t -> string option
val get_path : t -> string option
val get_type : t -> gamepad_type
val has_button : t -> gamepad_button -> bool
val has_axis : t -> gamepad_axis -> bool
val get_player_index : t -> int
val set_player_index : t -> int -> unit
val get_from_player_index : int -> t option

(** Rumble, LED, mappings. *)

val rumble : t -> low:float -> high:float -> duration_ms:int -> unit
(** [rumble g ~low ~high ~duration_ms] starts main motors rumble.
    [low] and [high] are 0.0-1.0. Raises [Sdl_error] if not supported. *)

val rumble_triggers : t -> left:float -> right:float -> duration_ms:int -> unit
(** [rumble_triggers g ~left ~right ~duration_ms] rumbles trigger motors
    (Xbox One style). Raises [Sdl_error] if not supported. *)

val set_led : t -> r:int -> g:int -> b:int -> unit
(** [set_led g ~r ~g ~b] sets RGB LED (0-255 each). Raises [Sdl_error] if not supported. *)

val add_mapping : string -> bool
(** [add_mapping s] adds or updates a gamepad mapping. Returns [true] if new, [false] if updated.
    Raises [Sdl_error] on failure. *)

val add_mappings_from_file : string -> int
(** [add_mappings_from_file path] loads mappings from file. Returns number added.
    Raises [Sdl_error] on failure. *)

val get_mapping : t -> string option
(** [get_mapping g] returns the current mapping string, or [None] if unavailable. *)
