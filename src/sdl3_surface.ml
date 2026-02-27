open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_internal

(** SDL_Surface structure for accessing fields. *)
let sdl_surface : surface_tag structure typ = structure "SDL_Surface"
let _surface_flags = field sdl_surface "flags" uint32_t
let _surface_format = field sdl_surface "format" uint32_t
let _surface_w = field sdl_surface "w" int
let _surface_h = field sdl_surface "h" int
let _surface_pitch = field sdl_surface "pitch" int
let _surface_pixels = field sdl_surface "pixels" (ptr void)
let () = seal sdl_surface

type ba = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

type surface = {
  ptr : surface_ptr;
  source : [ `None | `Bigarray of ba ];
}

module Pixel_format = struct
  let rgba8888 = sdl_pixelformat_rgba8888
  let rgb24 = sdl_pixelformat_rgb24
  let rgb565 = sdl_pixelformat_rgb565
end

let sdl_create_surface =
  foreign "SDL_CreateSurface" (int @-> int @-> uint32_t @-> returning surface_ptr)

let sdl_destroy_surface = foreign "SDL_DestroySurface" (surface_ptr @-> returning void)

let surface_of_ptr (p : surface_ptr) =
  coerce surface_ptr (ptr sdl_surface) p

let destroy_surface s =
  sdl_destroy_surface s.ptr

let adopt_ ptr source =
  let s = { ptr; source } in
  Gc.finalise destroy_surface s;
  s

let create_surface ~width ~height ~format =
  let p = sdl_create_surface width height (Unsigned.UInt32.of_int format) in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  adopt_ p `None

let sdl_create_surface_from =
  foreign "SDL_CreateSurfaceFrom"
    (int @-> int @-> uint32_t @-> ptr void @-> int @-> returning surface_ptr)

let create_surface_from ~width ~height ~format ~pixels ~pitch =
  let pix_ptr =
    match pixels with
    | None -> coerce (ptr void) (ptr void) null
    | Some ba -> to_voidp (bigarray_start array1 ba)
  in
  let p = sdl_create_surface_from width height (Unsigned.UInt32.of_int format) pix_ptr pitch in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let source = match pixels with None -> `None | Some ba -> `Bigarray ba in
  adopt_ p source

let sdl_load_bmp = foreign "SDL_LoadBMP" (string @-> returning surface_ptr)

let load_bmp path =
  let p = sdl_load_bmp path in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  adopt_ p `None

let sdl_lock_surface = foreign "SDL_LockSurface" (surface_ptr @-> returning bool)

let lock_surface s =
  if not (sdl_lock_surface s.ptr) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let unlock_surface = foreign "SDL_UnlockSurface" (surface_ptr @-> returning void)

let with_locked_surface surface f =
  lock_surface surface;
  let view = !@ (surface_of_ptr surface.ptr) in
  let pitch = getf view _surface_pitch in
  let h = getf view _surface_h in
  let pix_ptr = getf view _surface_pixels in
  let size = pitch * h in
  let addr = Int64.to_nativeint (Signed.Int64.to_int64 (sdl3_ptr_addr (to_voidp pix_ptr))) in
  let pixels = sdl3_bigarray_of_ptr addr size in
  try
    let res = f (pixels, pitch) in
    unlock_surface surface.ptr;
    res
  with e ->
    unlock_surface surface.ptr;
    raise e

let of_ptr_ p = { ptr = coerce (ptr void) surface_ptr p; source = `None }
let to_ptr_ s = coerce surface_ptr (ptr void) s.ptr
let adopt_ptr_ p = adopt_ (coerce (ptr void) surface_ptr p) `None

module Surface = struct
  let view s = !@ (surface_of_ptr s.ptr)
  let w s = getf (view s) _surface_w
  let h s = getf (view s) _surface_h
  let pitch s = getf (view s) _surface_pitch
  let format s = Unsigned.UInt32.to_int (getf (view s) _surface_format)
end
