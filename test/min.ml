(* Minimal SDL3 example. Requires SDL_VIDEO_DRIVER=dummy and SDL_AUDIO_DRIVER=dummy for headless. *)

open Sdl3.Sdl

let () =
  init Init.(video + events);
  log "SDL3 initialized";
  let maj, min, patch = get_version () in
  log (Printf.sprintf "SDL version: %d.%d.%d" maj min patch);
  quit ();
  print_endline "min: ok"
