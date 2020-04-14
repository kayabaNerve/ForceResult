import ../../ForceResult

type
   A = object
   B = object

converter cA(a: A): bool {.forceResult: [].} =
   false

converter cB*(b: B): bool {.forceResult: [].} =
   true

discard cA(A())
discard cB(B())
