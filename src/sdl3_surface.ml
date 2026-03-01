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

(* Blitting *)

let sdl_blit_surface =
  foreign "SDL_BlitSurface"
    (surface_ptr @-> ptr rect_tag @-> surface_ptr @-> ptr rect_tag @-> returning bool)

let blit ~src ?srcrect ~dst ?dstrect () =
  let src_r = match srcrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  let dst_r = match dstrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  if not (sdl_blit_surface src.ptr src_r dst.ptr dst_r) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_blit_surface_scaled =
  foreign "SDL_BlitSurfaceScaled"
    (surface_ptr @-> ptr rect_tag @-> surface_ptr @-> ptr rect_tag @-> int @-> returning bool)

let blit_scaled ~src ?srcrect ~dst ?dstrect ~scale_mode () =
  let src_r = match srcrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  let dst_r = match dstrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  let mode = scale_mode_to_int scale_mode in
  if not (sdl_blit_surface_scaled src.ptr src_r dst.ptr dst_r mode) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_blit_surface_tiled =
  foreign "SDL_BlitSurfaceTiled"
    (surface_ptr @-> ptr rect_tag @-> surface_ptr @-> ptr rect_tag @-> returning bool)

let blit_tiled ~src ?srcrect ~dst ?dstrect () =
  let src_r = match srcrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  let dst_r = match dstrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  if not (sdl_blit_surface_tiled src.ptr src_r dst.ptr dst_r) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_blit_surface_9_grid =
  foreign "SDL_BlitSurface9Grid"
    (surface_ptr @-> ptr rect_tag @-> int @-> int @-> int @-> int @-> float @-> surface_ptr @-> ptr rect_tag @-> returning bool)

let blit_9_grid ~src ?srcrect ~left ~right ~top ~bottom ~scale ~dst ?dstrect () =
  let src_r = match srcrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  let dst_r = match dstrect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  if not (sdl_blit_surface_9_grid src.ptr src_r left right top bottom scale dst.ptr dst_r) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* Filling *)

let sdl_fill_surface_rect =
  foreign "SDL_FillSurfaceRect"
    (surface_ptr @-> ptr rect_tag @-> uint32_t @-> returning bool)

let fill_rect surface ?rect color =
  let r = match rect with None -> coerce (ptr void) (ptr rect_tag) null | Some r -> addr r in
  if not (sdl_fill_surface_rect surface.ptr r (Unsigned.UInt32.of_int color)) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* Conversion *)

let sdl_convert_surface =
  foreign "SDL_ConvertSurface" (surface_ptr @-> uint32_t @-> returning surface_ptr)

let convert surface format =
  let p = sdl_convert_surface surface.ptr (Unsigned.UInt32.of_int format) in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  adopt_ p `None

(* Modulators *)

let sdl_set_surface_color_mod =
  foreign "SDL_SetSurfaceColorMod" (surface_ptr @-> uint8_t @-> uint8_t @-> uint8_t @-> returning bool)

let set_color_mod surface ~r ~g ~b =
  if not (sdl_set_surface_color_mod surface.ptr (Unsigned.UInt8.of_int r) (Unsigned.UInt8.of_int g) (Unsigned.UInt8.of_int b)) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_surface_color_mod =
  foreign "SDL_GetSurfaceColorMod" (surface_ptr @-> ptr uint8_t @-> ptr uint8_t @-> ptr uint8_t @-> returning bool)

let get_color_mod surface =
  let r = allocate uint8_t Unsigned.UInt8.zero in
  let g = allocate uint8_t Unsigned.UInt8.zero in
  let b = allocate uint8_t Unsigned.UInt8.zero in
  if not (sdl_get_surface_color_mod surface.ptr r g b) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (Unsigned.UInt8.to_int !@ r, Unsigned.UInt8.to_int !@ g, Unsigned.UInt8.to_int !@ b)

let sdl_set_surface_alpha_mod =
  foreign "SDL_SetSurfaceAlphaMod" (surface_ptr @-> uint8_t @-> returning bool)

let set_alpha_mod surface alpha =
  if not (sdl_set_surface_alpha_mod surface.ptr (Unsigned.UInt8.of_int alpha)) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_surface_alpha_mod =
  foreign "SDL_GetSurfaceAlphaMod" (surface_ptr @-> ptr uint8_t @-> returning bool)

let get_alpha_mod surface =
  let a = allocate uint8_t Unsigned.UInt8.zero in
  if not (sdl_get_surface_alpha_mod surface.ptr a) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Unsigned.UInt8.to_int !@ a

module Surface = struct
  let view s = !@ (surface_of_ptr s.ptr)
  let w s = getf (view s) _surface_w
  let h s = getf (view s) _surface_h
  let pitch s = getf (view s) _surface_pitch
  let format s = Unsigned.UInt32.to_int (getf (view s) _surface_format)
end
