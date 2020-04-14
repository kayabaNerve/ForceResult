import ../../ForceResult

forceResultException:
    type AError = ResultException

proc a() {.forceResult: [
    AError
].} =
    raise newException(AError, "")

proc b(): int {.inline, forceResult: [].} =
    5

proc main() {.forceResult: [].} =
    var flag: bool = false
    try:
        a()
        flag = true
        b()
    except AError:
        if flag:
            quit(1)
    quit(0)
