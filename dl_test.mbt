///|
#cfg(not(platform="windows"))
fn open_libm() -> DynamicLibrary raise DynamicLibraryError {
  if DynamicLibrary::try_open("libm.so.6") is Some(lib) {
    lib
  } else if DynamicLibrary::try_open("libm.dylib") is Some(lib) {
    lib
  } else {
    DynamicLibrary::open("libm.so")
  }
}

///|
#cfg(platform="windows")
fn open_libm() -> DynamicLibrary raise DynamicLibraryError {
  if DynamicLibrary::try_open("ucrtbase.dll") is Some(lib) {
    lib
  } else {
    DynamicLibrary::open("msvcrt.dll")
  }
}

///|
test "DynamicLibrary::funcref" {
  let lib = open_libm()
  let cos_ptr : @c.Pointer[Unit] = lib.symbol("cos")
  let cos_fn : FuncRef[(Double) -> Double] = cos_ptr.unsafe_into()
  inspect(
    cos_fn(0.0),
    content=(
      #|1
    ),
  )
  let cos_fn : FuncRef[(Double) -> Double] = lib.funcref("cos")
  inspect(
    cos_fn(0.0),
    content=(
      #|1
    ),
  )
  lib.close()
}
