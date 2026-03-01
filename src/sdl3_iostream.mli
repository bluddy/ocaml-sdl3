(** SDL3 IOStream API. *)

type t
(** Opaque IO stream handle. *)

val from_file : string -> string -> t
(** [from_file path mode] opens a file. *)

val from_mem : (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t -> t
(** [from_mem ba] creates an IO stream from a Bigarray. The Bigarray must outlive the IO stream. *)

val close : t -> unit
(** [close io] closes the IO stream. *)

val read : t -> (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t -> int
(** [read io ba] reads into the Bigarray. Returns bytes read. *)

val write : t -> (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t -> int
(** [write io ba] writes from the Bigarray. Returns bytes written. *)

val get_size : t -> int64
val get_status : t -> int
