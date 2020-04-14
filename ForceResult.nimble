import os

version     = "2.0.0"
author      = "Luke Parker"
description = "A pragma to automatically convert Exceptions to Results and prevent bubble up."
license     = "MIT"

installFiles = @[
    "ForceResult.nim"
]

requires "nim > 1.0.4"

proc gatherTests(
    dir: string
): seq[string] =
    for path in listFiles(dir):
        let file: tuple[dir, name, ext: string] = splitFile(path)
        if file.name.endsWith("Test"):
            result.add(path)

proc stripPath(
    path: string
): string =
    var splitPath: seq[string] = path.split("/")
    result = splitPath[^2] & "/" & splitPath[^1]

let nimExe: string = system.findExe("nim")
proc compile(
    path: string
): bool =
    echo nimExe & " c --out:" & ("build" / stripPath(path).split(".")[0]) & " " & path
    gorgeEx(nimExe & " c --out:" & ("build" / stripPath(path).split(".")[0]) & " " & path).exitCode == 0

proc pass(
    path: string
) =
    echo "\x1B[0;32m", stripPath(path), " passed.\x1B[0;37m"

proc fail(
    path: string
) =
    echo "\x1B[0;31m", stripPath(path), " failed.\x1B[0;37m"

task test, "Run tests.":
    for test in gatherTests(thisDir() / "tests" / "Pass"):
        if compile(test):
            pass(test)
        else:
            fail(test)

    for test in gatherTests(thisDir() / "tests" / "Fail"):
        if not compile(test):
            pass(test)
        else:
            fail(test)
