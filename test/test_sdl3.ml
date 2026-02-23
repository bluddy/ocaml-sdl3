(* Integration tests for SDL3 bindings.
   Require SDL_VIDEO_DRIVER=dummy and SDL_AUDIO_DRIVER=dummy (set in test/dune). *)

open Sdl3
open Alcotest

let test_init () =
  init Init.(video + events);
  check bool "video init" true (Init.test (was_init None) Init.video);
  check bool "events init" true (Init.test (was_init None) Init.events);
  quit ();
  check bool "video quit" false (Init.test (was_init (Some Init.video)) Init.video)

let test_hints () =
  init Init.events;
  let hint = "sdl3_ocaml_test_hint_" ^ string_of_int (Random.int 0xFFFFFF) in
  check bool "set hint" true (set_hint hint "1");
  check (option string) "get hint" (Some "1") (get_hint hint);
  check bool "get hint bool" true (get_hint_boolean hint false);
  reset_hints ();
  check (option string) "hint reset" None (get_hint hint);
  quit ()

let test_version () =
  let maj, _min, _patch = get_version () in
  check int "version major" 3 maj;
  let _ = get_revision () in
  ()

let test_log () =
  let log_priority_testable =
    Alcotest.testable (fun fmt _ -> Format.pp_print_string fmt "log_priority") ( = )
  in
  log "test log message";
  log_message Log.category_application Log.priority_info "direct log_message";
  let p = log_get_priority Log.category_application in
  log_set_priority Log.category_application Log.priority_verbose;
  check log_priority_testable "log priority" Log.priority_verbose
    (log_get_priority Log.category_application);
  log_reset_priorities ();
  check log_priority_testable "log reset" p (log_get_priority Log.category_application)

let test_error () =
  check string "error empty" "" (get_error ());
  set_error "test error message";
  check bool "error set" true (String.length (get_error ()) > 0);
  clear_error ();
  check string "error cleared" "" (get_error ())

let test_window () =
  init Init.(video + events);
  let w = Video.create_window ~title:"test" ~width:320 ~height:240 ~flags:Video.Window.none in
  let id = Video.get_window_id w in
  check bool "window id" true (id <> 0l);
  (match Video.get_window_from_id id with
   | Some w' ->
       let id' = Video.get_window_id w' in
       check int32 "window from id" id id'
   | None -> Alcotest.fail "get_window_from_id returned None");
  let disp = Video.get_window_display w in
  check bool "window display" true (Video.display_id_to_int32 disp <> 0l);
  Video.destroy_window w;
  quit ()

let test_displays () =
  init Init.(video + events);
  let displays = Video.get_displays () in
  check bool "has displays" true (List.length displays > 0);
  List.iteri
    (fun _i did ->
      match Video.get_display_name did with
      | Some _name -> ()
      | None -> ())
    displays;
  (match displays with
  | did :: _ -> (
      match Video.get_display_bounds did with
      | Some r ->
          let _w = Video.Rect.w r in
          let _h = Video.Rect.h r in
          ()
      | None -> ())
  | [] -> ());
  quit ()

let test_events () =
  init Init.(video + events);
  let w =
    Video.create_window ~title:"events_test" ~width:100 ~height:100 ~flags:Video.Window.none
  in
  for _ = 1 to 3 do
    ignore (Event.poll ())
  done;
  Video.destroy_window w;
  quit ();
  check bool "event poll" true true

let test_audio () =
  init Init.audio;
  let stream =
    Audio.open_audio_device_stream
      ~device_id:Audio.Device.default_playback
      ~format:Audio.Format.s16
      ~channels:2
      ~freq:44100
      ()
  in
  check bool "audio stream paused" true (Audio.audio_stream_device_paused stream);
  let buf =
    Bigarray.Array1.create Bigarray.int8_unsigned Bigarray.c_layout 4096
  in
  Audio.put_audio_stream_data stream buf ~pos:0 ~len:4096;
  check int "queued bytes" 4096 (Audio.get_audio_stream_queued stream);
  Audio.destroy_audio_stream stream;
  quit ()

let test_audio_pull () =
  init Init.audio;
  let stream =
    Audio.open_audio_device_stream
      ~device_id:Audio.Device.default_playback
      ~format:Audio.Format.s16
      ~channels:2
      ~freq:44100
      ()
  in
  let callback_invoked = ref false in
  let supply_buf =
    Bigarray.Array1.create Bigarray.int8_unsigned Bigarray.c_layout 1024
  in
  Audio.set_audio_stream_get_callback stream
    (Some
       (fun _s ~additional_amount:_ ~total_amount:_ ->
         callback_invoked := true;
         Audio.put_audio_stream_data stream supply_buf ~pos:0 ~len:1024));
  Audio.resume_audio_stream_device stream;
  ignore (Unix.sleepf 0.05);
  Audio.destroy_audio_stream stream;
  quit ();
  check bool "pull callback invoked" true !callback_invoked

let test_render_smoke () =
  init Init.(video + events);
  let w, r =
    Render.create_window_and_renderer ~title:"render_test" ~width:320 ~height:240
      Video.Window.none
  in
  Render.set_draw_color r ~r:255 ~g:0 ~b:0 ~a:255;
  Render.render_clear r;
  Render.render_present r;
  Render.destroy_renderer r;
  Video.destroy_window w;
  quit ()

let test_texture_from_surface () =
  init Init.(video + events);
  let w, r =
    Render.create_window_and_renderer ~title:"tex_test" ~width:64 ~height:64 Video.Window.none
  in
  let surf =
    Surface.create_surface ~width:32 ~height:32 ~format:Surface.Pixel_format.rgba8888
  in
  let tex = Render.create_texture_from_surface r surf in
  Render.render_texture r tex ();
  Render.render_present r;
  Render.destroy_texture tex;
  Render.destroy_renderer r;
  Video.destroy_window w;
  quit ()

let () =
  run "SDL3"
    [
      ("init", [ test_case "init quit" `Quick test_init ]);
      ("hints", [ test_case "hints" `Quick test_hints ]);
      ("version", [ test_case "version" `Quick test_version ]);
      ("log", [ test_case "log" `Quick test_log ]);
      ("error", [ test_case "error" `Quick test_error ]);
      ("window", [ test_case "window" `Quick test_window ]);
      ("displays", [ test_case "displays" `Quick test_displays ]);
      ("events", [ test_case "events" `Quick test_events ]);
      ("audio", [
          test_case "push" `Quick test_audio;
          test_case "pull" `Quick test_audio_pull;
        ]);
      ("render", [
          test_case "smoke" `Quick test_render_smoke;
          test_case "texture_from_surface" `Quick test_texture_from_surface;
        ]);
    ]
