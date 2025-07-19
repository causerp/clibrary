package clibrary.test

import clibrary.*
import std.unittest.*

@When[os == "Windows"]
private const validCLib = "opengl32.dll"
@When[os == "Linux"]
private const validCLib = "libGL.so"
@When[os == "macOS"]
private const validCLib = "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"

@Test
class TestInvalidLib {
    @TestCase
    func init_invalid_library() {
        @ExpectThrows[CLibraryException](CLibrary("invalid_lib_name.so"))
    }

    @TestCase
    func load_invalid_library() {
        @Expect(CLibrary.load("invalid_lib_name.so").isNone(), true)
    }
}

@Test
class TestValidLib {
    @TestCase
    func init_valid_library() {
        try (clib = CLibrary(validCLib)) {
        }
    }

    @TestCase
    func load_valid_library() {
        if (let Some(clib) <- CLibrary.load(validCLib)) {
            clib.close()
        } else {
            @Fail("Expected successful library load")
        }
    }
}

@Test
class TestCFunc {
    var clib: ?CLibrary = None

    @BeforeAll
    func prepareData() {
        clib = CLibrary.load(validCLib)
    }

    @AfterAll
    func cleanup() {
        clib?.close()
    }

    @TestCase
    func get_valid_function() {
        if (let Some(clib) <- clib) {
            if (let Some(cfunc) <- clib.get("glClear")) {
            } else {
                @Fail("Expected successful function load")
            }
        } else {
            @Fail("Expected successful library load")
        }
    }

    @TestCase
    func get_invalid_function() {
        if (let Some(clib) <- clib) {
            @Expect(clib.get("invalid_function").isNone(), true)
        } else {
            @Fail("Expected successful library load")
        }
    }
}
