(** SDL3 Keyboard API. *)

val get_keyboard_state : unit -> bool Ctypes.CArray.t
(** [get_keyboard_state ()] returns a snapshot of the current keyboard state. *)

val get_mod_state : unit -> int
(** [get_mod_state ()] returns the current modifier state. *)
