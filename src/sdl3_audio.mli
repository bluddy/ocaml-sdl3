(** SDL3 audio: low-level stream API.

    Buffers use [Bigarray.Array1.t] with [int8_unsigned] and [c_layout] for
    zero-copy C access. Allocate with [Bigarray.Array1.create Bigarray.int8_unsigned
    Bigarray.c_layout len].

    Call [Sdl3.init [ Sdl3.Init.audio ]] before using audio.
    Device starts paused; call [resume_audio_stream_device] to start playback.
*)

type stream
(** Opaque audio stream handle. *)

type buffer = (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
(** Byte buffer; [Array1.dim b] is length in bytes. *)

type spec = {
  format : int;
  channels : int;
  freq : int;
}

module Device : sig
  val default_playback : int32
  (** SDL sentinel for default playback device (0xFFFFFFFFl). *)

  val default_recording : int32
  (** SDL sentinel for default recording device (0xFFFFFFFEl). *)
end

val get_playback_devices : unit -> int32 list
val get_recording_devices : unit -> int32 list
val get_device_name : int32 -> string option
val get_device_format : int32 -> spec * int
(** [get_device_format id] returns the device's native spec and recommended sample frames. *)

module Format : sig
  val s8 : int
  val u8 : int
  val s16 : int
  val s16_le : int
  val s16_be : int
  val s32 : int
  val s32_le : int
  val s32_be : int
  val f32 : int
  val f32_le : int
  val f32_be : int
end

val open_audio_device_stream :
  device_id:int32 ->
  format:int ->
  channels:int ->
  freq:int ->
  ?callback:(stream -> additional_amount:int -> total_amount:int -> unit) ->
  unit ->
  stream

val put_audio_stream_data : stream -> buffer -> pos:int -> len:int -> unit
(** Push model: copies buffer into stream. Use for small to medium files. *)

val put_audio_stream_data_no_copy :
  stream -> buffer -> pos:int -> len:int -> unit
(** Zero-copy push. Buffer must remain valid until SDL consumes it. *)

val get_audio_stream_data : stream -> buffer -> pos:int -> len:int -> int
(** Returns bytes read. *)

val get_audio_stream_available : stream -> int
val get_audio_stream_queued : stream -> int

val flush_audio_stream : stream -> unit
val clear_audio_stream : stream -> unit
val destroy_audio_stream : stream -> unit

val pause_audio_stream_device : stream -> unit
val resume_audio_stream_device : stream -> unit
val audio_stream_device_paused : stream -> bool

val set_audio_stream_get_callback :
  stream ->
  (stream -> additional_amount:int -> total_amount:int -> unit) option ->
  unit
(** Pull model: when SDL requests data, callback runs. Read next chunk and call
    [put_audio_stream_data] from inside. Necessary for streaming large files. *)

val set_audio_stream_put_callback :
  stream ->
  (stream -> additional_amount:int -> total_amount:int -> unit) option ->
  unit
(** When data is added (push), callback runs. User can call [get_audio_stream_data]
    from inside. *)
