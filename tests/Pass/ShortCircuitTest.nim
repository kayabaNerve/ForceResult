import ../../ForceResult

forceResultException:
    type AError = ResultException

var
    andFlag: bool = false
    orFlag: bool = false

proc a(): bool {.forceResult: [
    AError
].} =
    if 0 == 1:
        raise newException(AError, "")

    orFlag = true
    result = false

proc b(): bool {.forceResult: [].} =
    andFlag = true
    result = true

proc main() {.forceResult: [].} =
    try:
        if a() and b():
            if andFlag:
                quit(1)

        orFlag = false
        if b() or a():
            if orFlag:
                quit(1)

        andFlag = false
        if (not a()) or b():
            if andFlag:
                quit(1)
    except AError:
        quit(1)
