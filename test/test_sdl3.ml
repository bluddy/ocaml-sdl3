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
  log "test log message";
  log_message Log.category_application Log.priority_info "direct log_message";
  let p = log_get_priority Log.category_application in
  log_set_priority Log.category_application Log.priority_verbose;
  check int "log priority" Log.priority_verbose (log_get_priority Log.category_application);
  log_reset_priorities ();
  check int "log reset" p (log_get_priority Log.category_application)

let test_error () =
  check string "error empty" "" (get_error ());
  set_error "test error message";
  check bool "error set" true (String.length (get_error ()) > 0);
  clear_error ();
  check string "error cleared" "" (get_error ())

let test_window () =
  init Init.(video + events);
  let w = Video.create_window "test" 320 240 Video.Window.none in
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
  List.iteri (fun _i _did ->
    match Video.get_display_name _did with
    | Some _name -> ()
    | None -> ())
    displays;
  quit ()

let test_events () =
  init Init.(video + events);
  let w = Video.create_window "events_test" 100 100 Video.Window.none in
  for _ = 1 to 3 do
    ignore (Event.poll ())
  done;
  Video.destroy_window w;
  quit ();
  check bool "event poll" true true

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
    ]
