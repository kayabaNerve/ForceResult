import ../ForceResult

proc called() {.forceResult: [
    KeyError
].} =
    raise newException(KeyError, "This is a KeyError.")

proc failure() {.forceResult: [
    KeyError
].} =
    called()
