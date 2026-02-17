# sdl3-ocaml

OCaml bindings for SDL3.

## Prerequisites

- SDL3 installed and discoverable via `pkg-config sdl3`
- If using the vendored `../sdl3/` in this repo:

  ```bash
  cd ../sdl3 && mkdir -p build && cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/.local -DSDL_X11=OFF
  cmake --build . && cmake --install .
  export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH
  export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
  ```

## Build

```bash
dune build
```

## Tests

```bash
dune runtest
```

Tests run with `SDL_VIDEO_DRIVER=dummy` and `SDL_AUDIO_DRIVER=dummy` for headless CI.

## Usage

```ocaml
open Sdl3.Sdl

let () =
  init Init.(video + events);
  log "Hello SDL3";
  let maj, min, patch = get_version () in
  Printf.printf "SDL %d.%d.%d\n" maj min patch;
  quit ()
```
