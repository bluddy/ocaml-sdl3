open Ctypes
open Foreign

type t = int32

let sdl_create_properties = foreign "SDL_CreateProperties" (void @-> returning uint32_t)
let create () =
  let id = sdl_create_properties () in
  if Unsigned.UInt32.to_int32 id = 0l then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Unsigned.UInt32.to_int32 id

let sdl_destroy_properties = foreign "SDL_DestroyProperties" (uint32_t @-> returning void)
let destroy id = sdl_destroy_properties (Unsigned.UInt32.of_int32 id)

let sdl_set_string_property = foreign "SDL_SetStringProperty" (uint32_t @-> string @-> string @-> returning bool)
let set_string id name value =
  if not (sdl_set_string_property (Unsigned.UInt32.of_int32 id) name value) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_string_property = foreign "SDL_GetStringProperty" (uint32_t @-> string @-> string_opt @-> returning string_opt)
let get_string id name ?default () =
  sdl_get_string_property (Unsigned.UInt32.of_int32 id) name default

let sdl_set_number_property = foreign "SDL_SetNumberProperty" (uint32_t @-> string @-> int64_t @-> returning bool)
let set_number id name value =
  if not (sdl_set_number_property (Unsigned.UInt32.of_int32 id) name value) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_number_property = foreign "SDL_GetNumberProperty" (uint32_t @-> string @-> int64_t @-> returning int64_t)
let get_number id name ?(default=0L) () =
  sdl_get_number_property (Unsigned.UInt32.of_int32 id) name default

let sdl_set_boolean_property = foreign "SDL_SetBooleanProperty" (uint32_t @-> string @-> bool @-> returning bool)
let set_boolean id name value =
  if not (sdl_set_boolean_property (Unsigned.UInt32.of_int32 id) name value) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_boolean_property = foreign "SDL_GetBooleanProperty" (uint32_t @-> string @-> bool @-> returning bool)
let get_boolean id name ?(default=false) () =
  sdl_get_boolean_property (Unsigned.UInt32.of_int32 id) name default

let sdl_set_pointer_property = foreign "SDL_SetPointerProperty" (uint32_t @-> string @-> ptr void @-> returning bool)
let set_pointer id name value =
  if not (sdl_set_pointer_property (Unsigned.UInt32.of_int32 id) name value) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_pointer_property = foreign "SDL_GetPointerProperty" (uint32_t @-> string @-> ptr void @-> returning (ptr void))
let get_pointer id name ?(default=null) () =
  sdl_get_pointer_property (Unsigned.UInt32.of_int32 id) name default

let sdl_clear_property = foreign "SDL_ClearProperty" (uint32_t @-> string @-> returning bool)
let clear id name =
  if not (sdl_clear_property (Unsigned.UInt32.of_int32 id) name) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))
