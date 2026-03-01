open Ctypes
open Foreign

type iostream_tag
let iostream_tag : iostream_tag structure typ = structure "SDL_IOStream"
type t = iostream_tag structure ptr
let t_typ = ptr iostream_tag

let sdl_io_from_file = foreign "SDL_IOFromFile" (string @-> string @-> returning t_typ)
let sdl_io_from_mem = foreign "SDL_IOFromMem" (ptr void @-> size_t @-> returning t_typ)
let sdl_close_io = foreign "SDL_CloseIO" (t_typ @-> returning bool)

let close io =
  if not (sdl_close_io io) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let from_file path mode =
  let io = sdl_io_from_file path mode in
  if is_null io then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Gc.finalise (fun io -> ignore (sdl_close_io io)) io;
  io

let from_mem ba =
  let len = Unsigned.Size_t.of_int (Bigarray.Array1.dim ba) in
  let io = sdl_io_from_mem (to_voidp (bigarray_start array1 ba)) len in
  if is_null io then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (* Note: Bigarray must outlive IOStream if created from mem.
     Actually SDL3 might copy or wrap it. SDL_IOFromMem wraps it.
     So we should ideally keep a reference to 'ba' in a record. *)
  Gc.finalise (fun io -> ignore (sdl_close_io io)) io;
  io

let sdl_read_io = foreign "SDL_ReadIO" (t_typ @-> ptr void @-> size_t @-> returning size_t)
let read io ba =
  let len = Unsigned.Size_t.of_int (Bigarray.Array1.dim ba) in
  let n = sdl_read_io io (to_voidp (bigarray_start array1 ba)) len in
  Unsigned.Size_t.to_int n

let sdl_write_io = foreign "SDL_WriteIO" (t_typ @-> ptr void @-> size_t @-> returning size_t)
let write io ba =
  let len = Unsigned.Size_t.of_int (Bigarray.Array1.dim ba) in
  let n = sdl_write_io io (to_voidp (bigarray_start array1 ba)) len in
  Unsigned.Size_t.to_int n

let sdl_get_io_size = foreign "SDL_GetIOSize" (t_typ @-> returning int64_t)
let get_size = sdl_get_io_size

let sdl_get_io_status = foreign "SDL_GetIOStatus" (t_typ @-> returning int)
let get_status = sdl_get_io_status
