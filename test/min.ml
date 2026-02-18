(* Minimal SDL3 example. Requires SDL_VIDEO_DRIVER=dummy and SDL_AUDIO_DRIVER=dummy for headless. *)

open Sdl3

let () =
  init Init.(video + events);
  log "SDL3 initialized";
  let maj, min, patch = get_version () in
  log (Printf.sprintf "SDL version: %d.%d.%d" maj min patch);
  let w = Video.create_window "SDL3" 640 480 Video.Window.none in
  let wid = Video.get_window_id w in
  log (Printf.sprintf "Window ID: %ld" wid);
  Video.destroy_window w;
  quit ();
  print_endline "min: ok"
