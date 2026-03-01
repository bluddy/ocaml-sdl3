(** SDL3 Clipboard API. *)

val set_text : string -> unit
(** [set_text s] sets the clipboard text. *)

val get_text : unit -> string option
(** [get_text ()] gets the clipboard text. *)

val has_text : unit -> bool
(** [has_text ()] returns true if the clipboard has text. *)
