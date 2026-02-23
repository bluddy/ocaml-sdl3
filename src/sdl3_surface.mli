(** SDL surfaces: system-RAM pixel buffers. *)

type surface

val create_surface : int -> int -> int -> surface
(** [create_surface w h format] allocates a new surface. Pixels are zeroed.
    [format] is e.g. [Sdl3_consts.sdl_pixelformat_rgba8888]. *)

val create_surface_from :
  int ->
  int ->
  int ->
  (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t option ->
  int ->
  surface
(** [create_surface_from w h format pixels pitch] wraps existing pixel data.
    No copy is made; surface must be destroyed before freeing [pixels].
    [pixels = None] with [pitch = 0] creates a surface to fill in later. *)

val destroy_surface : surface -> unit
(** Frees the surface. Safe to pass an already-destroyed surface (no-op). *)

val load_bmp : string -> surface
(** Loads a BMP file. Raises [Sdl_error] on failure. *)

val lock_surface : surface -> unit
(** Locks the surface for pixel access. Required before reading/writing
    [Surface.pixels]. Raises on failure. *)

val unlock_surface : surface -> unit
(** Unlocks the surface. *)

(** Surface field accessors. [pixels] is valid only while locked. *)
module Surface : sig
  val w : surface -> int
  val h : surface -> int
  val pitch : surface -> int
  val format : surface -> int
  val pixels : surface -> unit Ctypes.ptr
end
