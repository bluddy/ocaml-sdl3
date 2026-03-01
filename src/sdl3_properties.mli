(** SDL3 Properties API. *)

type t = int32
(** A collection of named properties. *)

val create : unit -> t
(** [create ()] creates a new collection of properties. *)

val destroy : t -> unit
(** [destroy id] destroys a collection of properties. *)

val set_string : t -> string -> string -> unit
val get_string : t -> string -> ?default:string -> unit -> string option

val set_number : t -> string -> int64 -> unit
val get_number : t -> string -> ?default:int64 -> unit -> int64

val set_boolean : t -> string -> bool -> unit
val get_boolean : t -> string -> ?default:bool -> unit -> bool

val set_pointer : t -> string -> unit Ctypes.ptr -> unit
val get_pointer : t -> string -> ?default:unit Ctypes.ptr -> unit -> unit Ctypes.ptr

val clear : t -> string -> unit
