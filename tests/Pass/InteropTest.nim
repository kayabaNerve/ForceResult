const ERROR_MESSAGE: string = "Raised an error."

forceResultException:
    type InteropError = object of ResultException
        subcode: int

proc raises*(): int {.forceResult: [
    InteropError
].} =
    raise newException(InteropError, ERROR_MESSAGE)

proc returns*(): int {.forceResult: [
    InteropError
].} =
    if 0 == 1:
        raise newException(InteropError, "")
    result = 5

proc main() =
    var res: Result = raises()
    if not res.error.isNil:
        case res.code:
            of InteropError:
                if (res.error.msg != ERROR_MESSAGE) or (res.error.subcode != ERROR_SUBCODE):
                    quit(1)

    res = returns()
    if (not res.error.isNil) or (res.value != 5):
        quit(1)
main()
