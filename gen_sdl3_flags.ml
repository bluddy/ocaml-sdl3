(* Generate sdl3_cflags.sexp and sdl3_libs.sexp from pkg-config. *)
#load "unix.cma"

let split_flags s =
  let s' = String.map (fun c -> if c = '\t' then ' ' else c) s in
  s' |> String.split_on_char ' ' |> List.map String.trim
  |> List.filter (fun x -> x <> "")

let escape_sexp s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter (function
    | '"' -> Buffer.add_string b "\\\""
    | '\\' -> Buffer.add_string b "\\\\"
    | c -> Buffer.add_char b c)
    s;
  Buffer.add_char b '"';
  Buffer.contents b

let sexp_of_strings flags =
  "(" ^ String.concat " " (List.map escape_sexp flags) ^ ")\n"

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
