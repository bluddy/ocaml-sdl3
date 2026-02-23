(** SDL3 audio: low-level stream API with Bigarray buffers. *)

open Ctypes
open Foreign
open Sdl3_consts

type stream = unit ptr
type buffer =
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

let stream_of_ptr (p : unit ptr) : stream = p
let ptr_of_stream (s : stream) : unit ptr = s

(* SDL_AudioSpec - internal, not exposed *)
let audio_spec = structure "SDL_AudioSpec"
let audio_spec_format = field audio_spec "format" uint32_t
let audio_spec_channels = field audio_spec "channels" Ctypes.int
let audio_spec_freq = field audio_spec "freq" Ctypes.int
let () = seal audio_spec

let make_spec ~format ~channels ~freq =
  let spec = make audio_spec in
  setf spec audio_spec_format (Unsigned.UInt32.of_int format);
  setf spec audio_spec_channels channels;
  setf spec audio_spec_freq freq;
  spec

(* Stream callback: userdata, stream, additional_amount, total_amount -> void.
   C invokes from SDL audio thread: need runtime_lock and thread_registration *)
let audio_stream_callback =
  Foreign.funptr_opt
    ~runtime_lock:true
    ~thread_registration:true
    (ptr void @-> ptr void @-> int @-> int @-> returning void)

let sdl_open_audio_device_stream =
  foreign "SDL_OpenAudioDeviceStream"
    (uint32_t @-> ptr audio_spec @-> audio_stream_callback @-> ptr void
    @-> returning (ptr void))

let sdl_put_audio_stream_data =
  foreign "SDL_PutAudioStreamData"
    (ptr void @-> ptr void @-> int @-> returning bool)

let sdl_put_audio_stream_data_no_copy =
  foreign "SDL_PutAudioStreamDataNoCopy"
    (ptr void @-> ptr void @-> int @-> ptr void @-> ptr void @-> returning bool)

let sdl_get_audio_stream_data =
  foreign "SDL_GetAudioStreamData"
    (ptr void @-> ptr void @-> int @-> returning int)

let sdl_get_audio_stream_available =
  foreign "SDL_GetAudioStreamAvailable" (ptr void @-> returning int)

let sdl_get_audio_stream_queued =
  foreign "SDL_GetAudioStreamQueued" (ptr void @-> returning int)

let sdl_flush_audio_stream =
  foreign "SDL_FlushAudioStream" (ptr void @-> returning bool)

let sdl_clear_audio_stream =
  foreign "SDL_ClearAudioStream" (ptr void @-> returning bool)

let sdl_destroy_audio_stream =
  foreign "SDL_DestroyAudioStream" (ptr void @-> returning void)

let sdl_pause_audio_stream_device =
  foreign "SDL_PauseAudioStreamDevice" (ptr void @-> returning bool)

let sdl_resume_audio_stream_device =
  foreign "SDL_ResumeAudioStreamDevice" (ptr void @-> returning bool)

let sdl_audio_stream_device_paused =
  foreign "SDL_AudioStreamDevicePaused" (ptr void @-> returning bool)

let sdl_set_audio_stream_get_callback =
  foreign "SDL_SetAudioStreamGetCallback"
    (ptr void @-> audio_stream_callback @-> ptr void @-> returning bool)

let sdl_set_audio_stream_put_callback =
  foreign "SDL_SetAudioStreamPutCallback"
    (ptr void @-> audio_stream_callback @-> ptr void @-> returning bool)

let raise_on_false f =
  if not (f ()) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let wrap_stream_callback cb =
  match cb with
  | None -> None
  | Some f ->
      Some
        (fun _userdata stream additional total ->
          f (stream_of_ptr (from_voidp void stream))
            ~additional_amount:additional ~total_amount:total;
          ())

let buf_ptr ?(pos = 0) buffer =
  let ptr = bigarray_start array1 buffer in
  to_voidp (ptr +@ pos)

(* --- Public API --- *)

let open_audio_device_stream ~device_id ~format ~channels ~freq ?callback () =
  let spec = make_spec ~format ~channels ~freq in
  let cb = wrap_stream_callback callback in
  let stream =
    sdl_open_audio_device_stream
      (Unsigned.UInt32.of_int32 device_id)
      (addr spec) cb null
  in
  if is_null stream then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  stream_of_ptr stream

let put_audio_stream_data stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  if not (sdl_put_audio_stream_data (ptr_of_stream stream) buf len) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let put_audio_stream_data_no_copy stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  if not
       (sdl_put_audio_stream_data_no_copy
          (ptr_of_stream stream)
          buf
          len
          null
          null)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let get_audio_stream_data stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  let n = sdl_get_audio_stream_data (ptr_of_stream stream) buf len in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let get_audio_stream_available stream =
  let n = sdl_get_audio_stream_available (ptr_of_stream stream) in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let get_audio_stream_queued stream =
  let n = sdl_get_audio_stream_queued (ptr_of_stream stream) in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let flush_audio_stream stream =
  raise_on_false (fun () ->
      sdl_flush_audio_stream (ptr_of_stream stream))

let clear_audio_stream stream =
  raise_on_false (fun () -> sdl_clear_audio_stream (ptr_of_stream stream))

let destroy_audio_stream stream =
  sdl_destroy_audio_stream (ptr_of_stream stream)

let pause_audio_stream_device stream =
  raise_on_false (fun () ->
      sdl_pause_audio_stream_device (ptr_of_stream stream))

let resume_audio_stream_device stream =
  raise_on_false (fun () ->
      sdl_resume_audio_stream_device (ptr_of_stream stream))

let audio_stream_device_paused stream =
  sdl_audio_stream_device_paused (ptr_of_stream stream)

let set_audio_stream_get_callback stream cb =
  raise_on_false (fun () ->
      sdl_set_audio_stream_get_callback (ptr_of_stream stream)
        (wrap_stream_callback cb)
        null)

let set_audio_stream_put_callback stream cb =
  raise_on_false (fun () ->
      sdl_set_audio_stream_put_callback (ptr_of_stream stream)
        (wrap_stream_callback cb)
        null)

module Device = struct
  let default_playback = sdl_audio_device_default_playback
  let default_recording = sdl_audio_device_default_recording
end

module Format = struct
  let s8 = sdl_audio_s8
  let u8 = sdl_audio_u8
  let s16 = sdl_audio_s16
  let s16_le = sdl_audio_s16le
  let s16_be = sdl_audio_s16be
  let s32 = sdl_audio_s32
  let s32_le = sdl_audio_s32le
  let s32_be = sdl_audio_s32be
  let f32 = sdl_audio_f32
  let f32_le = sdl_audio_f32le
  let f32_be = sdl_audio_f32be
end
