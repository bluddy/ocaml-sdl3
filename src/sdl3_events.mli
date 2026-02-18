(** SDL3 event queue. *)

type t = bytes

val poll_event : unit -> t option
(** [poll_event ()] returns the next event if available, [None] if the queue is empty. *)

val wait_event : unit -> t
(** [wait_event ()] blocks until an event is available. @raises Sdl_error on failure. *)

val get_type : t -> int
(** [get_type e] returns the event type (SDL_EventType). *)

val get_window_from_event : t -> Sdl3_video.window option
(** [get_window_from_event e] returns the window associated with the event, if any. *)

module Type : sig
  val quit : int
  val window_close_requested : int
end
