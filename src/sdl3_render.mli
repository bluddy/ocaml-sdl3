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

val create_window_and_renderer :
  string -> int -> int -> Sdl3_video.window_flags -> Sdl3_video.window * renderer
val create_renderer : Sdl3_video.window -> ?name:string -> unit -> renderer
val destroy_renderer : renderer -> unit
val render_clear : renderer -> unit
val render_present : renderer -> unit
val set_draw_color : renderer -> int -> int -> int -> int -> unit
val create_texture_from_surface : renderer -> Sdl3_surface.surface -> texture
val destroy_texture : texture -> unit
val get_draw_color : renderer -> int * int * int * int
val create_texture : renderer -> int -> int -> int -> int -> texture
val destroy_texture : texture -> unit
val render_texture : renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> unit -> unit
val render_texture_rotated : renderer -> texture -> ?srcrect:frect -> ?dstrect:frect -> float -> ?center:fpoint -> int -> unit
val render_point : renderer -> float -> float -> unit
val render_line : renderer -> float -> float -> float -> float -> unit
val render_rect : renderer -> frect -> unit
val render_fill_rect : renderer -> frect -> unit
val set_viewport : renderer -> Sdl3_video.rect -> unit
val get_viewport : renderer -> Sdl3_video.rect
val set_clip_rect : renderer -> Sdl3_video.rect -> unit
val get_clip_rect : renderer -> Sdl3_video.rect
_render_window : renderer -> Sdl3_video.window option
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
