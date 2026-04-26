#include <dlfcn.h>
#include <moonbit.h>
#include <string.h>

MOONBIT_FFI_EXPORT
void *
moonbit_dlopen(moonbit_bytes_t path, int32_t flags) {
  return dlopen((const char *)path, flags);
}

MOONBIT_FFI_EXPORT
void *
moonbit_dlsym(void *handle, moonbit_bytes_t symbol) {
  return dlsym(handle, (const char *)symbol);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_dlerror() {
  const char *src = dlerror();
  size_t len = strlen(src);
  moonbit_bytes_t dst = moonbit_make_bytes(len, 0);
  memcpy(dst, src, len);
  return dst;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_dlclose(void *handle) {
  return dlclose(handle);
}
