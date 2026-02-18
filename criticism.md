# sdl3-ocaml: Software Engineering & OCaml Best Practices Criticism

This document reviews the sdl3-ocaml project from the perspectives of software engineering, functional programming, and OCaml conventions. The intent is constructive—to identify gaps and suggest improvements.

---

## 1. Side Effects at Module Load Time

**Location:** `sdl3.ml` lines 52–54

```ocaml
let () =
  let set_main_ready = foreign "SDL_SetMainReady" (void @-> returning void) in
  set_main_ready ()
```

**Issue:** `SDL_SetMainReady` is invoked as soon as the module is loaded. This:

- Introduces hidden global state and side effects without the caller’s knowledge
- Complicates testing and mocking
- Breaks assumptions of referential transparency and predictable module initialization

**Recommendation:** Expose an explicit `set_main_ready : unit -> unit` and document that it must be called when relevant (e.g. before init in some setups). Let the application call it, not the library.

---

## 2. Weak Type Safety: Bare Primitives Instead of Abstract Types

**Locations:** Various

| Type        | Current | Problem |
|-------------|---------|---------|
| `Hint.t`    | `string` | Any string can be passed; no guarantee it’s a valid hint name |
| `Hint.priority` | `int` | Arbitrary integers; no validation of valid priority levels |
| `Log.category` | `int` | Same as above |
| `Log.priority` | `int` | Same as above |
| `display_id`   | `int32` | No abstraction; easy to mix with other `int32` values |
| `window_flags` | `int64` | Same as above |

**Recommendation:** Use abstract types with smart constructors:

```ocaml
module Hint : sig
  type t
  val framebuffer_acceleration : t
  val audio_driver : t
  val video_driver : t
  (* ... *)
  val to_string : t -> string  (* for ctypes only, internal *)
end
```

This avoids mixing unrelated integers and enforces valid values at compile time.

---

## 3. Error Handling: Exceptions 

**Current approach:** All failures raise `Sdl_error`.

Consider documenting which functions can raise and under what conditions (e.g. with `[@raises Sdl_error ...]`).

---

## 4. Resource Safety: Use-After-Free Risk

**Issue:** `window` is an opaque `unit ptr`. After `destroy_window w`, the value `w` is still in scope and can be passed to other functions, leading to undefined behavior.

**Recommendation:** Options (from simplest to stronger):

1. **Documentation:** Clearly state that `destroy_window` invalidates the window and that using it afterward is UB.
2. **Option type:** Make `destroy_window` consume the window:  
   `val destroy_window : window -> unit` with the convention that the caller must not use the value afterwards (unenforceable but clearer).

---

## 5. Duplicated Exception Definition

**Locations:** `sdl3_error.ml`, `sdl3.ml`, `sdl3.mli`

`Sdl_error` is defined in `sdl3_error.ml` and re-exported in several places with `exception Sdl_error = Sdl3_error.Sdl_error`. The module `Sdl` again re-exports it.

**Recommendation:** Centralize the exception in one module (e.g. `Sdl3_error`) and re-export it only at the public API boundary (`Sdl3.Sdl`). Avoid multiple definitions that can drift.

---

## 6. Functional Programming: Imperative Style in Tests

**Location:** `test/test_sdl3.ml`

Tests use `assert` and imperative sequencing:

```ocaml
let test_init () =
  log_test "test_init: init video+events";
  init Init.(video + events);
  assert (Init.test (was_init None) Init.video);
  assert (Init.test (was_init None) Init.events);
  (* ... *)
```

**Issues:**

- `assert` can be disabled with `-noassert`, making tests silently pass
- No test framework structure (setup/teardown, isolation, reporting)
- Tests share mutable SDL state; order dependencies are implicit
- No distinction between integration and unit tests

**Recommendation:** Use a test framework (e.g. Alcotest, OUnit2):

```ocaml
let test_init () =
  Alcotest.(check bool) "video init" true (Init.test (was_init None) Init.video)
```

Add clear setup/teardown (e.g. `init` / `quit`) and document test ordering and environment assumptions.

---

## 7. gen_sdl3_flags.ml: Build-Time Script Issues

**Location:** `gen_sdl3_flags.ml`

**Issues:**

- Uses `#load "unix.cma"` — relies on the old `ocaml` driver and `cma` files; not compatible with dune’s default `ocamlc`/`ocamlopt` usage
- Implements `split_flags` manually; `String.split_on_char` (4.04+) would simplify this
- Script is invoked directly with `ocaml`; no explicit dependency on a particular OCaml version
- Output files (`sdl3_cflags.sexp`, `sdl3_libs.sexp`) are generated at build time but might not be regenerated when `pkg-config` output changes
- No `.gitignore` for generated `.sexp` files if they are ever committed by mistake

**Recommendation:** Will be obsoleted by migration to Dune ctypes 0.3 (§16); `(build_flags_resolver pkg_config)` handles this natively.

---

## 8. gen_sdl3_flags.ml: String Concatenation for S-Expressions

```ocaml
let sexp_of_strings flags =
  "(" ^ String.concat " " (List.map (fun f -> "\"" ^ f ^ "\"") flags) ^ ")\n"
```

