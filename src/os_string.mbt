///|
#cfg(platform="windows")
priv struct OsString(String)

///|
#cfg(not(platform="windows"))
priv struct OsString(Bytes)

///|
#cfg(platform="windows")
fn OsString::from_string(path : String) -> OsString {
  OsString(path)
}

///|
#cfg(not(platform="windows"))
fn OsString::from_string(path : String) -> OsString {
  OsString(@encoding/utf8.encode(path))
}
