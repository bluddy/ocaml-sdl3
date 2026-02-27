open Ctypes

type window_tag
val window_tag : window_tag structure typ
type window = window_tag structure ptr
val window : window typ

type renderer_tag
val renderer_tag : renderer_tag structure typ
type renderer = renderer_tag structure ptr
val renderer : renderer typ

type texture_tag
val texture_tag : texture_tag structure typ
type texture = texture_tag structure ptr
val texture : texture typ

type surface_tag
val surface_tag : surface_tag structure typ
type surface_ptr = surface_tag structure ptr
val surface_ptr : surface_ptr typ

type stream_tag
val stream_tag : stream_tag structure typ
type stream = stream_tag structure ptr
val stream : stream typ

type gamepad_tag
val gamepad_tag : gamepad_tag structure typ
type gamepad = gamepad_tag structure ptr
val gamepad : gamepad typ

val sdl3_ptr_addr : unit ptr -> int64

external sdl3_bigarray_of_ptr :
  nativeint ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  = "sdl3_bigarray_of_ptr"

val sdl_free : unit ptr -> unit

val consume_c_string : char ptr option -> string option
