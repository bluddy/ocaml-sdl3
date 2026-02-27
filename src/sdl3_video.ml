open Ctypes
open Foreign
open Sdl3_internal
open Sdl3_consts

(** Opaque window pointer *)
type window = Sdl3_internal.window

let window_of_ptr (p : unit ptr) : window = coerce (ptr void) (ptr window_tag) p

type display_id = int32

let display_id_to_int32 id = id

type rect_tag
let sdl_rect : rect_tag structure typ = structure "SDL_Rect"
type rect = rect_tag structure
let _rect_x = field sdl_rect "x" int
let _rect_y = field sdl_rect "y" int
let _rect_w = field sdl_rect "w" int
let _rect_h = field sdl_rect "h" int
let () = seal sdl_rect

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
  foreign "SDL_GetDisplayBounds" (uint32_t @-> ptr sdl_rect @-> returning bool)

let get_display_bounds id =
  let r = make sdl_rect in
  if sdl_get_display_bounds (Unsigned.UInt32.of_int32 id) (addr r) then
    Some r
  else
    None

(** Allocate a rect for use as C out-parameter. Contents are uninitialized. *)
let rect_alloc () = make sdl_rect

module Rect = struct
  let x r = getf r _rect_x
  let y r = getf r _rect_y
  let w r = getf r _rect_w
  let h r = getf r _rect_h

  let make ~x ~y ~w ~h =
    let r = make sdl_rect in
    setf r _rect_x x;
    setf r _rect_y y;
    setf r _rect_w w;
    setf r _rect_h h;
    r
end

type window_flag =
  | Fullscreen
  | Opengl
  | Hidden
  | Borderless
  | Resizable
  | Minimized
  | Maximized
  | Vulkan
  | Metal

let window_flag_to_int64 = function
  | Fullscreen -> sdl_window_fullscreen
  | Opengl -> sdl_window_opengl
  | Hidden -> sdl_window_hidden
  | Borderless -> sdl_window_borderless
  | Resizable -> sdl_window_resizable
  | Minimized -> sdl_window_minimized
  | Maximized -> sdl_window_maximized
  | Vulkan -> sdl_window_vulkan
  | Metal -> sdl_window_metal

let window_flags_to_int64 flags =
  List.fold_left
    (fun acc f -> Int64.logor acc (window_flag_to_int64 f))
    0L flags

module Window = struct
  type flag = window_flag

  let all : flag list =
    [ Fullscreen; Opengl; Hidden; Borderless; Resizable; Minimized; Maximized; Vulkan; Metal ]

  let fullscreen = Fullscreen
  let opengl = Opengl
  let hidden = Hidden
  let borderless = Borderless
  let resizable = Resizable
  let minimized = Minimized
  let maximized = Maximized
  let vulkan = Vulkan
  let metal = Metal
end

let sdl_create_window =
  foreign "SDL_CreateWindow" (string @-> int @-> int @-> uint64_t @-> returning (ptr window_tag))

let sdl_destroy_window =
  foreign "SDL_DestroyWindow" (ptr window_tag @-> returning void)

let destroy_window w =
  sdl_destroy_window w

let create_window ~title ~width ~height ~flags =
  let wptr =
    sdl_create_window title width height (Unsigned.UInt64.of_int64 (window_flags_to_int64 flags))
  in
  if is_null wptr then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Gc.finalise destroy_window wptr;
  wptr

let sdl_get_window_id = foreign "SDL_GetWindowID" (ptr window_tag @-> returning uint32_t)
let get_window_id w =
  Unsigned.UInt32.to_int32 (sdl_get_window_id w)

let sdl_get_window_from_id =
  foreign "SDL_GetWindowFromID" (uint32_t @-> returning (ptr window_tag))
let get_window_from_id id =
  let w = sdl_get_window_from_id (Unsigned.UInt32.of_int32 id) in
  if is_null w then None else Some w

let sdl_get_window_display = foreign "SDL_GetDisplayForWindow" (ptr window_tag @-> returning uint32_t)
let get_window_display w =
  Unsigned.UInt32.to_int32 (sdl_get_window_display w)
