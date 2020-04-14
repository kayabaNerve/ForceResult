import ../ForceResult

proc empty() {.forceResult: [].} =
    discard

proc publicEmpty*() {.forceResult: [].} =
    discard

proc unneeded() {.forceResult: [
    OSError
].} =
    discard

proc multitype(
    a: int or string)
 {.forceResult: [].} =
    discard

var procLambda: proc () {.raises: [].} = proc () {.forceResult: [].} =
    discard

proc `!`(a: int) {.forceResult: [].} =
    discard

proc raises() {.forceResult: [
    OSError
].} =
    raise newException(OSError, "")

proc publicRaises*() {.forceResult: [
    OSError
].} =
    raise newException(OSError, "")

func funcEmpty() {.forceResult: [].} =
    discard

func funcPublicEmpty*() {.forceResult: [].} =
    discard

func funcUnneeded() {.forceResult: [
    OSError
].} =
    discard

func funcMultitype(a: int or string) {.forceResult: [].} =
    discard

var funcLambda: proc () {.noSideEffect.} = func () {.forceResult: [].} =
    discard

func `@`*(a: int) {.forceResult: [].} =
    discard

func funcRaises() {.forceResult: [
    OSError
].} =
    raise newException(OSError, "")

func funcPublicRaises*() {.forceResult: [
    OSError
].} =
    raise newException(OSError, "")

empty()
publicEmpty()
unneeded()
multitype(5)
procLambda()
!5

funcEmpty()
funcPublicEmpty()
funcUnneeded()
funcMultitype("x")
funcLambda()
@5

raises()
publicRaises()
funcRaises()
funcPublicRaises()
