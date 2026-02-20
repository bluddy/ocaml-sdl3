#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

CAMLprim value sdl3_event_size(value unit)
{
  CAMLparam1(unit);
  CAMLreturn(Val_int((int)sizeof(SDL_Event)));
}

CAMLprim value sdl3_set_error_stub(value msg)
{
  CAMLparam1(msg);
  SDL_SetError("%s", String_val(msg));
  CAMLreturn(Val_unit);
}

CAMLprim value sdl3_log_message_stub(value category, value priority, value msg)
{
  CAMLparam3(category, priority, msg);
  SDL_LogMessage(Int_val(category), Int_val(priority), "%s", String_val(msg));
  CAMLreturn(Val_unit);
}
