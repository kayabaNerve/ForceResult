import ../../ForceResult

type
   A = object
   B = object

converter toBool(
    a: A
): bool {.forceResult: [].} =
   false

converter toBool*(
    b: B
): bool {.forceResult: [
    KeyError
].} =
    raise newException(KeyError, "")

discard A().toBool()
try:
    discard B().toBool()
except KeyError:
    quit(0)
quit(1)
