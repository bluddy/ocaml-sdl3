(lang dune 3.0)
(name sdl3)
(generate_opam_files true)

(package
 (name sdl3)
 (depends
  (ocaml (>= 4.08.0))
  (ctypes (>= 0.21.1))
  (ctypes-foreign (>= 0.21.1))
  (alcotest :with-test)))
