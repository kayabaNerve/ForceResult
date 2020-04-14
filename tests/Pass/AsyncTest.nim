import ../../ForceResult

import asyncdispatch

proc main(
    x: int
) {.forceResult: [
    ValueError,
    IOError
], async.} =
    if x == 0:
        raise newException(ValueError, "")
    elif x == 1:
        raise newException(IOError, "")
try:
    waitFor main(0)
except ValueError:
    quit(0)
quit(1)
