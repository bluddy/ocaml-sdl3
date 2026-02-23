(** Internal helpers for surface pointer handling. Not part of the public API. *)

open Ctypes
open Foreign

type surface = unit ptr

let sdl_destroy_surface = foreign "SDL_DestroySurface" (ptr void @-> returning void)

let adopt s = Gc.finalise sdl_destroy_surface s

let of_ptr p = (p : surface)
let to_ptr s = (s : unit ptr)
