(** SDL3 Mouse API. *)

type mouse_state = {
  x : float;
  y : float;
  buttons : int32;
}

val get_state : unit -> mouse_state
val get_relative_state : unit -> mouse_state

val show_cursor : unit -> bool
val hide_cursor : unit -> bool
val cursor_visible : unit -> bool
