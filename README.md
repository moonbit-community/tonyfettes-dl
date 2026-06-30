# tonyfettes/dl

Dynamic/shared library loading for MoonBit native targets.

## Features

- Open shared libraries at runtime
- Resolve symbols as raw pointers or typed `FuncRef`s
- Error-aware APIs (`open`, `symbol`, `funcref`, `close`) and optional APIs (`try_*`)

## Installation

```bash
moon add tonyfettes/dl
```

Add this package to your `moon.pkg.json`:

```json
{
  "import": [
    "tonyfettes/dl"
  ]
}
```

## Quick Start

```moonbit
fn cosine_zero() -> Double raise @dl.DynamicLibraryError {
  // Linux: "libm.so.6" (or the platform's libm soname)
  // macOS: "libm.dylib"
  // Windows: "ucrtbase.dll" or another DLL
  let lib = @dl.DynamicLibrary::open("libm.dylib")
  let cos_fn : FuncRef[(Double) -> Double] = lib.funcref("cos")
  let out = cos_fn(0.0)
  lib.close()
  out
}
```

If you prefer non-raising control flow:

```moonbit
fn cosine_zero_safe() -> Double? {
  match @dl.DynamicLibrary::try_open("libm.dylib") {
    None => None
    Some(lib) => {
      let out = match lib.try_funcref("cos") {
        None => None
        Some(cos_fn) => Some((cos_fn : FuncRef[(Double) -> Double])(0.0))
      }
      ignore(try? lib.close())
      out
    }
  }
}
```

## API Overview

### Constants

- `RTLD_LAZY : Int`
- `RTLD_NOW : Int`

### Type

- `DynamicLibrary`

### Methods

| Method | Description |
|--------|-------------|
| `DynamicLibrary::open(path)` | Open a dynamic library; raises `DynamicLibraryError` on failure |
| `DynamicLibrary::try_open(path)` | Open a dynamic library; returns `None` on failure |
| `DynamicLibrary::symbol(symbol)` | Resolve a symbol as `@c.Pointer[Unit]`; raises on failure |
| `DynamicLibrary::try_symbol(symbol)` | Resolve a symbol as pointer; returns `None` on failure |
| `DynamicLibrary::funcref(symbol)` | Resolve a symbol as typed `FuncRef[T]`; raises on failure |
| `DynamicLibrary::try_funcref(symbol)` | Resolve a symbol as typed `FuncRef[T]`; returns `None` on failure |
| `DynamicLibrary::close()` | Close the library handle; raises on failure |

## Error Type

- `DynamicLibraryError(String)` with `Show` derived

## Notes

- This package is for native targets and uses the platform dynamic loader.
- Symbol names and library filenames are platform-specific.
- The function signature used with `FuncRef[T]` must exactly match the native symbol signature.
- Keep the library open while using pointers/function refs resolved from it.

## License

Apache-2.0
