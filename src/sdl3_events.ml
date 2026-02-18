(** SDL3 event queue. *)

open Ctypes
open Sdl3_consts

(** Event buffer (128 bytes, opaque). Type is stored in first 4 bytes (little-endian). *)
type t = bytes

let event_size = 128

external poll_event_stub : bytes -> bool = "sdl3_poll_event_stub"
external wait_event_stub : bytes -> bool = "sdl3_wait_event_stub"
external get_window_from_event_stub : bytes -> nativeint = "sdl3_get_window_from_event_stub"

let get_type buf =
  assert (Bytes.length buf >= 4);
  let b0 = int_of_char (Bytes.get buf 0) in
  let b1 = int_of_char (Bytes.get buf 1) in
  let b2 = int_of_char (Bytes.get buf 2) in
  let b3 = int_of_char (Bytes.get buf 3) in
  b0 lor (b1 lsl 8) lor (b2 lsl 16) lor (b3 lsl 24)

let poll_event () =
  let buf = Bytes.create event_size in
  if poll_event_stub buf then Some buf else None

let wait_event () =
  let buf = Bytes.create event_size in
  if wait_event_stub buf then buf else raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let get_window_from_event (buf : t) : Sdl3_video.window option =
  let ptr = get_window_from_event_stub buf in
  if ptr = 0n then None else Some (Sdl3_video.window_of_ptr (ptr_of_raw_address ptr))

module Type = struct
  let quit = sdl_event_quit
  let window_close_requested = sdl_event_window_close_requested
end
