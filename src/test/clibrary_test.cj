package clibrary.test

import clibrary.{CLibrary, CLibraryException}

// cjlint-ignore -start !G.NAM.04 function names should be lower camel case

@When[os == "Windows"]
private const VALID_C_LIB = "opengl32.dll"
@When[os == "Linux"]
private const VALID_C_LIB = "libGL.so"
@When[os == "macOS"]
private const VALID_C_LIB = "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"

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
        try (clib = CLibrary(VALID_C_LIB)) {
        }
    }

    @TestCase
    func load_valid_library() {
        if (let Some(clib) <- CLibrary.load(VALID_C_LIB)) {
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
        clib = CLibrary.load(VALID_C_LIB)
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

// cjlint-ignore -end function names should be lower camel case
