open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_video
open Sdl3_surface

(** Opaque renderer and texture pointers. *)
type renderer = unit ptr
type texture = unit ptr

(** SDL_FPoint - float point. *)
type fpoint_tag
let sdl_fpoint : fpoint_tag structure typ = structure "SDL_FPoint"
let _fpoint_x = field sdl_fpoint "x" float
let _fpoint_y = field sdl_fpoint "y" float
let () = seal sdl_fpoint

(** SDL_FRect - float rectangle. *)
type frect_tag
let sdl_frect : frect_tag structure typ = structure "SDL_FRect"
let _frect_x = field sdl_frect "x" float
let _frect_y = field sdl_frect "y" float
let _frect_w = field sdl_frect "w" float
let _frect_h = field sdl_frect "h" float
let () = seal sdl_frect

type frect = frect_tag structure
type fpoint = fpoint_tag structure

module FRect = struct
  let x r = getf r _frect_x
  let y r = getf r _frect_y
  let w r = getf r _frect_w
  let h r = getf r _frect_h
  let set_x r v = setf r _frect_x v
  let set_y r v = setf r _frect_y v
  let set_w r v = setf r _frect_w v
  let set_h r v = setf r _frect_h v

  let make x y w h =
    let r = Ctypes.make sdl_frect in
    setf r _frect_x x;
    setf r _frect_y y;
    setf r _frect_w w;
    setf r _frect_h h;
    r

  (** Convert SDL_Rect to SDL_FRect (OCaml-side; SDL_RectToFRect is inline). *)
  let of_rect (r : rect) =
    let r' = Ctypes.make sdl_frect in
    setf r' _frect_x (float (Sdl3_video.Rect.x r));
    setf r' _frect_y (float (Sdl3_video.Rect.y r));
    setf r' _frect_w (float (Sdl3_video.Rect.w r));
    setf r' _frect_h (float (Sdl3_video.Rect.h r));
    r'
end

module FPoint = struct
  let x p = getf p _fpoint_x
  let y p = getf p _fpoint_y
  let make x y =
    let p = Ctypes.make sdl_fpoint in
    setf p _fpoint_x x;
    setf p _fpoint_y y;
    p
end

let sdl_create_window_and_renderer =
  foreign "SDL_CreateWindowAndRenderer"
    (string @-> int @-> int @-> uint64_t @-> ptr (ptr void) @-> ptr (ptr void)
       @-> returning bool)

let create_window_and_renderer title w h flags =
  let win_ptr = allocate (ptr void) (from_voidp void null) in
  let ren_ptr = allocate (ptr void) (from_voidp void null) in
  if not (sdl_create_window_and_renderer title w h
            (Unsigned.UInt64.of_int64 flags) win_ptr ren_ptr)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let w' = !@ win_ptr in
  let r' = !@ ren_ptr in
  if is_null w' || is_null r' then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (w', r')

let sdl_create_renderer =
  foreign "SDL_CreateRenderer" (ptr void @-> string_opt @-> returning (ptr void))

let create_renderer window ?name () =
  let p = sdl_create_renderer window name in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let destroy_renderer = foreign "SDL_DestroyRenderer" (ptr void @-> returning void)

let sdl_get_render_window = foreign "SDL_GetRenderWindow" (ptr void @-> returning (ptr void))

let get_render_window renderer =
  let w = sdl_get_render_window renderer in
  if is_null w then None else Some w

let sdl_get_current_render_output_size =
  foreign "SDL_GetCurrentRenderOutputSize" (ptr void @-> ptr int @-> ptr int @-> returning bool)

let get_output_size renderer =
  let pw = allocate int 0 in
  let ph = allocate int 0 in
  if not (sdl_get_current_render_output_size renderer pw ph)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (!@ pw, !@ ph)

let sdl_set_render_draw_color =
  foreign "SDL_SetRenderDrawColor"
    (ptr void @-> uint8_t @-> uint8_t @-> uint8_t @-> uint8_t @-> returning bool)

let set_draw_color renderer r g b a =
  if
    not
      (sdl_set_render_draw_color renderer (Unsigned.UInt8.of_int r)
         (Unsigned.UInt8.of_int g) (Unsigned.UInt8.of_int b)
         (Unsigned.UInt8.of_int a))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_draw_color =
  foreign "SDL_GetRenderDrawColor"
    (ptr void @-> ptr uint8_t @-> ptr uint8_t @-> ptr uint8_t @-> ptr uint8_t @-> returning bool)

