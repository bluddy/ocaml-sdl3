[@@@warning "-33"]
open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_video
open Sdl3_surface

(** SDL_Rect - same C struct as Video, obtained by name for make. *)
let sdl_rect = structure "SDL_Rect"

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
  (* [set_x] etc. are in the interface for external mutation. *)
  [@@@warning "-32"]
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
    setf r' _frect_x (Float.of_int (Sdl3_video.Rect.x r));
    setf r' _frect_y (Float.of_int (Sdl3_video.Rect.y r));
    setf r' _frect_w (Float.of_int (Sdl3_video.Rect.w r));
    setf r' _frect_h (Float.of_int (Sdl3_video.Rect.h r));
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

(** SDL_FColor - float RGBA. *)
type fcolor_tag
let sdl_fcolor : fcolor_tag structure typ = structure "SDL_FColor"
let _fcolor_r = field sdl_fcolor "r" float
let _fcolor_g = field sdl_fcolor "g" float
let _fcolor_b = field sdl_fcolor "b" float
let _fcolor_a = field sdl_fcolor "a" float
let () = seal sdl_fcolor

type fcolor = fcolor_tag structure

module FColor = struct
  let r c = getf c _fcolor_r
  let g c = getf c _fcolor_g
  let b c = getf c _fcolor_b
  let a c = getf c _fcolor_a
  let make r g b a =
    let c = Ctypes.make sdl_fcolor in
    setf c _fcolor_r r;
    setf c _fcolor_g g;
    setf c _fcolor_b b;
    setf c _fcolor_a a;
    c
end

(** SDL_Vertex - position, color, tex_coord. *)
type vertex_tag
let sdl_vertex : vertex_tag structure typ = structure "SDL_Vertex"
let _vertex_position = field sdl_vertex "position" sdl_fpoint
let _vertex_color = field sdl_vertex "color" sdl_fcolor
let _vertex_tex_coord = field sdl_vertex "tex_coord" sdl_fpoint
let () = seal sdl_vertex

type vertex = vertex_tag structure

module Vertex = struct
  let position v = getf v _vertex_position
  let color v = getf v _vertex_color
  let tex_coord v = getf v _vertex_tex_coord
  let make ~position ~color ~tex_coord =
    let v = Ctypes.make sdl_vertex in
    setf v _vertex_position position;
    setf v _vertex_color color;
    setf v _vertex_tex_coord tex_coord;
    v
end

let sdl_create_window_and_renderer =
  foreign "SDL_CreateWindowAndRenderer"
    (string @-> int @-> int @-> uint64_t @-> ptr (ptr void) @-> ptr (ptr void)
       @-> returning bool)

let create_window_and_renderer (title : string) (w : int) (h : int)
    (flags : Sdl3_video.window_flags) : Sdl3_video.window * renderer =
  let win_ptr = allocate (ptr void) (from_voidp void null) in
  let ren_ptr = allocate (ptr void) (from_voidp void null) in
  if not (sdl_create_window_and_renderer title w h
            (Unsigned.UInt64.of_int64 flags) win_ptr ren_ptr)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let w' = !@ win_ptr in
  let r' = !@ ren_ptr in
  if is_null w' || is_null r' then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (Sdl3_video.window_of_ptr w', (r' : renderer))

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

let create_texture_from_surface (renderer : renderer) (surface: surface) =
  let t = sdl_create_texture_from_surface renderer (Sdl3_surface.to_ptr_ surface) in
  if is_null t then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  t

let destroy_texture = foreign "SDL_DestroyTexture" (ptr void @-> returning void)

let sdl_render_texture =
  foreign "SDL_RenderTexture"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> ptr sdl_frect @-> returning bool)

let render_texture renderer texture ?srcrect ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture renderer texture src dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_texture_rotated =
  foreign "SDL_RenderTextureRotated"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> ptr sdl_frect @-> double
       @-> ptr sdl_fpoint @-> int @-> returning bool)

