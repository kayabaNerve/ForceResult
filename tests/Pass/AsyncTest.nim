import ../../ForceResult

import asyncdispatch

proc called(
    x: int
) {.forceResult: [
    ValueError,
    IndexError
], async.} =
    if x == 0:
        raise newException(ValueError, "0")
    elif x == 1:
        raise newException(IndexError, "1")

proc returning(
    x: int
): Future[int] {.forceResult: [], async.} =
    result = x

proc unneeded() {.forceResult: [
    ValueError
], async.} =
    return

proc caller() {.forceResult: [], async.} =
    try:
        await called(0)
    except ValueError as e:
        echo e.msg
    except IOError as e:
        echo e.msg
    except Exception:
        echo "Exception."

    try:
        echo await returning(5)
    except Exception:
        echo "Exception"

    try:
        await unneeded()
    except Exception:
        discard

waitFor caller()
