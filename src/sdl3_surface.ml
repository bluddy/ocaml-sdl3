open Ctypes
open Foreign
open Sdl3_consts

(** Opaque surface pointer. *)
type surface = unit ptr

(** SDL_Surface structure for accessing fields. *)
type surface_tag
let sdl_surface : surface_tag structure typ = structure "SDL_Surface"
let _surface_flags = field sdl_surface "flags" uint32_t
let _surface_format = field sdl_surface "format" uint32_t
let _surface_w = field sdl_surface "w" int
let _surface_h = field sdl_surface "h" int
let _surface_pitch = field sdl_surface "pitch" int
let _surface_pixels = field sdl_surface "pixels" (ptr void)
let () = seal sdl_surface

let sdl_create_surface =
  foreign "SDL_CreateSurface" (int @-> int @-> uint32_t @-> returning (ptr void))

let create_surface w h format =
  let p = sdl_create_surface w h (Unsigned.UInt32.of_int format) in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let sdl_create_surface_from =
  foreign "SDL_CreateSurfaceFrom"
    (int @-> int @-> uint32_t @-> ptr void @-> int @-> returning (ptr void))

let create_surface_from w h format pixels pitch =
  let pix_ptr =
    match pixels with
    | None -> coerce (ptr void) (ptr void) null
    | Some ba -> to_voidp (bigarray_start array1 ba)
  in
  let p = sdl_create_surface_from w h (Unsigned.UInt32.of_int format) pix_ptr pitch in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let destroy_surface = foreign "SDL_DestroySurface" (ptr void @-> returning void)

let sdl_load_bmp = foreign "SDL_LoadBMP" (string @-> returning (ptr void))

let load_bmp path =
  let p = sdl_load_bmp path in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let sdl_lock_surface = foreign "SDL_LockSurface" (ptr void @-> returning bool)

let lock_surface s =
  if not (sdl_lock_surface s) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let unlock_surface = foreign "SDL_UnlockSurface" (ptr void @-> returning void)

(** View surface pointer as struct for field access. *)
let surface_of_ptr (p : surface) =
  coerce (ptr void) (ptr sdl_surface) p

module Surface = struct
  let w s = (surface_of_ptr s |-> _surface_w)
  let h s = (surface_of_ptr s |-> _surface_h)
  let pitch s = (surface_of_ptr s |-> _surface_pitch)
  let format s =
    Unsigned.UInt32.to_int (getf (!@ (surface_of_ptr s)) _surface_format)
  (** [pixels s] returns raw C pointer; valid only while surface is locked. *)
  let pixels s = (surface_of_ptr s |-> _surface_pixels)
end
