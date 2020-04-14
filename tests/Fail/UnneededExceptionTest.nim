import ../../ForceResult

proc main() {.forceResult: [
    OSError
].} =
    discard
main()
