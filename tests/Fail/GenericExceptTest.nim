import ../../ForceResult

proc main() {.forceResult: [].} =
    try:
        discard
    except:
        discard
main()
