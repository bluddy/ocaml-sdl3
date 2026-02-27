open Ctypes

type window_tag
let window_tag : window_tag structure typ = structure "SDL_Window"
type window = window_tag structure ptr
let window : window typ = ptr window_tag

type renderer_tag
let renderer_tag : renderer_tag structure typ = structure "SDL_Renderer"
type renderer = renderer_tag structure ptr
let renderer : renderer typ = ptr renderer_tag

type texture_tag
let texture_tag : texture_tag structure typ = structure "SDL_Texture"
type texture = texture_tag structure ptr
let texture : texture typ = ptr texture_tag

type surface_tag
let surface_tag : surface_tag structure typ = structure "SDL_Surface"
type surface_ptr = surface_tag structure ptr
let surface_ptr : surface_ptr typ = ptr surface_tag

type stream_tag
let stream_tag : stream_tag structure typ = structure "SDL_AudioStream"
type stream = stream_tag structure ptr
let stream : stream typ = ptr stream_tag

type gamepad_tag
let gamepad_tag : gamepad_tag structure typ = structure "SDL_Gamepad"
type gamepad = gamepad_tag structure ptr
let gamepad : gamepad typ = ptr gamepad_tag

let sdl3_ptr_addr = Foreign.foreign "sdl3_ptr_addr" (ptr void @-> returning int64_t)

external sdl3_bigarray_of_ptr :
  nativeint ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  = "sdl3_bigarray_of_ptr"

let sdl_free = Foreign.foreign "SDL_free" (ptr void @-> returning void)

let consume_c_string p_opt =
  match p_opt with
  | None -> None
  | Some p ->
      let s = coerce (ptr char) string p in
      sdl_free (to_voidp p);
      Some s
