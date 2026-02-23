(* Minimal SDL3 example. Requires SDL_VIDEO_DRIVER=dummy and SDL_AUDIO_DRIVER=dummy for headless. *)

open Sdl3

let () =
  init [ Init.video; Init.events ];
  log "SDL3 initialized";
  let maj, min, patch = get_version () in
  log (Printf.sprintf "SDL version: %d.%d.%d" maj min patch);
  let w =
    Video.create_window ~title:"SDL3" ~width:640 ~height:480 ~flags:[]
  in
  let wid = Video.get_window_id w in
  log (Printf.sprintf "Window ID: %ld" wid);
  (* Poll a few times (headless has no user events) *)
  for _ = 1 to 5 do
    ignore (Event.poll ())
  done;
  Video.destroy_window w;
  quit ();
  print_endline "min: ok"
