import ../../ForceResult

import asyncdispatch

proc main(
    x: int
) {.forceResult: [], async.} =
    if x == 0:
        raise newException(ValueError, "")
    elif x == 1:
        raise newException(IOError, "")
waitFor main(0)
