import ../../ForceResult

forceResultException:
    type AError = object of Exception

proc unneeded() {.forceResult: [].} =
    discard

proc main() {.forceResult: [].} =
    try:
        unneeded()
    except AError:
        discard
main()