let render_texture_rotated renderer texture ?srcrect ?dstrect angle ?center flip =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let ctr = match center with None -> coerce (ptr void) (ptr sdl_fpoint) null | Some p -> addr p in
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
  foreign "SDL_SetRenderViewport" (ptr void @-> ptr void @-> returning bool)

let set_viewport (renderer : renderer) (rect : Sdl3_video.rect) =
  if not (sdl_set_render_viewport renderer (to_voidp (addr rect)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_viewport =
  foreign "SDL_GetRenderViewport" (ptr void @-> ptr void @-> returning bool)

let get_viewport renderer =
  let r = Ctypes.make sdl_rect in
  if not (sdl_get_render_viewport renderer (to_voidp (addr r)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

let sdl_set_render_clip_rect =
  foreign "SDL_SetRenderClipRect" (ptr void @-> ptr void @-> returning bool)

let set_clip_rect (renderer : renderer) (rect : Sdl3_video.rect) =
  if not (sdl_set_render_clip_rect renderer (to_voidp (addr rect)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_clip_rect =
  foreign "SDL_GetRenderClipRect" (ptr void @-> ptr void @-> returning bool)

let get_clip_rect renderer =
  let r = Ctypes.make sdl_rect in
  if not (sdl_get_render_clip_rect renderer (to_voidp (addr r)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

(* --- Render target --- *)
let sdl_set_render_target =
  foreign "SDL_SetRenderTarget" (ptr void @-> ptr void @-> returning bool)

let set_render_target renderer texture =
  if not (sdl_set_render_target renderer
            (match texture with None -> coerce (ptr void) (ptr void) null | Some t -> t))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_target =
  foreign "SDL_GetRenderTarget" (ptr void @-> returning (ptr void))

let get_render_target renderer =
  let t = sdl_get_render_target renderer in
  if is_null t then None else Some t

(* --- UpdateTexture --- *)
let sdl_update_texture =
  foreign "SDL_UpdateTexture"
    (ptr void @-> ptr void @-> ptr void @-> int @-> returning bool)

let update_texture texture ?rect pixels pitch =
  let r =
    match rect with
    | None -> coerce (ptr void) (ptr void) null
    | Some r -> to_voidp (addr r)
  in
  let pix = to_voidp (bigarray_start array1 pixels) in
  if not (sdl_update_texture texture r pix pitch)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- Logical presentation --- *)
let sdl_set_render_logical_presentation =
  foreign "SDL_SetRenderLogicalPresentation"
    (ptr void @-> int @-> int @-> int @-> returning bool)

let set_render_logical_presentation renderer w h mode =
  if not (sdl_set_render_logical_presentation renderer w h mode)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_logical_presentation =
  foreign "SDL_GetRenderLogicalPresentation"
    (ptr void @-> ptr int @-> ptr int @-> ptr int @-> returning bool)

let get_render_logical_presentation renderer =
  let pw = allocate int 0 in
  let ph = allocate int 0 in
  let pmode = allocate int 0 in
  if not (sdl_get_render_logical_presentation renderer pw ph pmode)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (!@ pw, !@ ph, !@ pmode)

let sdl_get_render_logical_presentation_rect =
  foreign "SDL_GetRenderLogicalPresentationRect"
    (ptr void @-> ptr sdl_frect @-> returning bool)

let get_render_logical_presentation_rect renderer =
  let r = Ctypes.make sdl_frect in
  if not (sdl_get_render_logical_presentation_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

(* --- RenderTextureTiled --- *)
let sdl_render_texture_tiled =
  foreign "SDL_RenderTextureTiled"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> float @-> ptr sdl_frect
       @-> returning bool)

let render_texture_tiled renderer texture ?srcrect scale ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_tiled renderer texture src scale dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderTexture9Grid --- *)
let sdl_render_texture_9_grid =
  foreign "SDL_RenderTexture9Grid"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> float @-> float @-> float
       @-> float @-> float @-> ptr sdl_frect @-> returning bool)

let render_texture_9_grid renderer texture ?srcrect left_width right_width
    top_height bottom_height scale ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_9_grid renderer texture src left_width right_width
            top_height bottom_height scale dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderTexture9GridTiled --- *)
let sdl_render_texture_9_grid_tiled =
  foreign "SDL_RenderTexture9GridTiled"
    (ptr void @-> ptr void @-> ptr sdl_frect @-> float @-> float @-> float
       @-> float @-> float @-> ptr sdl_frect @-> float
       @-> returning bool)

let render_texture_9_grid_tiled renderer texture ?srcrect left_width right_width
    top_height bottom_height scale ?dstrect tile_scale () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_9_grid_tiled renderer texture src left_width right_width
            top_height bottom_height scale dst tile_scale)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderGeometry --- *)
let sdl_render_geometry =
  foreign "SDL_RenderGeometry"
    (ptr void @-> ptr void @-> ptr sdl_vertex @-> int @-> ptr int @-> int
       @-> returning bool)

let render_geometry renderer ?texture vertices indices =
  let tex = match texture with None -> from_voidp void null | Some t -> t in
  let nv = Array.length vertices in
  let verts = CArray.of_list sdl_vertex (Array.to_list vertices) in
  let (idx_ptr, ni) =
    match indices with
    | None -> (coerce (ptr void) (ptr int) null, 0)
    | Some idx ->
        let arr = CArray.of_list int (Array.to_list idx) in
        (CArray.start arr, Array.length idx)
  in
  if not (sdl_render_geometry renderer tex (CArray.start verts) nv idx_ptr ni)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderGeometryRaw --- *)
let sdl_render_geometry_raw =
  foreign "SDL_RenderGeometryRaw"
    (ptr void @-> ptr void @-> ptr float @-> int @-> ptr sdl_fcolor @-> int
       @-> ptr float @-> int @-> int @-> ptr void @-> int @-> int
       @-> returning bool)

let render_geometry_raw renderer ?texture ~xy ~xy_stride ~color ~color_stride
    ?uv ?(uv_stride = 0) ~num_vertices ?indices ?(size_indices = 4) () =
  let tex = match texture with None -> from_voidp void null | Some t -> t in
  let uv_ptr, uv_str =
    match uv with
    | None -> (coerce (ptr void) (ptr float) null, 0)
    | Some u ->
        let stride = if uv_stride = 0 then 8 else uv_stride in
        (bigarray_start array1 u, stride)
  in
  let (idx_ptr, ni, si) =
    match indices with
    | None -> (coerce (ptr void) (ptr void) null, 0, size_indices)
    | Some (ba : (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t) ->
        let ptr = bigarray_start array1 ba in
        let n = Bigarray.Array1.dim ba in
        (to_voidp ptr, n, size_indices)
  in
  let color_ptr = coerce (ptr float) (ptr sdl_fcolor) (bigarray_start array1 color) in
  if
    not
      (sdl_render_geometry_raw renderer tex
         (bigarray_start array1 xy)
         xy_stride
         color_ptr
         color_stride uv_ptr uv_str num_vertices idx_ptr ni si)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderReadPixels --- *)
let sdl_render_read_pixels =
  foreign "SDL_RenderReadPixels" (ptr void @-> ptr void @-> returning (ptr void))

let render_read_pixels renderer ?rect () =
  let r =
    match rect with
    | None -> from_voidp void null
    | Some r -> to_voidp (addr r)
  in
  let s = sdl_render_read_pixels renderer r in
  if is_null s then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let s = Sdl3_surface.of_ptr_ s in
  Sdl3_surface.adopt_ s;
  s

(* --- VSync --- *)
let sdl_set_render_vsync = foreign "SDL_SetRenderVSync" (ptr void @-> int @-> returning bool)

let set_render_vsync renderer vsync =
  if not (sdl_set_render_vsync renderer vsync)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_vsync =
  foreign "SDL_GetRenderVSync" (ptr void @-> ptr int @-> returning bool)

let get_render_vsync renderer =
  let p = allocate int 0 in
  if not (sdl_get_render_vsync renderer p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  !@ p

(* --- Default texture scale mode --- *)
let sdl_set_default_texture_scale_mode =
  foreign "SDL_SetDefaultTextureScaleMode" (ptr void @-> int @-> returning bool)

let set_default_texture_scale_mode renderer mode =
  if not (sdl_set_default_texture_scale_mode renderer mode)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_default_texture_scale_mode =
  foreign "SDL_GetDefaultTextureScaleMode" (ptr void @-> ptr int @-> returning bool)

let get_default_texture_scale_mode renderer =
  let p = allocate int 0 in
  if not (sdl_get_default_texture_scale_mode renderer p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  !@ p

(* --- GetTextureSize --- *)
let sdl_get_texture_size =
  foreign "SDL_GetTextureSize" (ptr void @-> ptr float @-> ptr float @-> returning bool)

let get_texture_size texture =
  let pw = allocate float 0.0 in
  let ph = allocate float 0.0 in
  if not (sdl_get_texture_size texture pw ph)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (!@ pw, !@ ph)

(* --- LockTexture / UnlockTexture --- *)
let sdl_lock_texture =
  foreign "SDL_LockTexture"
    (ptr void @-> ptr void @-> ptr (ptr void) @-> ptr int @-> returning bool)

let sdl3_ptr_addr = foreign "sdl3_ptr_addr" (ptr void @-> returning int64_t)

external sdl3_bigarray_of_ptr : nativeint -> int -> (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  = "sdl3_bigarray_of_ptr"

let with_locked_texture texture ?rect f =
  let r =
    match rect with
    | None -> coerce (ptr void) (ptr void) null
    | Some r -> to_voidp (addr r)
  in
  let ppix = allocate (ptr void) (from_voidp void null) in
  let ppitch = allocate int 0 in
  if not (sdl_lock_texture texture r ppix ppitch)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let pix_ptr = !@ ppix in
  let pitch = !@ ppitch in
  let height =
    match rect with
    | Some r -> Sdl3_video.Rect.h r
    | None ->
        let _w, h = get_texture_size texture in
        int_of_float h
  in
  let size = pitch * height in
  let unlock_texture = foreign "SDL_UnlockTexture" (ptr void @-> returning void) in
  let addr = Int64.to_nativeint (Signed.Int64.to_int64 (sdl3_ptr_addr pix_ptr)) in
  let pixels = sdl3_bigarray_of_ptr addr size in
  try
    f (pixels, pitch);
    unlock_texture texture
  with e ->
    unlock_texture texture;
    raise e

(* --- SetTextureBlendMode / GetTextureBlendMode --- *)
let sdl_set_texture_blend_mode =
  foreign "SDL_SetTextureBlendMode" (ptr void @-> uint32_t @-> returning bool)

let set_texture_blend_mode texture mode =
  if not (sdl_set_texture_blend_mode texture (Unsigned.UInt32.of_int mode))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_texture_blend_mode =
  foreign "SDL_GetTextureBlendMode" (ptr void @-> ptr uint32_t @-> returning bool)

let get_texture_blend_mode texture =
  let p = allocate uint32_t Unsigned.UInt32.zero in
  if not (sdl_get_texture_blend_mode texture p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Unsigned.UInt32.to_int !@ p

(* --- SetTextureScaleMode / GetTextureScaleMode --- *)
let sdl_set_texture_scale_mode =
  foreign "SDL_SetTextureScaleMode" (ptr void @-> int @-> returning bool)

let set_texture_scale_mode texture mode =
  if not (sdl_set_texture_scale_mode texture mode)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_texture_scale_mode =
  foreign "SDL_GetTextureScaleMode" (ptr void @-> ptr int @-> returning bool)

let get_texture_scale_mode texture =
  let p = allocate int 0 in
  if not (sdl_get_texture_scale_mode texture p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  !@ p
