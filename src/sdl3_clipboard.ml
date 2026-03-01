open Foreign
open Ctypes
open Sdl3_internal

let sdl_set_clipboard_text = foreign "SDL_SetClipboardText" (string @-> returning bool)
let set_text text =
  if not (sdl_set_clipboard_text text) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_clipboard_text = foreign "SDL_GetClipboardText" (void @-> returning (ptr char))
let get_text () =
  consume_c_string (Some (sdl_get_clipboard_text ()))

let sdl_has_clipboard_text = foreign "SDL_HasClipboardText" (void @-> returning bool)
let has_text = sdl_has_clipboard_text
