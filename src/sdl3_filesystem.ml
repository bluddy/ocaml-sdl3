open Ctypes
open Foreign
open Sdl3_internal

let sdl_get_base_path = foreign "SDL_GetBasePath" (void @-> returning (ptr char))
let get_base_path () =
  consume_c_string (Some (sdl_get_base_path ()))

let sdl_get_pref_path = foreign "SDL_GetPrefPath" (string @-> string @-> returning (ptr char))
let get_pref_path ~org ~app =
  consume_c_string (Some (sdl_get_pref_path org app))
