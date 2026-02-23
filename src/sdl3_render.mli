(** SDL3 2D rendering. *)
type renderer
type texture
type frect
type fpoint

type blend_mode =
  | Blend_none
  | Blend_blend
  | Blend_blend_premultiplied
  | Blend_add
  | Blend_add_premultiplied
  | Blend_mod
  | Blend_mul
  | Blend_invalid

type scale_mode = Scale_invalid | Scale_nearest | Scale_linear | Scale_pixelart

type flip = Flip_none | Flip_horizontal | Flip_vertical | Flip_both

type logical_presentation =
  | Logical_disabled
  | Logical_stretch
  | Logical_letterbox
  | Logical_overscan
  | Logical_integer_scale

type vsync_mode = Vsync_off | Vsync_on | Vsync_adaptive

type texture_access = Texture_static | Texture_streaming | Texture_target

type draw_color = { r : int; g : int; b : int; a : int }
type output_size = { width : int; height : int }
type logical_presentation_result = { width : int; height : int; mode : logical_presentation }
type texture_size = { width : float; height : float }
type locked_texture = {
  pixels : (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t;
  pitch : int;
}

module FRect : sig
  val x : frect -> float
  val y : frect -> float
  val w : frect -> float
  val h : frect -> float
  val set_x : frect -> float -> unit
  val set_y : frect -> float -> unit
  val set_w : frect -> float -> unit
  val set_h : frect -> float -> unit
  val make : x:float -> y:float -> w:float -> h:float -> frect
  val of_rect : Sdl3_video.rect -> frect
end

module FPoint : sig
  val x : fpoint -> float
  val y : fpoint -> float
  val make : x:float -> y:float -> fpoint
end

type fcolor

module FColor : sig
  val r : fcolor -> float
  val g : fcolor -> float
  val b : fcolor -> float
  val a : fcolor -> float
  val make : r:float -> g:float -> b:float -> a:float -> fcolor
end

type vertex

module Vertex : sig
  val position : vertex -> fpoint
  val color : vertex -> fcolor
  val tex_coord : vertex -> fpoint
  val make : position:fpoint -> color:fcolor -> tex_coord:fpoint -> vertex
end

val create_window_and_renderer :
  title:string -> width:int -> height:int -> Sdl3_video.window_flags -> Sdl3_video.window * renderer
val create_renderer : Sdl3_video.window -> ?name:string -> unit -> renderer
val destroy_renderer : renderer -> unit
val get_render_window : renderer -> Sdl3_video.window option
val get_output_size : renderer -> output_size
val set_draw_color : renderer -> r:int -> g:int -> b:int -> a:int -> unit
val get_draw_color : renderer -> draw_color
val set_draw_blend_mode : renderer -> blend_mode -> unit
val render_clear : renderer -> unit
val render_present : renderer -> unit
val flush : renderer -> unit

val create_texture :
  renderer ->
  format:int ->
  access:texture_access ->
  width:int ->
  height:int ->
  texture
val create_texture_from_surface : renderer -> Sdl3_surface.surface -> texture
val destroy_texture : texture -> unit

val render_texture :
  renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> unit -> unit

val render_texture_rotated :
  renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> angle:float ->
  ?center:fpoint -> flip:flip -> unit -> unit

val render_point : renderer -> x:float -> y:float -> unit
val render_line : renderer -> x1:float -> y1:float -> x2:float -> y2:float -> unit
val render_rect : renderer -> frect -> unit
val render_fill_rect : renderer -> frect -> unit

val set_viewport : renderer -> Sdl3_video.rect -> unit
val get_viewport : renderer -> Sdl3_video.rect
val set_clip_rect : renderer -> Sdl3_video.rect -> unit
val get_clip_rect : renderer -> Sdl3_video.rect

(** {2 Render target} *)
val set_render_target : renderer -> texture option -> unit
val get_render_target : renderer -> texture option

(** {2 Texture updates} *)
val update_texture :
  texture ->
  ?rect:Sdl3_video.rect ->
  (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  pitch:int ->
  unit

(** {2 Logical presentation} *)
val set_render_logical_presentation :
  renderer -> width:int -> height:int -> mode:logical_presentation -> unit
val get_render_logical_presentation : renderer -> logical_presentation_result
val get_render_logical_presentation_rect : renderer -> frect

(** {2 Tiled and 9-grid texture rendering} *)
val render_texture_tiled :
  renderer -> texture -> ?srcrect:frect -> scale:float -> ?dstrect:frect -> unit -> unit

val render_texture_9_grid :
  renderer ->
  texture ->
  ?srcrect:frect ->
  left_width:float ->
  right_width:float ->
  top_height:float ->
  bottom_height:float ->
  scale:float ->
  ?dstrect:frect ->
  unit ->
  unit

val render_texture_9_grid_tiled :
  renderer ->
  texture ->
  ?srcrect:frect ->
  left_width:float ->
  right_width:float ->
  top_height:float ->
  bottom_height:float ->
  scale:float ->
  ?dstrect:frect ->
  tile_scale:float ->
  unit ->
  unit

(** {2 Geometry rendering} *)
val render_geometry :
  renderer -> ?texture:texture -> vertex array -> int array option -> unit

val render_geometry_raw :
  renderer ->
  ?texture:texture ->
  xy:(float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  xy_stride:int ->
  color:(float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  color_stride:int ->
  ?uv:(float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  ?uv_stride:int ->
  num_vertices:int ->
  ?indices:
    (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t ->
  ?size_indices:int ->
  unit ->
  unit

(** {2 Read pixels} *)
val render_read_pixels :
  renderer -> ?rect:Sdl3_video.rect -> unit -> Sdl3_surface.surface

(** {2 VSync} *)
val set_render_vsync : renderer -> vsync_mode -> unit
val get_render_vsync : renderer -> vsync_mode

(** {2 Default texture scale mode} *)
val set_default_texture_scale_mode : renderer -> scale_mode -> unit
val get_default_texture_scale_mode : renderer -> scale_mode

(** {2 Texture lock} *)
val with_locked_texture :
  texture ->
  ?rect:Sdl3_video.rect ->
  (locked_texture -> unit) ->
  unit

(** {2 Texture properties} *)
val get_texture_size : texture -> texture_size
val set_texture_blend_mode : texture -> blend_mode -> unit
val get_texture_blend_mode : texture -> blend_mode
val set_texture_scale_mode : texture -> scale_mode -> unit
val get_texture_scale_mode : texture -> scale_mode
