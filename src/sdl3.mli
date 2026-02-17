(** SDL3 OCaml bindings.

    Open [Sdl] to use the bindings. Functions raise [Sdl.Sdl_error] on failure.
*)

module Sdl : sig
  exception Sdl_error of string

  (** {1 Error handling} *)
  val get_error : unit -> string
  val clear_error : unit -> unit
  val set_error : string -> unit

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
end
