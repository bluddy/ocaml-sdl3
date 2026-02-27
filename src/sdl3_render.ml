open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_internal

type renderer = Sdl3_internal.renderer
type texture = Sdl3_internal.texture

type blend_mode =
  | Blend_none
  | Blend_blend
  | Blend_blend_premultiplied
  | Blend_add
  | Blend_add_premultiplied
  | Blend_mod
  | Blend_mul
  | Blend_unknown of int

let blend_mode_to_int = function
  | Blend_none -> sdl_blendmode_none
  | Blend_blend -> sdl_blendmode_blend
  | Blend_blend_premultiplied -> sdl_blendmode_blend_premultiplied
  | Blend_add -> sdl_blendmode_add
  | Blend_add_premultiplied -> sdl_blendmode_add_premultiplied
  | Blend_mod -> sdl_blendmode_mod
  | Blend_mul -> sdl_blendmode_mul
  | Blend_unknown i -> i

let blend_mode_of_int i =
  if i = sdl_blendmode_none then Blend_none
  else if i = sdl_blendmode_blend then Blend_blend
  else if i = sdl_blendmode_blend_premultiplied then Blend_blend_premultiplied
  else if i = sdl_blendmode_add then Blend_add
  else if i = sdl_blendmode_add_premultiplied then Blend_add_premultiplied
  else if i = sdl_blendmode_mod then Blend_mod
  else if i = sdl_blendmode_mul then Blend_mul
  else Blend_unknown i

type scale_mode =
  | Scale_nearest
  | Scale_linear
  | Scale_pixelart
  | Scale_unknown of int

let scale_mode_to_int = function
  | Scale_nearest -> sdl_scalemode_nearest
  | Scale_linear -> sdl_scalemode_linear
  | Scale_pixelart -> sdl_scalemode_pixelart
  | Scale_unknown i -> i

let scale_mode_of_int i =
  if i = sdl_scalemode_nearest then Scale_nearest
  else if i = sdl_scalemode_linear then Scale_linear
  else if i = sdl_scalemode_pixelart then Scale_pixelart
  else Scale_unknown i

type flip = Flip_none | Flip_horizontal | Flip_vertical | Flip_both

let flip_to_int = function
  | Flip_none -> sdl_flip_none
  | Flip_horizontal -> sdl_flip_horizontal
  | Flip_vertical -> sdl_flip_vertical
  | Flip_both -> sdl_flip_horizontal_and_vertical

type logical_presentation =
  | Logical_disabled
  | Logical_stretch
  | Logical_letterbox
  | Logical_overscan
  | Logical_integer_scale
  | Logical_unknown of int

let logical_presentation_to_int = function
  | Logical_disabled -> sdl_logical_presentation_disabled
  | Logical_stretch -> sdl_logical_presentation_stretch
  | Logical_letterbox -> sdl_logical_presentation_letterbox
  | Logical_overscan -> sdl_logical_presentation_overscan
  | Logical_integer_scale -> sdl_logical_presentation_integer_scale
  | Logical_unknown i -> i

let logical_presentation_of_int i =
  if i = sdl_logical_presentation_disabled then Logical_disabled
  else if i = sdl_logical_presentation_stretch then Logical_stretch
  else if i = sdl_logical_presentation_letterbox then Logical_letterbox
  else if i = sdl_logical_presentation_overscan then Logical_overscan
  else if i = sdl_logical_presentation_integer_scale then Logical_integer_scale
  else Logical_unknown i

type vsync_mode = Vsync_off | Vsync_on | Vsync_adaptive | Vsync_unknown of int

let vsync_mode_to_int = function
  | Vsync_off -> sdl_renderer_vsync_disabled
  | Vsync_on -> 1
  | Vsync_adaptive -> sdl_renderer_vsync_adaptive
  | Vsync_unknown i -> i

let vsync_mode_of_int i =
  if i = sdl_renderer_vsync_disabled then Vsync_off
  else if i = sdl_renderer_vsync_adaptive then Vsync_adaptive
  else if i = 1 then Vsync_on
  else Vsync_unknown i

