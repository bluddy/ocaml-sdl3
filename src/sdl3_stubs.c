#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>
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

/* Return pointer address as int64 for passing to sdl3_bigarray_of_ptr. */
int64_t sdl3_ptr_addr(void *p)
{
  return (int64_t)(uintptr_t)p;
}

/* Wrap a C pointer as a Bigarray.Array1 (int8_unsigned, c_layout).
   The memory must remain valid until the bigarray is no longer used. */
CAMLprim value sdl3_bigarray_of_ptr(value addr_val, value size_val)
{
  CAMLparam2(addr_val, size_val);
  void *ptr = (void *)(uintptr_t)Nativeint_val(addr_val);
  intnat size = Int_val(size_val);
  intnat dim = size;
  CAMLreturn(caml_ba_alloc(CAML_BA_UINT8 | CAML_BA_C_LAYOUT | CAML_BA_EXTERNAL,
                           1, ptr, &dim));
}
