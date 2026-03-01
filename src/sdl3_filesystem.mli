(** SDL3 Filesystem API. *)

val get_base_path : unit -> string option
(** [get_base_path ()] returns the directory where the application is run from. *)

val get_pref_path : org:string -> app:string -> string option
(** [get_pref_path ~org ~app] returns the writeable directory for application data. *)
