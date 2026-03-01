open Foreign
open Ctypes
open Sdl3_internal

type flags =
  | Error
  | Warning
  | Information

let flags_to_int = function
  | Error -> 0x00000010
  | Warning -> 0x00000020
  | Information -> 0x00000040

let sdl_show_simple_message_box =
  foreign "SDL_ShowSimpleMessageBox"
    (uint32_t @-> string @-> string @-> ptr window_tag @-> returning bool)

let show_simple ?window ~flags ~title ~message () =
  let w = match window with None -> coerce (ptr void) (ptr window_tag) null | Some w -> w in
  if not (sdl_show_simple_message_box (Unsigned.UInt32.of_int (flags_to_int flags)) title message w) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))