**Issue:** No escaping of `"` or `\` inside flag strings; malicious or unusual `pkg-config` output could produce invalid or unsafe S-expressions.

**Recommendation:** Will be obsoleted by migration to Dune ctypes 0.3 (§16); no custom .sexp generation needed.

---

## 9. Module Structure and Naming

**Current:** `Sdl3.Sdl` — nested `Sdl` under `Sdl3`.

**Issues:**

- Redundant naming (`Sdl3.Sdl` vs `Sdl3` alone)
- Users must `open Sdl3.Sdl`, which is unusual for a single main module

**Recommendation:** Either:

- Expose the main API as `Sdl3` directly (`open Sdl3`), or
- Keep `Sdl` if you plan to add other top-level modules (e.g. `Sdl3.Audio`, `Sdl3.Sdl`) and document the intended structure.

---

## 10. Sdl3_consts: Public vs Internal API

**Current:** `sdl3_consts.mli` exposes raw constants (`sdl_init_audio`, `sdl_log_category_application`, etc.) that are primarily for internal use.

**Issue:** Consumers might depend on these implementation details (e.g. exact numeric values), making it harder to change the implementation later.

**Recommendation:** Keep constants in `.ml` only where possible, or hide them behind an `Internal` sub-module. The public API should use abstract types and constructors, not raw C constants.

---

## 11. Documentation Gaps

**Issues:**

- No docstrings for many functions (e.g. `init`, `quit`, `was_init`)
- `was_init`’s behavior (None vs Some) is not documented
- No `@raises` or `@deprecated` annotations
- No documented threading assumptions (e.g. SDL’s main-thread requirements)
- No migration notes from TSDL or other bindings

**Recommendation:** Add `(** ... *)` docstrings for public values, document parameters, return values, possible exceptions, threading constraints, and lifecycle (e.g. init/quit ordering).

---

## 12. .gitignore Completeness

**Current:** `.gitignore` contains only `_build/`.

**Recommendation:** Add common OCaml/editor artifacts, for example:

```
_build/
*.swp
*~
.merlin
*.sexp
```

(Adjust `*.sexp` if some sexp files are meant to be tracked.)

---

## 13. DRY: Re-exports

**Location:** `sdl3.ml` module `Sdl`

The `Sdl` module largely re-exports other modules. That’s fine, but the same identifiers appear in both the top-level `sdl3.ml` scope and inside `Sdl`, which can be confusing when browsing the codebase.

**Recommendation:** Prefer a single re-export layer (e.g. only `Sdl`) and avoid duplicating the same bindings at the library root unless there’s a clear reason.

---

## 14. Test Environment Configuration

**Location:** `test/dune`

```ocaml
(env
 (_ (env-vars (SDL_VIDEO_DRIVER dummy) (SDL_AUDIO_DRIVER dummy))))
```

**Issue:** These variables apply to all tests in this directory. If you add tests that need different drivers, this becomes restrictive.

**Recommendation:** Consider applying env vars only to specific tests, or document that all tests in this suite assume a headless/dummy setup and why.

---

## 15. Version Constant Mismatch

**Location:** `sdl3_consts.ml` vs SDL3 headers

Constants like `sdl_window_fullscreen` are hardcoded. If SDL3 changes these values in a future version, the bindings can silently misbehave.

**Recommendation:** Document the SDL3 version these constants match. Consider generating them from SDL headers (e.g. via a small codegen step) or documenting the maintenance process.

---

## 16. FFI Approach: Foreign vs Dune ctypes 0.3 Stub Generation

**Current approach:** Uses `ctypes-foreign` (runtime libffi dispatch) plus two hand-written C stubs for varargs.

**Planned:** Migrate to Dune's ctypes 0.3 FFI (stub generation). This will address §7, §8, and improve performance.

### Two ctypes Modes

| Mode | What sdl3-ocaml uses now | What we're migrating to |
|------|--------------------------|---------------------------|
| **Foreign** | `Foreign.foreign` resolves symbols at runtime via libffi | — |
| **Stub generation (cstubs)** | — | Dune generates C stubs at compile time |
| **Overhead** | ~150–160 ns per call | ~8 ns per call (near hand-written C) |
| **Build flags** | Custom `gen_sdl3_flags.ml` script | Built-in `(build_flags_resolver pkg_config)` |

### Dune ctypes 0.3 Setup

1. **dune-project:** `(using ctypes 0.3)`

2. **Type description** — C types and constants as a functor:
   ```ocaml
   module Types (F : Ctypes.TYPE) = struct
     open F
     let sdl_init_video = constant "SDL_INIT_VIDEO" uint32_t
     (* structs, enums, etc. *)
   end
   ```

3. **Function description** — C functions as a functor:
   ```ocaml
   module Types = Types_generated
   module Functions (F : Ctypes.FOREIGN) = struct
     open F
     let sdl_init = foreign "SDL_Init" (uint32_t @-> returning bool)
   end
   ```

4. **Dune stanza** — wires it up; `pkg_config` replaces `gen_sdl3_flags.ml`:
   ```lisp
   (ctypes
    (external_library_name sdl3)
    (build_flags_resolver pkg_config)
    (headers (include "SDL3/SDL.h"))
    (type_description ...)
    (function_description ...))
   ```

### Migration Notes for SDL3

- **Varargs:** `SDL_SetError`, `SDL_LogMessage` use printf-style varargs. ctypes doesn't support varargs; keep `sdl3_stubs.c` for those (or equivalent wrappers).
- **Constants:** Replace `sdl3_consts.ml` with `constant "SDL_*" ...` in the Types functor, reading from headers where possible.
- **Opaque pointers:** `SDL_Window*` as `ptr void` or abstract pointer types works in both approaches.
- **gen_sdl3_flags.ml:** Obsolete after migration; Dune calls pkg-config directly.

### Status

Dune's ctypes support is still experimental. Docs: [Dealing with Foreign Libraries](https://dune.readthedocs.io/en/stable/foreign-code.html); [tutorial](https://michael.bacarella.com/2022/02/19/dune-ctypes/). Nevertheless, we'll adopt it.
