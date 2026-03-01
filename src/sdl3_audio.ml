open Ctypes
open Foreign
open Sdl3_consts
open Sdl3_internal

type ba = (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
type buffer = ba

type stream = {
  ptr : Sdl3_internal.stream;
  source : [ `None | `Bigarray of ba ];
}

let stream_of_ptr (p : Sdl3_internal.stream) : stream = { ptr = p; source = `None }

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

type spec = {
  format : int;
  channels : int;
  freq : int;
}

let spec_of_c s = {
  format = Unsigned.UInt32.to_int (getf s audio_spec_format);
  channels = getf s audio_spec_channels;
  freq = getf s audio_spec_freq;
}

(* Stream callback: userdata, stream, additional_amount, total_amount -> void. *)
let audio_stream_callback =
  Foreign.funptr_opt
    ~runtime_lock:true
    ~thread_registration:true
    (ptr void @-> ptr stream_tag @-> int @-> int @-> returning void)

let sdl_open_audio_device_stream =
  foreign "SDL_OpenAudioDeviceStream"
    (uint32_t @-> ptr audio_spec @-> audio_stream_callback @-> ptr void
    @-> returning (ptr stream_tag))

let sdl_put_audio_stream_data =
  foreign "SDL_PutAudioStreamData"
    (ptr stream_tag @-> ptr void @-> int @-> returning bool)

let sdl_put_audio_stream_data_no_copy =
  foreign "SDL_PutAudioStreamDataNoCopy"
    (ptr stream_tag @-> ptr void @-> int @-> ptr void @-> ptr void @-> returning bool)

let sdl_get_audio_stream_data =
  foreign "SDL_GetAudioStreamData"
    (ptr stream_tag @-> ptr void @-> int @-> returning int)

let sdl_get_audio_stream_available =
  foreign "SDL_GetAudioStreamAvailable" (ptr stream_tag @-> returning int)

let sdl_get_audio_stream_queued =
  foreign "SDL_GetAudioStreamQueued" (ptr stream_tag @-> returning int)

let sdl_flush_audio_stream =
  foreign "SDL_FlushAudioStream" (ptr stream_tag @-> returning bool)

let sdl_clear_audio_stream =
  foreign "SDL_ClearAudioStream" (ptr stream_tag @-> returning bool)

let sdl_destroy_audio_stream =
  foreign "SDL_DestroyAudioStream" (ptr stream_tag @-> returning void)

let sdl_pause_audio_stream_device =
  foreign "SDL_PauseAudioStreamDevice" (ptr stream_tag @-> returning bool)

let sdl_resume_audio_stream_device =
  foreign "SDL_ResumeAudioStreamDevice" (ptr stream_tag @-> returning bool)

let sdl_audio_stream_device_paused =
  foreign "SDL_AudioStreamDevicePaused" (ptr stream_tag @-> returning bool)

let sdl_set_audio_stream_get_callback =
  foreign "SDL_SetAudioStreamGetCallback"
    (ptr stream_tag @-> audio_stream_callback @-> ptr void @-> returning bool)

let sdl_set_audio_stream_put_callback =
  foreign "SDL_SetAudioStreamPutCallback"
    (ptr stream_tag @-> audio_stream_callback @-> ptr void @-> returning bool)

let raise_on_false f =
  if not (f ()) then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let wrap_stream_callback cb =
  match cb with
  | None -> None
  | Some f ->
      Some
        (fun _userdata stream additional total ->
          f (stream_of_ptr stream)
            ~additional_amount:additional ~total_amount:total;
          ())

let buf_ptr ?(pos = 0) buffer =
  let ptr = bigarray_start array1 buffer in
  to_voidp (ptr +@ pos)

(* --- Devices --- *)

let sdl_get_audio_playback_devices = foreign "SDL_GetAudioPlaybackDevices" (ptr int @-> returning (ptr uint32_t))
let sdl_get_audio_recording_devices = foreign "SDL_GetAudioRecordingDevices" (ptr int @-> returning (ptr uint32_t))

let get_devices f =
  let count = allocate int 0 in
  let arr = f count in
  if is_null arr then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  let n = !@ count in
  let ids = List.init n (fun i -> Unsigned.UInt32.to_int32 (CArray.get (CArray.from_ptr arr n) i)) in
  sdl_free (to_voidp arr);
  ids

let get_playback_devices () = get_devices sdl_get_audio_playback_devices
let get_recording_devices () = get_devices sdl_get_audio_recording_devices

let sdl_get_audio_device_name = foreign "SDL_GetAudioDeviceName" (uint32_t @-> returning string_opt)
let get_device_name id = sdl_get_audio_device_name (Unsigned.UInt32.of_int32 id)

let sdl_get_audio_device_format = foreign "SDL_GetAudioDeviceFormat" (uint32_t @-> ptr audio_spec @-> ptr int @-> returning bool)
let get_device_format id =
  let spec = make audio_spec in
  let sample_frames = allocate int 0 in
  if not (sdl_get_audio_device_format (Unsigned.UInt32.of_int32 id) (addr spec) sample_frames) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  (spec_of_c spec, !@ sample_frames)

(* --- Public API --- *)

let destroy_audio_stream s =
  sdl_destroy_audio_stream s.ptr

let adopt_ ptr source =
  let s = { ptr; source } in
  Gc.finalise destroy_audio_stream s;
  s

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
  adopt_ stream `None

let put_audio_stream_data stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  if not (sdl_put_audio_stream_data stream.ptr buf len) then
    raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let put_audio_stream_data_no_copy stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  if not
       (sdl_put_audio_stream_data_no_copy
          stream.ptr
          buf
          len
          null
          null)
  then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()))

let get_audio_stream_data stream buffer ~pos ~len =
  let buf = buf_ptr ~pos buffer in
  let n = sdl_get_audio_stream_data stream.ptr buf len in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let get_audio_stream_available stream =
  let n = sdl_get_audio_stream_available stream.ptr in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let get_audio_stream_queued stream =
  let n = sdl_get_audio_stream_queued stream.ptr in
  if n < 0 then raise (Sdl3_error.Sdl_error (Sdl3_error.get_error ()));
  n

let flush_audio_stream stream =
  raise_on_false (fun () ->
      sdl_flush_audio_stream stream.ptr)

let clear_audio_stream stream =
  raise_on_false (fun () -> sdl_clear_audio_stream stream.ptr)

let pause_audio_stream_device stream =
  raise_on_false (fun () ->
      sdl_pause_audio_stream_device stream.ptr)

let resume_audio_stream_device stream =
  raise_on_false (fun () ->
      sdl_resume_audio_stream_device stream.ptr)

let audio_stream_device_paused stream =
  sdl_audio_stream_device_paused stream.ptr

let set_audio_stream_get_callback stream cb =
  raise_on_false (fun () ->
      sdl_set_audio_stream_get_callback stream.ptr
        (wrap_stream_callback cb)
        null)

let set_audio_stream_put_callback stream cb =
  raise_on_false (fun () ->
      sdl_set_audio_stream_put_callback stream.ptr
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
