(** SDL3 audio: low-level stream API.

    Buffers use [Bigarray.Array1.t] with [int8_unsigned] and [c_layout] for
    zero-copy C access. Allocate with [Bigarray.Array1.create Bigarray.int8_unsigned
    Bigarray.c_layout len].

    Call [Sdl3.init Sdl3.Init.audio] before using audio.
    Device starts paused; call [resume_audio_stream_device] to start playback.

    {2 Default workflow: push with copy}

    Prefer [put_audio_stream_data]: it copies your buffer into SDL's queue.
    Allocate buffers, fill them, push; SDL owns the copy. Simple and safe.

    {2 Avoid [on_complete]}

    Do not use [on_complete] in [put_audio_stream_data_no_copy]. The OCaml
    callback cannot be guaranteed to outlive SDL's async use of the buffer;
    the funptr may be collected before SDL calls it. Use [put_audio_stream_data]
    instead, or ensure the buffer stays alive until the stream is destroyed or
    cleared (without relying on [on_complete]).

    {2 Callbacks from C}

    [set_audio_stream_get_callback] and [set_audio_stream_put_callback] run from
    SDL's audio thread. Avoid allocating or blocking; use pre-allocated Bigarrays. *)

type stream
(** Opaque audio stream handle. *)

type buffer = (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
(** Byte buffer; [Array1.dim b] is length in bytes. *)

module Device : sig
  val default_playback : int32
  val default_recording : int32
end

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
(** Preferred: copies buffer into stream. No lifetime concerns. *)


val put_audio_stream_data_no_copy :
  stream ->
  buffer ->
  pos:int ->
  len:int ->
  ?on_complete:(unit -> unit) ->
  unit ->
  unit
(** Zero-copy push. Buffer must remain valid until SDL consumes it (stream
    destroyed or cleared). {b Do not use [on_complete]}: the OCaml callback
    may be collected before SDL invokes it. Prefer [put_audio_stream_data]. *)

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
(** When data is requested (pull), callback runs. User typically calls
    [put_audio_stream_data] from inside. *)

val set_audio_stream_put_callback :
  stream ->
  (stream -> additional_amount:int -> total_amount:int -> unit) option ->
  unit
(** When data is added (push), callback runs. User can call [get_audio_stream_data]
    from inside. *)
