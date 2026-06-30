#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <wchar.h>
#else
#include <dlfcn.h>
#include <string.h>
#endif

#include <moonbit.h>

#ifndef _WIN32
static moonbit_bytes_t moonbit_dl_bytes(const char *src, int32_t len) {
  moonbit_bytes_t dst = moonbit_make_bytes(len, 0);
  if (len > 0) {
    memcpy(dst, src, (size_t)len);
  }
  return dst;
}
#endif

#ifdef _WIN32
static moonbit_string_t moonbit_dl_string_from_wide(const wchar_t *src,
                                                    int32_t len) {
  moonbit_string_t dst = moonbit_make_string(len, 0);
  if (len > 0) {
    memcpy(dst, src, sizeof(uint16_t) * (size_t)len);
  }
  return dst;
}

static moonbit_string_t moonbit_dl_windows_error() {
  DWORD error = GetLastError();
  if (error == 0) {
    return moonbit_dl_string_from_wide(L"", 0);
  }

  wchar_t *wide = NULL;
  DWORD len = FormatMessageW(
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
          FORMAT_MESSAGE_IGNORE_INSERTS,
      NULL, error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR)&wide, 0,
      NULL);
  if (len == 0) {
    wchar_t fallback[64];
    int fallback_len =
        swprintf(fallback, 64, L"Windows error %lu", (unsigned long)error);
    if (fallback_len < 0) {
      return moonbit_dl_string_from_wide(L"Windows error", 13);
    }
    return moonbit_dl_string_from_wide(fallback, fallback_len);
  }

  while (len > 0 && (wide[len - 1] == L'\r' || wide[len - 1] == L'\n')) {
    len--;
  }

  moonbit_string_t dst = moonbit_dl_string_from_wide(wide, (int32_t)len);
  LocalFree(wide);
  return dst;
}
#endif

MOONBIT_FFI_EXPORT
void *
moonbit_dlopen(void *path, int32_t flags) {
#ifdef _WIN32
  (void)flags;
  return (void *)LoadLibraryW((LPCWSTR)path);
#else
  return dlopen((const char *)path, flags);
#endif
}

MOONBIT_FFI_EXPORT
void *
moonbit_dlsym(void *handle, moonbit_bytes_t symbol) {
#ifdef _WIN32
  return (void *)GetProcAddress((HMODULE)handle, (const char *)symbol);
#else
  return dlsym(handle, (const char *)symbol);
#endif
}

MOONBIT_FFI_EXPORT
#ifdef _WIN32
moonbit_string_t
#else
moonbit_bytes_t
#endif
moonbit_dlerror() {
#ifdef _WIN32
  return moonbit_dl_windows_error();
#else
  const char *src = dlerror();
  if (src == NULL) {
    return moonbit_dl_bytes("", 0);
  }
  return moonbit_dl_bytes(src, (int32_t)strlen(src));
#endif
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_dlclose(void *handle) {
#ifdef _WIN32
  return FreeLibrary((HMODULE)handle) ? 0 : 1;
#else
  return dlclose(handle);
#endif
}
