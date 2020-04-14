 import ../ForceResult

type
    A = ref object of RootObj
    B = ref object of A

method test(a: A) {.base, forceResult: [].} =
    discard

method test*(b: B) {.forceResult: [].} =
    discard
