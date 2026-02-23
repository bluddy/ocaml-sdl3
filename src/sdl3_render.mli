(** SDL3 2D rendering. *)
type renderer
type texture
type frect
type fpoint

module FRect : sig
  val x : frect -> float
  val y : frect -> float
  val w : frect -> float
  val h : frect -> float
  val make : float -> float -> float -> float -> frect
  val of_rect : Sdl3_video.rect -> frect
end

module FPoint : sig
  val x : fpoint -> float
  val y : fpoint -> float
  val make : float -> float -> fpoint
end

type fcolor

module FColor : sig
  val r : fcolor -> float
  val g : fcolor -> float
  val b : fcolor -> float
  val a : fcolor -> float
  val make : float -> float -> float -> float -> fcolor
end

type vertex

module Vertex : sig
  val position : vertex -> fpoint
  val color : vertex -> fcolor
  val tex_coord : vertex -> fpoint
  val make : position:fpoint -> color:fcolor -> tex_coord:fpoint -> vertex
end

val create_window_and_renderer :
  string -> int -> int -> Sdl3_video.window_flags -> Sdl3_video.window * renderer
val create_renderer : Sdl3_video.window -> ?name:string -> unit -> renderer
val destroy_renderer : renderer -> unit
val get_render_window : renderer -> Sdl3_video.window option
val get_output_size : renderer -> int * int
val set_draw_color : renderer -> int -> int -> int -> int -> unit
val get_draw_color : renderer -> int * int * int * int
val set_draw_blend_mode : renderer -> int -> unit
val render_clear : renderer -> unit
val render_present : renderer -> unit
val flush : renderer -> unit

val create_texture : renderer -> int -> int -> int -> int -> texture
val create_texture_from_surface : renderer -> Sdl3_surface.surface -> texture
val destroy_texture : texture -> unit

val render_texture :
  renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> unit -> unit

val render_texture_rotated :
  renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> float ->
  ?center:fpoint -> int -> unit

val render_point : renderer -> float -> float -> unit
val render_line : renderer -> float -> float -> float -> float -> unit
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
  int ->
  unit

(** {2 Logical presentation} *)
val set_render_logical_presentation : renderer -> int -> int -> int -> unit
val get_render_logical_presentation : renderer -> int * int * int
val get_render_logical_presentation_rect : renderer -> frect

(** {2 Tiled and 9-grid texture rendering} *)
val render_texture_tiled :
  renderer -> texture -> ?srcrect:frect -> float -> ?dstrect:frect -> unit -> unit

val render_texture_9_grid :
  renderer ->
  texture ->
  ?srcrect:frect ->
  float ->
  float ->
  float ->
  float ->
  float ->
  ?dstrect:frect ->
  unit ->
  unit

val render_texture_9_grid_tiled :
  renderer ->
  texture ->
  ?srcrect:frect ->
  float ->
  float ->
  float ->
  float ->
  float ->
  ?dstrect:frect ->
  float ->
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
val set_render_vsync : renderer -> int -> unit
val get_render_vsync : renderer -> int

(** {2 Default texture scale mode} *)
val set_default_texture_scale_mode : renderer -> int -> unit
val get_default_texture_scale_mode : renderer -> int

(** {2 Texture lock}

    Use [with_locked_texture] to access texture pixels as a Bigarray. The
    callback receives [(pixels, pitch)] where [pixels] is a 1D byte buffer
    (size = pitch * height) and [pitch] is bytes per row. The buffer is
    valid only during the callback; do not use it after the callback returns. *)
val with_locked_texture :
  texture ->
  ?rect:Sdl3_video.rect ->
  ((int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t * int ->
   unit) ->
  unit

(** {2 Texture properties} *)
val get_texture_size : texture -> float * float
val set_texture_blend_mode : texture -> int -> unit
val get_texture_blend_mode : texture -> int
val set_texture_scale_mode : texture -> int -> unit
val get_texture_scale_mode : texture -> int
