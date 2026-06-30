///|
struct DynamicLibrary(@c.Pointer[Unit])

///|
suberror DynamicLibraryError {
  DynamicLibraryError(String)
} derive(Debug)

///|
#borrow(path)
extern "c" fn dlopen(path : OsString, flags : Int) -> @c.Pointer[Unit] = "moonbit_dlopen"

///|
#borrow(symbol)
extern "c" fn dlsym(
  handle : @c.Pointer[Unit],
  symbol : Bytes,
) -> @c.Pointer[Unit] = "moonbit_dlsym"

///|
extern "c" fn dlclose(handle : @c.Pointer[Unit]) -> Int = "moonbit_dlclose"

///|
#cfg(platform="windows")
extern "c" fn dlerror() -> String = "moonbit_dlerror"

///|
#cfg(not(platform="windows"))
extern "c" fn dlerror() -> Bytes = "moonbit_dlerror"

///|
#cfg(platform="windows")
fn dlerror_as_string() -> String {
  dlerror()
}

///|
#cfg(not(platform="windows"))
fn dlerror_as_string() -> String {
  @encoding/utf8.decode_lossy(dlerror())
}

///|
pub const RTLD_LAZY = 0x1

///|
pub const RTLD_NOW = 0x2

///|
#as_free_fn(open)
pub fn DynamicLibrary::open(
  path : String,
) -> DynamicLibrary raise DynamicLibraryError {
  let handle = dlopen(OsString::from_string(path), RTLD_LAZY)
  if handle.is_null() {
    raise DynamicLibraryError(dlerror_as_string())
  }
  DynamicLibrary(handle)
}

///|
pub fn DynamicLibrary::try_open(path : String) -> DynamicLibrary? {
  let handle = dlopen(OsString::from_string(path), RTLD_LAZY)
  if handle.is_null() {
    return None
  }
  Some(DynamicLibrary(handle))
}

///|
pub fn DynamicLibrary::symbol(
  self : DynamicLibrary,
  symbol : String,
) -> @c.Pointer[Unit] raise DynamicLibraryError {
  let ptr = dlsym(self.0, @encoding/utf8.encode(symbol))
  if ptr.is_null() {
    raise DynamicLibraryError(dlerror_as_string())
  }
  ptr
}

///|
pub fn DynamicLibrary::unsafe_symbol(
  self : DynamicLibrary,
  symbol : String,
) -> @c.Pointer[Unit] {
  dlsym(self.0, @encoding/utf8.encode(symbol))
}

///|
pub fn[T] DynamicLibrary::funcref(
  self : DynamicLibrary,
  symbol : String,
) -> FuncRef[T] raise DynamicLibraryError {
  let ptr = self.symbol(symbol)
  ptr.unsafe_into()
}

///|
pub fn[T] DynamicLibrary::unsafe_funcref(
  self : DynamicLibrary,
  symbol : String,
) -> FuncRef[T] {
  self.unsafe_symbol(symbol).unsafe_into()
}

///|
pub fn DynamicLibrary::try_symbol(
  self : DynamicLibrary,
  symbol : String,
) -> @c.Pointer[Unit]? {
  let ptr = dlsym(self.0, @encoding/utf8.encode(symbol))
  if ptr.is_null() {
    return None
  }
  Some(ptr)
}

///|
pub fn[T] DynamicLibrary::try_funcref(
  self : DynamicLibrary,
  symbol : String,
) -> FuncRef[T]? {
  match self.try_symbol(symbol) {
    None => None
    Some(ptr) => Some(ptr.unsafe_into())
  }
}

///|
pub fn DynamicLibrary::close(
  self : DynamicLibrary,
) -> Unit raise DynamicLibraryError {
  if dlclose(self.0) != 0 {
    raise DynamicLibraryError(dlerror_as_string())
  }
}
