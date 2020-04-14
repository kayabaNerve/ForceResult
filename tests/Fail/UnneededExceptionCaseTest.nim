import ../../ForceResult

proc unneeded() {.forceResult: [].} =
    discard

proc main() {.forceResult: [].} =
    try:
        unneeded()
    except OSError:
        discard
main()
