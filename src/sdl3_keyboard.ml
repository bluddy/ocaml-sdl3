open Ctypes
open Foreign

let sdl_get_keyboard_state = foreign "SDL_GetKeyboardState" (ptr int @-> returning (ptr bool))
let get_keyboard_state () =
  let num_keys = allocate int 0 in
  let arr = sdl_get_keyboard_state num_keys in
  CArray.from_ptr arr (!@ num_keys)

let sdl_get_mod_state = foreign "SDL_GetModState" (void @-> returning uint16_t)
let get_mod_state () =
  Unsigned.UInt16.to_int (sdl_get_mod_state ())