type texture_access = Texture_static | Texture_streaming | Texture_target

let texture_access_to_int = function
  | Texture_static -> sdl_textureaccess_static
  | Texture_streaming -> sdl_textureaccess_streaming
  | Texture_target -> sdl_textureaccess_target

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

  let make ~x ~y ~w ~h =
    let r = Ctypes.make sdl_frect in
    setf r _frect_x x;
    setf r _frect_y y;
    setf r _frect_w w;
    setf r _frect_h h;
    r

  (** Convert SDL_Rect to SDL_FRect (OCaml-side; SDL_RectToFRect is inline). *)
  let of_rect (r : Sdl3_video.rect) =
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
  let make ~x ~y =
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
  let make ~r ~g ~b ~a =
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
    (string @-> int @-> int @-> uint64_t @-> ptr Sdl3_internal.window @-> ptr Sdl3_internal.renderer
       @-> returning bool)

let create_window_and_renderer ~title ~width ~height
    (flags : Sdl3_video.window_flag list) : Sdl3_video.window * renderer =
  let win_ptr = allocate Sdl3_internal.window (coerce (ptr void) Sdl3_internal.window null) in
  let ren_ptr = allocate Sdl3_internal.renderer (coerce (ptr void) Sdl3_internal.renderer null) in
  if not (sdl_create_window_and_renderer title width height
            (Unsigned.UInt64.of_int64 (Sdl3_video.window_flags_to_int64 flags))
            win_ptr ren_ptr)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let w' = !@ win_ptr in
  let r' = !@ ren_ptr in
  if is_null w' || is_null r' then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let r = r' in
  let destroy_renderer_ = foreign "SDL_DestroyRenderer" (Sdl3_internal.renderer @-> returning void) in
  Gc.finalise destroy_renderer_ r;
  (w', r)

let sdl_create_renderer =
  foreign "SDL_CreateRenderer" (Sdl3_internal.window @-> string_opt @-> returning Sdl3_internal.renderer)

let create_renderer window ?name () =
  let p = sdl_create_renderer window name in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let destroy_renderer_ = foreign "SDL_DestroyRenderer" (Sdl3_internal.renderer @-> returning void) in
  Gc.finalise destroy_renderer_ p;
  p

let destroy_renderer = foreign "SDL_DestroyRenderer" (Sdl3_internal.renderer @-> returning void)

let sdl_get_render_window = foreign "SDL_GetRenderWindow" (Sdl3_internal.renderer @-> returning Sdl3_internal.window)

let get_render_window renderer =
  let w = sdl_get_render_window renderer in
  if is_null w then None else Some w

let sdl_get_current_render_output_size =
  foreign "SDL_GetCurrentRenderOutputSize" (Sdl3_internal.renderer @-> ptr int @-> ptr int @-> returning bool)

type draw_color = { r : int; g : int; b : int; a : int }
type output_size = { width : int; height : int }

let get_output_size renderer =
  let pw = allocate int 0 in
  let ph = allocate int 0 in
  if not (sdl_get_current_render_output_size renderer pw ph)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  { width = !@ pw; height = !@ ph }

let sdl_set_render_draw_color =
  foreign "SDL_SetRenderDrawColor"
    (Sdl3_internal.renderer @-> uint8_t @-> uint8_t @-> uint8_t @-> uint8_t @-> returning bool)

let set_draw_color renderer ~r ~g ~b ~a =
  if
    not
      (sdl_set_render_draw_color renderer (Unsigned.UInt8.of_int r)
         (Unsigned.UInt8.of_int g) (Unsigned.UInt8.of_int b)
         (Unsigned.UInt8.of_int a))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_draw_color =
  foreign "SDL_GetRenderDrawColor"
    (Sdl3_internal.renderer @-> ptr uint8_t @-> ptr uint8_t @-> ptr uint8_t @-> ptr uint8_t @-> returning bool)

let get_draw_color renderer =
  let pr = allocate uint8_t Unsigned.UInt8.zero in
  let pg = allocate uint8_t Unsigned.UInt8.zero in
  let pb = allocate uint8_t Unsigned.UInt8.zero in
  let pa = allocate uint8_t Unsigned.UInt8.zero in
  if not (sdl_get_render_draw_color renderer pr pg pb pa)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  { r = Unsigned.UInt8.to_int !@ pr;
    g = Unsigned.UInt8.to_int !@ pg;
    b = Unsigned.UInt8.to_int !@ pb;
    a = Unsigned.UInt8.to_int !@ pa }

let sdl_set_render_draw_blend_mode =
  foreign "SDL_SetRenderDrawBlendMode" (Sdl3_internal.renderer @-> uint32_t @-> returning bool)

let set_draw_blend_mode renderer mode =
  if not (sdl_set_render_draw_blend_mode renderer (Unsigned.UInt32.of_int (blend_mode_to_int mode)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_clear = foreign "SDL_RenderClear" (Sdl3_internal.renderer @-> returning bool)

let render_clear renderer =
  if not (sdl_render_clear renderer)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_present = foreign "SDL_RenderPresent" (Sdl3_internal.renderer @-> returning void)

let render_present = sdl_render_present

let flush_renderer = foreign "SDL_FlushRenderer" (Sdl3_internal.renderer @-> returning bool)

let flush renderer =
  if not (flush_renderer renderer)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_create_texture =
  foreign "SDL_CreateTexture"
    (Sdl3_internal.renderer @-> uint32_t @-> int @-> int @-> int @-> returning Sdl3_internal.texture)

let create_texture renderer ~format ~access ~width ~height =
  let p =
    sdl_create_texture renderer (Unsigned.UInt32.of_int format)
      (texture_access_to_int access) width height
  in
  if is_null p then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let destroy_texture_ = foreign "SDL_DestroyTexture" (Sdl3_internal.texture @-> returning void) in
  Gc.finalise destroy_texture_ p;
  p

let sdl_create_texture_from_surface =
  foreign "SDL_CreateTextureFromSurface" (Sdl3_internal.renderer @-> Sdl3_internal.surface_ptr @-> returning Sdl3_internal.texture)

let create_texture_from_surface (renderer : renderer) (surface: Sdl3_surface.surface) =
  let t = sdl_create_texture_from_surface renderer (Sdl3_surface.to_ptr_ surface |> coerce (ptr void) Sdl3_internal.surface_ptr) in
  if is_null t then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let destroy_texture_ = foreign "SDL_DestroyTexture" (Sdl3_internal.texture @-> returning void) in
  Gc.finalise destroy_texture_ t;
  t

let destroy_texture = foreign "SDL_DestroyTexture" (Sdl3_internal.texture @-> returning void)

let sdl_render_texture =
  foreign "SDL_RenderTexture"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_frect @-> ptr sdl_frect @-> returning bool)

let render_texture renderer texture ?srcrect ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture renderer texture src dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_texture_rotated =
  foreign "SDL_RenderTextureRotated"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_frect @-> ptr sdl_frect @-> double
       @-> ptr sdl_fpoint @-> int @-> returning bool)

let render_texture_rotated renderer texture ?srcrect ?dstrect ~angle ?center ~flip () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let ctr = match center with None -> coerce (ptr void) (ptr sdl_fpoint) null | Some p -> addr p in
  if not (sdl_render_texture_rotated renderer texture src dst angle ctr (flip_to_int flip))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_point = foreign "SDL_RenderPoint" (Sdl3_internal.renderer @-> float @-> float @-> returning bool)

let render_point renderer ~x ~y =
  if not (sdl_render_point renderer x y)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_line =
  foreign "SDL_RenderLine" (Sdl3_internal.renderer @-> float @-> float @-> float @-> float @-> returning bool)

let render_line renderer ~x1 ~y1 ~x2 ~y2 =
  if not (sdl_render_line renderer x1 y1 x2 y2)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_rect = foreign "SDL_RenderRect" (Sdl3_internal.renderer @-> ptr sdl_frect @-> returning bool)

let render_rect renderer r =
  if not (sdl_render_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_render_fill_rect = foreign "SDL_RenderFillRect" (Sdl3_internal.renderer @-> ptr sdl_frect @-> returning bool)

let render_fill_rect renderer r =
  if not (sdl_render_fill_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_set_render_viewport =
  foreign "SDL_SetRenderViewport" (Sdl3_internal.renderer @-> ptr void @-> returning bool)

let set_viewport (renderer : renderer) (rect : Sdl3_video.rect) =
  if not (sdl_set_render_viewport renderer (to_voidp (Ctypes.addr rect)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_viewport =
  foreign "SDL_GetRenderViewport" (Sdl3_internal.renderer @-> ptr void @-> returning bool)

let get_viewport renderer =
  let r = Sdl3_video.rect_alloc () in
  if not (sdl_get_render_viewport renderer (to_voidp (Ctypes.addr r)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

let sdl_set_render_clip_rect =
  foreign "SDL_SetRenderClipRect" (Sdl3_internal.renderer @-> ptr void @-> returning bool)

let set_clip_rect (renderer : renderer) (rect : Sdl3_video.rect) =
  if not (sdl_set_render_clip_rect renderer (to_voidp (Ctypes.addr rect)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_clip_rect =
  foreign "SDL_GetRenderClipRect" (Sdl3_internal.renderer @-> ptr void @-> returning bool)

let get_clip_rect renderer =
  let r = Sdl3_video.rect_alloc () in
  if not (sdl_get_render_clip_rect renderer (to_voidp (Ctypes.addr r)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

(* --- Render target --- *)
let sdl_set_render_target =
  foreign "SDL_SetRenderTarget" (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> returning bool)

let set_render_target renderer texture =
  if not (sdl_set_render_target renderer
            (match texture with None -> coerce (ptr void) Sdl3_internal.texture null | Some t -> t))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_target =
  foreign "SDL_GetRenderTarget" (Sdl3_internal.renderer @-> returning Sdl3_internal.texture)

let get_render_target renderer =
  let t = sdl_get_render_target renderer in
  if is_null t then None else Some t

(* --- UpdateTexture --- *)
let sdl_update_texture =
  foreign "SDL_UpdateTexture"
    (Sdl3_internal.texture @-> ptr void @-> ptr void @-> int @-> returning bool)

let update_texture texture ?rect pixels ~pitch =
  let r =
    match rect with
    | None -> coerce (ptr void) (ptr void) null
    | Some r -> to_voidp (Ctypes.addr r)
  in
  let pix = to_voidp (bigarray_start array1 pixels) in
  if not (sdl_update_texture texture r pix pitch)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- Logical presentation --- *)
let sdl_set_render_logical_presentation =
  foreign "SDL_SetRenderLogicalPresentation"
    (Sdl3_internal.renderer @-> int @-> int @-> int @-> returning bool)

type logical_presentation_result = { width : int; height : int; mode : logical_presentation }

let set_render_logical_presentation renderer ~width ~height ~mode =
  if not (sdl_set_render_logical_presentation renderer width height (logical_presentation_to_int mode))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_logical_presentation =
  foreign "SDL_GetRenderLogicalPresentation"
    (Sdl3_internal.renderer @-> ptr int @-> ptr int @-> ptr int @-> returning bool)

let get_render_logical_presentation renderer =
  let pw = allocate int 0 in
  let ph = allocate int 0 in
  let pmode = allocate int 0 in
  if not (sdl_get_render_logical_presentation renderer pw ph pmode)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  { width = !@ pw; height = !@ ph; mode = logical_presentation_of_int !@ pmode }

let sdl_get_render_logical_presentation_rect =
  foreign "SDL_GetRenderLogicalPresentationRect"
    (Sdl3_internal.renderer @-> ptr sdl_frect @-> returning bool)

let get_render_logical_presentation_rect renderer =
  let r = Ctypes.make sdl_frect in
  if not (sdl_get_render_logical_presentation_rect renderer (addr r))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  r

(* --- RenderTextureTiled --- *)
let sdl_render_texture_tiled =
  foreign "SDL_RenderTextureTiled"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_frect @-> float @-> ptr sdl_frect
       @-> returning bool)

let render_texture_tiled renderer texture ?srcrect ~scale ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_tiled renderer texture src scale dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderTexture9Grid --- *)
let sdl_render_texture_9_grid =
  foreign "SDL_RenderTexture9Grid"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_frect @-> float @-> float @-> float
       @-> float @-> float @-> ptr sdl_frect @-> returning bool)

let render_texture_9_grid renderer texture ?srcrect ~left_width ~right_width
    ~top_height ~bottom_height ~scale ?dstrect () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_9_grid renderer texture src left_width right_width
            top_height bottom_height scale dst)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderTexture9GridTiled --- *)
let sdl_render_texture_9_grid_tiled =
  foreign "SDL_RenderTexture9GridTiled"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_frect @-> float @-> float @-> float
       @-> float @-> float @-> ptr sdl_frect @-> float
       @-> returning bool)

let render_texture_9_grid_tiled renderer texture ?srcrect ~left_width ~right_width
    ~top_height ~bottom_height ~scale ?dstrect ~tile_scale () =
  let src = match srcrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  let dst = match dstrect with None -> coerce (ptr void) (ptr sdl_frect) null | Some r -> addr r in
  if not (sdl_render_texture_9_grid_tiled renderer texture src left_width right_width
            top_height bottom_height scale dst tile_scale)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

(* --- RenderGeometry --- *)
let sdl_render_geometry =
  foreign "SDL_RenderGeometry"
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr sdl_vertex @-> int @-> ptr int @-> int
       @-> returning bool)

let render_geometry renderer ?texture vertices indices =
  let tex = match texture with None -> coerce (ptr void) Sdl3_internal.texture null | Some t -> t in
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
    (Sdl3_internal.renderer @-> Sdl3_internal.texture @-> ptr float @-> int @-> ptr sdl_fcolor @-> int
       @-> ptr float @-> int @-> int @-> ptr void @-> int @-> int
       @-> returning bool)

let render_geometry_raw renderer ?texture ~xy ~xy_stride ~color ~color_stride
    ?uv ?(uv_stride = 0) ~num_vertices ?indices ?(size_indices = 4) () =
  let tex = match texture with None -> coerce (ptr void) Sdl3_internal.texture null | Some t -> t in
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
  foreign "SDL_RenderReadPixels" (Sdl3_internal.renderer @-> ptr void @-> returning surface_ptr)

let render_read_pixels renderer ?rect () =
  let r =
    match rect with
    | None -> coerce (ptr void) (ptr void) null
    | Some r -> to_voidp (Ctypes.addr r)
  in
  let s = sdl_render_read_pixels renderer r in
  if is_null s then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  Sdl3_surface.adopt_ptr_ (to_voidp s)

(* --- VSync --- *)
let sdl_set_render_vsync = foreign "SDL_SetRenderVSync" (Sdl3_internal.renderer @-> int @-> returning bool)

let set_render_vsync renderer vsync =
  if not (sdl_set_render_vsync renderer (vsync_mode_to_int vsync))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_render_vsync =
  foreign "SDL_GetRenderVSync" (Sdl3_internal.renderer @-> ptr int @-> returning bool)

let get_render_vsync renderer =
  let p = allocate int 0 in
  if not (sdl_get_render_vsync renderer p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  vsync_mode_of_int !@ p

(* --- Default texture scale mode --- *)
let sdl_set_default_texture_scale_mode =
  foreign "SDL_SetDefaultTextureScaleMode" (Sdl3_internal.renderer @-> int @-> returning bool)

let set_default_texture_scale_mode renderer mode =
  if not (sdl_set_default_texture_scale_mode renderer (scale_mode_to_int mode))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_default_texture_scale_mode =
  foreign "SDL_GetDefaultTextureScaleMode" (Sdl3_internal.renderer @-> ptr int @-> returning bool)

let get_default_texture_scale_mode renderer =
  let p = allocate int 0 in
  if not (sdl_get_default_texture_scale_mode renderer p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  scale_mode_of_int !@ p

(* --- GetTextureSize --- *)
let sdl_get_texture_size =
  foreign "SDL_GetTextureSize" (Sdl3_internal.texture @-> ptr float @-> ptr float @-> returning bool)

type texture_size = { width : float; height : float }

type locked_texture = {
  pixels : (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t;
  pitch : int;
}

let get_texture_size texture =
  let pw = allocate float 0.0 in
  let ph = allocate float 0.0 in
  if not (sdl_get_texture_size texture pw ph)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  { width = !@ pw; height = !@ ph }

(* --- LockTexture / UnlockTexture --- *)
let sdl_lock_texture =
  foreign "SDL_LockTexture"
    (Sdl3_internal.texture @-> ptr void @-> ptr (ptr void) @-> ptr int @-> returning bool)

let with_locked_texture texture ?rect f =
  let r =
    match rect with
    | None -> coerce (ptr void) (ptr void) null
    | Some r -> to_voidp (Ctypes.addr r)
  in
  let ppix = allocate (ptr void) (coerce (ptr void) (ptr void) null) in
  let ppitch = allocate int 0 in
  if not (sdl_lock_texture texture r ppix ppitch)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let pix_ptr = !@ ppix in
  let pitch = !@ ppitch in
  let height =
    match rect with
    | Some r -> Sdl3_video.Rect.h r
    | None ->
        let { height = h; _ } = get_texture_size texture in
        int_of_float h
  in
  let size = pitch * height in
  let unlock_texture_ = foreign "SDL_UnlockTexture" (Sdl3_internal.texture @-> returning void) in
  let addr = Int64.to_nativeint (Signed.Int64.to_int64 (sdl3_ptr_addr pix_ptr)) in
  let pixels = sdl3_bigarray_of_ptr addr size in
  try
    f { pixels; pitch };
    unlock_texture_ texture
  with e ->
    unlock_texture_ texture;
    raise e

(* --- SetTextureBlendMode / GetTextureBlendMode --- *)
let sdl_set_texture_blend_mode =
  foreign "SDL_SetTextureBlendMode" (Sdl3_internal.texture @-> uint32_t @-> returning bool)

let set_texture_blend_mode texture mode =
  if not (sdl_set_texture_blend_mode texture (Unsigned.UInt32.of_int (blend_mode_to_int mode)))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_texture_blend_mode =
  foreign "SDL_GetTextureBlendMode" (Sdl3_internal.texture @-> ptr uint32_t @-> returning bool)

let get_texture_blend_mode texture =
  let p = allocate uint32_t Unsigned.UInt32.zero in
  if not (sdl_get_texture_blend_mode texture p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  blend_mode_of_int (Unsigned.UInt32.to_int !@ p)

(* --- SetTextureScaleMode / GetTextureScaleMode --- *)
let sdl_set_texture_scale_mode =
  foreign "SDL_SetTextureScaleMode" (Sdl3_internal.texture @-> int @-> returning bool)

let set_texture_scale_mode texture mode =
  if not (sdl_set_texture_scale_mode texture (scale_mode_to_int mode))
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let sdl_get_texture_scale_mode =
  foreign "SDL_GetTextureScaleMode" (Sdl3_internal.texture @-> ptr int @-> returning bool)

let get_texture_scale_mode texture =
  let p = allocate int 0 in
  if not (sdl_get_texture_scale_mode texture p)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  scale_mode_of_int !@ p
