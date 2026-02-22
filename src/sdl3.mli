(** SDL3 OCaml bindings.

    [open Sdl3] to use the bindings. Most functions raise [Sdl3.Sdl_error] on
    SDL failure. SDL has main-thread requirements on some platforms; prefer
    init/quit and window ops on the main thread.
*)

exception Sdl_error of string

(** {1 Error handling} *)
val get_error : unit -> string
val clear_error : unit -> unit
val set_error : string -> unit

val set_main_ready : unit -> unit
(** Call before [init] when SDL is used from a non-main thread.
    Required on some platforms (e.g. bundled apps). *)

(** {1 Init} *)
module Init : sig
  type t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val test : t -> t -> bool
  val nothing : t
  val audio : t
  val video : t
  val joystick : t
  val haptic : t
  val gamepad : t
  val events : t
  val sensor : t
  val camera : t
end
val init : Init.t -> unit
val init_subsystem : Init.t -> unit
val quit : unit -> unit
val quit_subsystem : Init.t -> unit
val was_init : Init.t option -> Init.t
(** [was_init None] returns currently initialized flags.
    [was_init (Some mask)] returns flags matching [mask]. *)

(** {1 Hints} *)
module Hint : sig
  type t = string
  type priority = int
  val framebuffer_acceleration : t
  val audio_driver : t
  val video_driver : t
  val default : priority
  val normal : priority
  val override : priority
end
val reset_hints : unit -> unit
val get_hint : string -> string option
val get_hint_boolean : string -> bool -> bool
val set_hint : string -> string -> bool
val set_hint_with_priority : string -> string -> Hint.priority -> bool

(** {1 Log} *)
module Log : sig
  type category = int
  val category_application : category
  val category_error : category
  val category_system : category
  val category_audio : category
  val category_video : category
  val category_render : category
  val category_input : category
  val category_test : category

  type priority = int
  val priority_verbose : priority
  val priority_debug : priority
  val priority_info : priority
  val priority_warn : priority
  val priority_error : priority
  val priority_critical : priority
end
val log : string -> unit
val log_message : int -> int -> string -> unit
val log_get_priority : int -> int
val log_reset_priorities : unit -> unit
val log_set_all_priority : int -> unit
val log_set_priority : int -> int -> unit

(** {1 Version} *)
val get_version : unit -> int * int * int
val get_revision : unit -> string

(** {1 Video}

    [create_window] raises [Sdl_error] on failure. [destroy_window] invalidates
    the window; using it afterwards is undefined behaviour. *)
module Video : sig
  type rect = Sdl3_video.rect
  type display_id = Sdl3_video.display_id
  type window
  type window_flags = Sdl3_video.window_flags

  val get_displays : unit -> display_id list
  val get_display_name : display_id -> string option
  val get_display_bounds : display_id -> rect option

  module Rect : sig
    val x : rect -> int
    val y : rect -> int
    val w : rect -> int
    val h : rect -> int
  end

  module Window : sig
    val ( + ) : window_flags -> window_flags -> window_flags
    val none : window_flags
    val fullscreen : window_flags
    val opengl : window_flags
    val hidden : window_flags
    val borderless : window_flags
    val resizable : window_flags
    val vulkan : window_flags
    val metal : window_flags
  end

  val create_window : string -> int -> int -> window_flags -> window
  val destroy_window : window -> unit
  val get_window_id : window -> int32
  val get_window_from_id : int32 -> window option
  val get_window_display : window -> display_id
  val display_id_to_int32 : display_id -> int32
end

(** {1 Events} *)
module Event : module type of Sdl3_events

(** {1 Audio} *)
module Audio : module type of Sdl3_audio
