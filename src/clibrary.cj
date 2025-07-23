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

public class CLibrary <: Resource {
    private var m_handle: CPointer<Unit>

    public prop handle: CPointer<Unit> {
        get() {
            m_handle
        }
    }

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

    private init(handle: CPointer<Unit>) {
        m_handle = handle
    }

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
