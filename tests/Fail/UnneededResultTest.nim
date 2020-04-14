import ../../ForceResult

forceResultException:
    type AError = object of Exception

proc main() {.forceResult: [
    AError
].} =
    discard
main()
