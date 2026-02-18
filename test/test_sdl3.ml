(* Integration tests for SDL3 bindings. Run with SDL_VIDEO_DRIVER=dummy, SDL_AUDIO_DRIVER=dummy. *)

open Sdl3.Sdl

let log_test fmt = Printf.eprintf (fmt ^^ "\n%!")
let () = log_test "=== SDL3 integration tests ==="

let test_init () =
  log_test "test_init: init video+events";
  init Init.(video + events);
  assert (Init.test (was_init None) Init.video);
  assert (Init.test (was_init None) Init.events);
  log_test "test_init: quit";
  quit ();
  assert (not (Init.test (was_init (Some Init.video)) Init.video));
  log_test "test_init: ok"

let test_hints () =
  log_test "test_hints";
  init Init.events;
  let hint = "sdl3_ocaml_test_hint_" ^ string_of_int (Random.int 0xFFFFFF) in
  assert (set_hint hint "1");
  assert (get_hint hint = Some "1");
  assert (get_hint_boolean hint false = true);
  reset_hints ();
  assert (get_hint hint = None);
  quit ();
  log_test "test_hints: ok"

let test_version () =
  log_test "test_version";
  let maj, min, patch = get_version () in
  log_test "  version: %d.%d.%d" maj min patch;
  let rev = get_revision () in
  log_test "  revision: %s" (if rev = "" then "(empty)" else rev);
  assert (maj = 3);
  log_test "test_version: ok"

let test_log () =
  log_test "test_log";
  log "test log message";
  log_message Log.category_application Log.priority_info "direct log_message";
  let p = log_get_priority Log.category_application in
  log_set_priority Log.category_application Log.priority_verbose;
  assert (log_get_priority Log.category_application = Log.priority_verbose);
  log_reset_priorities ();
  assert (log_get_priority Log.category_application = p);
  log_test "test_log: ok"

let test_error () =
  log_test "test_error";
  assert (get_error () = "");
  set_error "test error message";
  assert (String.length (get_error ()) > 0);
  clear_error ();
  assert (get_error () = "");
  log_test "test_error: ok"

let test_window () =
  log_test "test_window";
  init Init.(video + events);
  let w = Video.create_window "test" 320 240 Video.Window.none in
  let id = Video.get_window_id w in
  assert (id <> 0l);
  let w' = Video.get_window_from_id id in
  assert (w' = Some w);
  let disp = Video.get_window_display w in
  assert (disp <> 0l);
  Video.destroy_window w;
  quit ();
  log_test "test_window: ok"

let test_displays () =
  log_test "test_displays";
  init Init.(video + events);
  let displays = Video.get_displays () in
  assert (List.length displays > 0);
  List.iteri (fun i did ->
    (match Video.get_display_name did with
     | Some name -> log_test "  display %d: %s" i name
     | None -> ());
    (match Video.get_display_bounds did with
     | Some r -> log_test "    bounds: %d,%d %dx%d" r.x r.y r.w r.h
     | None -> ()))
    displays;
  quit ();
  log_test "test_displays: ok"

let () =
  test_init ();
  test_hints ();
  test_version ();
  test_log ();
  test_error ();
  test_window ();
  test_displays ();
  log_test "=== all tests passed ==="
