(** Error handling used by core and video modules. *)

open Ctypes
open Foreign

exception Sdl_error of string

let get_error = foreign "SDL_GetError" (void @-> returning string)
let clear_error = foreign "SDL_ClearError" (void @-> returning void)

external set_error_stub : string -> unit = "sdl3_set_error_stub"
let set_error msg = set_error_stub msg
