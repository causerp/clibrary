package clibrary

@When[os == "Windows"]
foreign {
    func LoadLibraryA(name: CString): CPointer<Unit>

    func GetProcAddress(handle: CPointer<Unit>, name: CString): CPointer<Unit>

    func FreeLibrary(handle: CPointer<Unit>): Int32
}

@When[os != "Windows"]
foreign {
    func dlopen(name: CString, flag: Int32): CPointer<Unit>

    func dlsym(handle: CPointer<Unit>, name: CString): CPointer<Unit>

    func dlclose(handle: CPointer<Unit>): Int32
}

public class CLibraryException <: Exception {
    public init(message: String) {
        super(message)
    }
}

/**
 * This is a library that loads C dynamic libraries (.dll, .dylib, .so).
 */
public class CLibrary <: Resource {
    private var m_handle: CPointer<Unit>

    public prop handle: CPointer<Unit> {
        get() {
            m_handle
        }
    }

    /**
     * Create a new CLibrary object and loads the library.
     *
     * @param name library name with file extension.
     *
     * @throws CLibraryException if library fails to load.
     */
    public init(name: String) {
        unsafe {
            try (name = LibC.mallocCString(name).asResource()) {
                @When[os == "Windows"]
                let libPtr = LoadLibraryA(name.value)

                @When[os != "Windows"]
                let libPtr = dlopen(name.value, 1) // RTLD_LAZY

                m_handle = libPtr
                if (m_handle.isNotNull()) {
                    return
                }
            }
            throw CLibraryException("Failed to load library")
        }
    }

    /**
     * Create a new CLibrary object from existing library handle.
     *
     * @param handle library handle.
     */
    private init(handle: CPointer<Unit>) {
        m_handle = handle
    }

    /**
     * Load a library.
     *
     * @param name library name with file extension.
     *
     * @return returns a CLibrary object or None if it fails to load.
     */
    public static func load(name: String): ?CLibrary {
        unsafe {
            try (name = LibC.mallocCString(name).asResource()) {
                @When[os == "Windows"]
                let handle = LoadLibraryA(name.value)

                @When[os != "Windows"]
                let handle = dlopen(name.value, 1)

                if (handle.isNotNull()) {
                    return CLibrary(handle)
                }
            }
            return None
        }
    }

    public func isClosed(): Bool {
        m_handle.isNull()
    }

    public func close(): Unit {
        if (m_handle.isNotNull()) {
            @When[os == "Windows"]
            let _ = unsafe { FreeLibrary(m_handle) }

            @When[os != "Windows"]
            let _ = unsafe { dlclose(m_handle) }

            m_handle = CPointer()
        }
    }

    /**
     * Get a library function.
     *
     * @param name function name.
     *
     * @return returns a function pointer or None if it fails to find the function.
     */
    public func get(name: String): ?CPointer<Unit> {
        unsafe {
            try (name = LibC.mallocCString(name).asResource()) {
                @When[os == "Windows"]
                let funcHandle = GetProcAddress(m_handle, name.value)

                @When[os != "Windows"]
                let funcHandle = dlsym(m_handle, name.value)

                if (funcHandle.isNotNull()) {
                    return funcHandle
                }
            }
            return Option<CPointer<Unit>>.None
        }
    }
}
