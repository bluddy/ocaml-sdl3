open Ctypes
open Foreign
open Sdl3_consts

(** Opaque window pointer *)
type window = unit ptr

type rect = { x : int; y : int; w : int; h : int }
type display_id = int32

let display_id_to_int32 id = id

let rect = structure "SDL_Rect"
let rect_x = field rect "x" int
let rect_y = field rect "y" int
let rect_w = field rect "w" int
let rect_h = field rect "h" int
let () = seal rect

let sdl_free = foreign "SDL_free" (ptr void @-> returning void)

let sdl_get_displays = foreign "SDL_GetDisplays" (ptr int @-> returning (ptr uint32_t))
let get_displays () =
  let count = allocate int 0 in
  let arr = sdl_get_displays count in
  if is_null arr then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let n = !@ count in
  let ids =
    List.init n (fun i ->
      Unsigned.UInt32.to_int32 (CArray.get (CArray.from_ptr arr n) i))
  in
  sdl_free (to_voidp arr);
  ids

let sdl_get_display_name = foreign "SDL_GetDisplayName" (uint32_t @-> returning string_opt)
let get_display_name id =
  sdl_get_display_name (Unsigned.UInt32.of_int32 id)

let sdl_get_display_bounds =
  foreign "SDL_GetDisplayBounds" (uint32_t @-> ptr rect @-> returning bool)
let get_display_bounds id =
  let r = make rect in
  if sdl_get_display_bounds (Unsigned.UInt32.of_int32 id) (addr r) then
    Some { x = getf r rect_x; y = getf r rect_y; w = getf r rect_w; h = getf r rect_h }
  else
    None

type window_flags = int64

module Window = struct
  let ( + ) = Int64.logor
  let none = 0L
  let fullscreen = sdl_window_fullscreen
  let opengl = sdl_window_opengl
  let hidden = sdl_window_hidden
  let borderless = sdl_window_borderless
  let resizable = sdl_window_resizable
  let vulkan = sdl_window_vulkan
  let metal = sdl_window_metal
end

let sdl_create_window =
  foreign "SDL_CreateWindow" (string @-> int @-> int @-> uint64_t @-> returning (ptr void))

let create_window title w h flags =
  let wptr = sdl_create_window title w h (Unsigned.UInt64.of_int64 flags) in
  if is_null wptr then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  wptr

let destroy_window =
  foreign "SDL_DestroyWindow" (ptr void @-> returning void)

let sdl_get_window_id = foreign "SDL_GetWindowID" (ptr void @-> returning uint32_t)
let get_window_id w =
  Unsigned.UInt32.to_int32 (sdl_get_window_id w)

let sdl_get_window_from_id =
  foreign "SDL_GetWindowFromID" (uint32_t @-> returning (ptr void))
let get_window_from_id id =
  let w = sdl_get_window_from_id (Unsigned.UInt32.of_int32 id) in
  if is_null w then None else Some w

let sdl_get_window_display = foreign "SDL_GetDisplayForWindow" (ptr void @-> returning uint32_t)
let get_window_display w =
  Unsigned.UInt32.to_int32 (sdl_get_window_display w)
