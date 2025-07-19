package clibrary_example

import clibrary.*

main(): Int64 {
    println("clibrary example")

    @When[os == "Windows"]
    const libName = "libclib.dll"

    @When[os == "Linux"]
    const libName = "libclib.so"

    @When[os == "macOS"]
    const libName = "libclib.dylib"

    if (let Some(clib) <- CLibrary.load(libName)) {
        println("clib loaded successfully")
        if (let Some(cFuncPtr) <- clib.get("add_numbers")) {
            let add_numbers = CFunc<(a: Int64, b: Int64, c: Int32, d: Float32) -> Float64>(cFuncPtr)
            var result = unsafe { add_numbers(123, 456, -4, 1.5) }
            println("add_numbers(123, 456, -4, 1.5) = ${result}")
            result = unsafe { add_numbers(9999, 99999999, -12, 0.5) }
            println("add_numbers(9999, 99999999, -12, 0.5) = ${result}")
        }
    } else {
        println("failed to load clib")
    }
    return 0
}