let get_draw_color renderer =
  let pr = allocate uint8_t Unsigned.UInt8.zero in
  let pg = allocate uint8_t Unsigned.UInt8.zero in
  let pb = allocate uint8_t Unsigned.UInt8.zero in
  let pa = allocate uint8_t Unsigned.UInt8.zero in
  if not (sdl_get_render_draw_color renderer pr pg pb pa)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  ( Unsigned.UInt8.to_int !@ pr,
    Unsigned.UInt8.to_int !@ pg,
    Unsigned.UInt8.to_int !@ pb,
    Unsigned.UInt8.to_int !@ pa )

let sdl_set_render_draw_blend_mode =
  foreign "SDL_SetRenderDrawBlendMode" (ptr void @-> uint32_t @-> returning bool)

let set_draw_blend_mode renderer mode =
  if not (sdl_set_render_draw_blend_mode renderer (Unsigned.UInt32.of_int mode))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_clear = foreign "SDL_RenderClear" (ptr void @-> returning bool)

let render_clear renderer =
  if not (sdl_render_clear renderer)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_present = foreign "SDL_RenderPresent" (ptr void @-> returning void)

let render_present = sdl_render_present

let flush_renderer = foreign "SDL_FlushRenderer" (ptr void @-> returning bool)

let flush renderer =
  if not (flush_renderer renderer)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_create_texture =
  foreign "SDL_CreateTexture"
    (ptr void @-> uint32_t @-> int @-> int @-> int @-> returning (ptr void))

let create_texture renderer format access w h =
  let p =
    sdl_create_texture renderer (Unsigned.UInt32.of_int format) access w h
  in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let sdl_create_texture_from_surface =
  foreign "SDL_CreateTextureFromSurface" (ptr void @-> ptr void @-> returning (ptr void))

let create_texture_from_surface renderer surface =
  let p = sdl_create_texture_from_surface renderer surface in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  p

let destroy_texture = foreign "SDL_DestroyTexture" (ptr void @-> returning void)

let sdl_render_texture =
  foreign "SDL_RenderTexture"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> ptr sdl_frect @-> returning bool)

let render_texture renderer texture ?srcrect ?dstrect () =
  let src = match srcrect with None -> coerce (ptr sdl_frect) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr sdl_frect) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture renderer texture src dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_texture_rotated =
  foreign "SDL_RenderTextureRotated"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> ptr sdl_frect @-> double
       @-> ptr sdl_fpoint @-> int @-> returning bool)

let render_texture_rotated renderer texture ?srcrect ?dstrect angle ?center flip =
  let src = match srcrect with None -> coerce (ptr sdl_frect) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr sdl_frect) (ptr sdl_frect) null | Some r -> addr r in
  let ctr = match center with None -> coerce (ptr sdl_fpoint) (ptr sdl_fpoint) null | Some p -> addr p in
  if not (sdl_render_texture_rotated renderer texture src dst angle ctr flip)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_point = foreign "SDL_RenderPoint" (ptr void @-> float @-> float @-> returning bool)

let render_point renderer x y =
  if not (sdl_render_point renderer x y)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_line =
  foreign "SDL_RenderLine" (ptr void @-> float @-> float @-> float @-> float @-> returning bool)

let render_line renderer x1 y1 x2 y2 =
  if not (sdl_render_line renderer x1 y1 x2 y2)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_rect = foreign "SDL_RenderRect" (ptr void @-> ptr sdl_frect @-> returning bool)

let render_rect renderer r =
  if not (sdl_render_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_fill_rect = foreign "SDL_RenderFillRect" (ptr void @-> ptr sdl_frect @-> returning bool)

let render_fill_rect renderer r =
  if not (sdl_render_fill_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_set_render_viewport =
  foreign "SDL_SetRenderViewport" (ptr void @-> ptr Sdl3_video.sdl_rect @-> returning bool)

let set_viewport renderer rect =
  if not (sdl_set_render_viewport renderer (addr rect))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_viewport =
  foreign "SDL_GetRenderViewport" (ptr void @-> ptr Sdl3_video.sdl_rect @-> returning bool)

let get_viewport renderer =
  let r = Ctypes.make Sdl3_video.sdl_rect in
  if not (sdl_get_render_viewport renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

let sdl_set_render_clip_rect =
  foreign "SDL_SetRenderClipRect" (ptr void @-> ptr Sdl3_video.sdl_rect @-> returning bool)

let set_clip_rect renderer rect =
  if not (sdl_set_render_clip_rect renderer (addr rect))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_clip_rect =
  foreign "SDL_GetRenderClipRect" (ptr void @-> ptr Sdl3_video.sdl_rect @-> returning bool)

let get_clip_rect renderer =
  let r = Ctypes.make Sdl3_video.sdl_rect in
  if not (sdl_get_render_clip_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r
