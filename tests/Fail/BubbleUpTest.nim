import ../../ForceResult

proc called() {.forceResult: [
    KeyError
].} =
    raise newException(KeyError, "")

proc main() {.forceResult: [
    KeyError
].} =
    called()
main()
