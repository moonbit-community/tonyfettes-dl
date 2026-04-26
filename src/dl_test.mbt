///|
fn open_libm() -> DynamicLibrary raise DynamicLibraryError {
  match DynamicLibrary::try_open("libm.so.6") {
    Some(lib) => lib
    None =>
      match DynamicLibrary::try_open("libm.dylib") {
        Some(lib) => lib
        None => DynamicLibrary::open("libm.so")
      }
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
