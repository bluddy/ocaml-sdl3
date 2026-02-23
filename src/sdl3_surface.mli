(** SDL surfaces: system-RAM pixel buffers. *)

type surface

module Pixel_format : sig
  val rgba8888 : int
  val rgb24 : int
  val rgb565 : int
end

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

val with_locked_surface :
  surface -> ((int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t * int -> unit) -> unit
(** [with_locked_surface s f] locks the surface, calls [f (pixels, pitch)],
    then unlocks. [pixels] is a 1D byte Bigarray of size [pitch * height],
    valid only during the callback. *)

(** Surface field accessors. *)
module Surface : sig
  val w : surface -> int
  val h : surface -> int
  val pitch : surface -> int
  val format : surface -> int
end
