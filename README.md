# clibrary

clibrary is a cangjie package that loads C dynamic libraries (.dll, .dylib, .so).
Only `cdecl` functions are supported (Windows API libraries use `stdcall`)

## Examples

### Load library, get function and call it

```
@When[os == "Windows"]
const libName = "libadd.dll"
@When[os == "Linux"]
const libName = "libadd.so"
@When[os == "macOS"]
const libName = "libadd.dylib"

if (let Some(clib) <- CLibrary.load(libName)) {
    if (let Some(cFuncPtr) <- clib.get("add")) {
        let add = CFunc<(Int64, Int64) -> Int64>(cFuncPtr)
        let result = unsafe { add(2, 3) }
        println("add(2, 3) = ${result}")
    }
}
```

## License

MIT No Attribution
