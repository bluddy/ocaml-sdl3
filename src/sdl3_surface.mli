(** SDL surfaces: system-RAM pixel buffers. Freed automatically when no longer referenced. *)

type surface

module Pixel_format : sig
  val rgba8888 : int
  val rgb24 : int
  val rgb565 : int
end

val create_surface : width:int -> height:int -> format:int -> surface
(** [create_surface ~width ~height ~format] allocates a new surface. Pixels are zeroed.
    [format] is e.g. [Sdl3_consts.sdl_pixelformat_rgba8888]. *)

val create_surface_from :
  width:int ->
  height:int ->
  format:int ->
  pixels:(char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t option ->
  pitch:int ->
  surface
(** [create_surface_from w h format pixels pitch] wraps existing pixel data.
    No copy is made; [pixels] must outlive the surface. Surfaces are freed
    automatically when no longer referenced.
    [pixels = None] with [pitch = 0] creates a surface to fill in later. *)

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

(** {1 Internal} *)

val to_ptr_: surface -> unit Ctypes.ptr
val of_ptr_: unit Ctypes.ptr -> surface
val adopt_ptr_: unit Ctypes.ptr -> surface
