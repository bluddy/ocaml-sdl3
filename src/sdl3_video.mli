(** SDL3 video: displays and windows. *)

(** {1 Rect} *)
type rect = { x : int; y : int; w : int; h : int }

(** {1 Display} *)
type display_id

val display_id_to_int32 : display_id -> int32
(** For interop; 0 is invalid. *)

val get_displays : unit -> display_id list
(** [get_displays ()] returns the list of connected display IDs. *)

val get_display_name : display_id -> string option
(** [get_display_name id] returns the display name, or None on error. *)

val get_display_bounds : display_id -> rect option
(** [get_display_bounds id] returns the display bounds, or None on error. *)

(** {1 Window} *)
type window

val window_of_ptr : unit Ctypes.ptr -> window
(** Internal: construct window from raw pointer. *)

type window_flags

module Window : sig
  val none : window_flags
  val fullscreen : window_flags
  val opengl : window_flags
  val hidden : window_flags
  val borderless : window_flags
  val resizable : window_flags
  val vulkan : window_flags
  val metal : window_flags
  val ( + ) : window_flags -> window_flags -> window_flags
end

val create_window : string -> int -> int -> window_flags -> window
(** [create_window title w h flags] creates a window. Raises [Sdl_error] on failure. *)

val destroy_window : window -> unit

val get_window_id : window -> int32
(** [get_window_id w] returns the unique ID of the window. *)

val get_window_from_id : int32 -> window option
(** [get_window_from_id id] returns the window with the given ID. *)

val get_window_display : window -> display_id
(** [get_window_display w] returns the display the window is on. Returns 0 on error. *)
