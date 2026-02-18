#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <string.h>

#define SDL_EVENT_SIZE 128

CAMLprim value sdl3_poll_event_stub(value buf)
{
  CAMLparam1(buf);
  SDL_Event event;
  if (SDL_PollEvent(&event)) {
    memcpy((char *)String_val(buf), &event, SDL_EVENT_SIZE);
    CAMLreturn(Val_true);
  }
  CAMLreturn(Val_false);
}

CAMLprim value sdl3_wait_event_stub(value buf)
{
  CAMLparam1(buf);
  SDL_Event event;
  if (SDL_WaitEvent(&event)) {
    memcpy((char *)String_val(buf), &event, SDL_EVENT_SIZE);
    CAMLreturn(Val_true);
  }
  CAMLreturn(Val_false);
}

CAMLprim value sdl3_get_window_from_event_stub(value buf)
{
  CAMLparam1(buf);
  SDL_Window *w = SDL_GetWindowFromEvent((const SDL_Event *)String_val(buf));
  CAMLreturn(caml_copy_nativeint(w ? (intnat)w : 0));
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
