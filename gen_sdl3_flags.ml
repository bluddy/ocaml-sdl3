(* Generate sdl3_cflags.sexp and sdl3_libs.sexp from pkg-config. *)
#load "unix.cma"
let split_flags s =
  let len = String.length s in
  let rec loop start i acc =
    if i >= len then
      if start < len then String.sub s start (len - start) :: acc else acc
    else if s.[i] = ' ' || s.[i] = '\t' then
      if start < i then
        loop (i + 1) (i + 1) (String.sub s start (i - start) :: acc)
      else
        loop (i + 1) (i + 1) acc
    else loop start (i + 1) acc
  in
  List.rev (loop 0 0 [])

let sexp_of_strings flags =
  "(" ^ String.concat " " (List.map (fun f -> "\"" ^ f ^ "\"") flags) ^ ")\n"

let () =
  let cflags =
    try
      let ic = Unix.open_process_in "pkg-config sdl3 --cflags" in
      let s = input_line ic in
      close_in ic;
      split_flags s
    with _ ->
      prerr_endline "Error: pkg-config sdl3 --cflags failed. Install SDL3 and ensure pkg-config finds it.";
      prerr_endline "  From vendored sdl3/: mkdir build && cd build && cmake .. && cmake --build . && cmake --install . --prefix ~/.local";
      exit 1
  in
  let libs =
    try
      let ic = Unix.open_process_in "pkg-config sdl3 --libs" in
      let s = input_line ic in
      close_in ic;
      split_flags s
    with _ ->
      prerr_endline "Error: pkg-config sdl3 --libs failed.";
      exit 1
  in
  let oc = open_out "sdl3_cflags.sexp" in
  output_string oc (sexp_of_strings cflags);
  close_out oc;
  let oc = open_out "sdl3_libs.sexp" in
  output_string oc (sexp_of_strings libs);
  close_out oc
