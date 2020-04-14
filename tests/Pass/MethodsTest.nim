 import ../../ForceResult

type
    A = ref object of RootObj
    B = ref object of A

method test(
    a: A
) {.base, forceResult: [
    KeyError
].} =
    discard

method test*(
    b: B
) {.forceResult: [
    KeyError
].} =
    raise newException(KeyError, "")

A().test()
try:
    B().test()
except KeyError:
    quit(0)
quit(1)
