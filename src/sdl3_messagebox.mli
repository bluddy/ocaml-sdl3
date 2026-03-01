(** SDL3 Message Box API. *)

type flags =
  | Error
  | Warning
  | Information

val show_simple :
  ?window:Sdl3_video.window ->
  flags:flags ->
  title:string ->
  message:string ->
  unit ->
  unit
(** [show_simple ?window ~flags ~title ~message ()] shows a simple message box. *)
