open Ctypes
open Foreign

type mouse_state = {
  x : float;
  y : float;
  buttons : int32;
}

let sdl_get_mouse_state = foreign "SDL_GetMouseState" (ptr float @-> ptr float @-> returning uint32_t)
let get_state () =
  let x = allocate float 0.0 in
  let y = allocate float 0.0 in
  let b = sdl_get_mouse_state x y in
  { x = !@ x; y = !@ y; buttons = Unsigned.UInt32.to_int32 b }

let sdl_get_relative_mouse_state = foreign "SDL_GetRelativeMouseState" (ptr float @-> ptr float @-> returning uint32_t)
let get_relative_state () =
  let x = allocate float 0.0 in
  let y = allocate float 0.0 in
  let b = sdl_get_relative_mouse_state x y in
  { x = !@ x; y = !@ y; buttons = Unsigned.UInt32.to_int32 b }

let sdl_show_cursor = foreign "SDL_ShowCursor" (void @-> returning bool)
let show_cursor = sdl_show_cursor

let sdl_hide_cursor = foreign "SDL_HideCursor" (void @-> returning bool)
let hide_cursor = sdl_hide_cursor

let sdl_cursor_visible = foreign "SDL_CursorVisible" (void @-> returning bool)
let cursor_visible = sdl_cursor_visible
