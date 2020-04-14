import Function/Name

import macros

#Recursively replaces every raise statement in the NimNode with a discard.
#This function also checks to make sure there's no generic excepts (`except:`).
proc removeRaises(
    parent: NimNode,
    index: int
) {.compileTime.} =
    #If this is an except branch, without specifying an error, error.
    if (parent[index].kind == nnkExceptBranch) and (parent[index].len == 1):
        raise newException(Exception, "Except branches must specify an Exception.")

    #If this is a raise statement, replace it with a discard statement.
    if parent[index].kind == nnkRaiseStmt:
        var replacement: NimNode = newNimNode(nnkDiscardStmt)
        parent[index].copyChildrenTo(replacement)
        parent[index] = replacement
        return

    #Iterate over every child and do the same there.
    for i in 0 ..< parent[index].len:
        removeRaises(parent[index], i)

#Recursively replaces every `await` with `waitFor` so the copied function is guaranteed synchronous.
#This is needed as every async proc raises `Exception`, and raises is purposeless when it includes Exception.
proc removeAsync(
    parent: NimNode,
    index: int
) {.compileTime.} =
    #If this is an `await`, replace it with a `waitFor`.
    if (parent[index].kind == nnkIdent) and (parent[index].strVal == "await"):
        parent[index] = newIdentNode("waitFor")

    #Iterate over every child and do the same there.
    for i in 0 ..< parent[index].len:
        parent[index].removeAsync(i)

#Make sure the proc/func doesn't allow any Exceptions to bubble up.
macro forceResult*(
    exceptions: untyped,
    original: untyped
): untyped =
    var
        #Boolean of whether or not this function is async.
        async: bool
        #Copy of the original function.
        copy: NimNode
        #Define a second copy if this is async (explained below).
        asyncCopy: NimNode

    #Copy the function.
    copy = copy(original)

    #Rename it.
    copy.rename(original.getName() & "_forceResult")

    #Add the used pragma.
    copy.addPragma(
        newIdentNode(
            "used"
        )
    )

    #If this is an async proc, remove any traces of async from the copy.
    for pragma in original[4]:
        if (pragma.kind == nnkIdent) and (pragma.strVal == "async"):
            async = true
    if async:
        #Remove the async pragma.
        for p in 0 ..< copy[4].len:
            if (copy[4][p].kind == nnkIdent) and (copy[4][p].strVal == "async"):
                copy[4].del(p)
                break

        #Remove the Future[T] from the copy.
        if copy[3][0].kind != nnkEmpty:
            copy[3][0] = copy[3][0][1]

        #Remove awaits.
        copy.removeAsync(6)

        #Create a second copy. Why?
        #Generally, the original function gets the proper raises pragma, and the copy gets its raises replaced with discards and a blank raises pragma.
        #If it is async, any raises pragma would be forced to include Exception, which would make it purposeless.
        #The solution to this, is create two copies.
        #As before, one raises nothing and has a blank raises. The other is untouched, other than it being made synchronous, and contains the proper raises pragma.
        #The first checks bubble up, the second checks that all possible Exceptions were placed in forceResult (guaranteeing it's a drop-in replacement for raises).
        asyncCopy = copy(copy)
        asyncCopy.rename(original.getName() & "_asyncforceResult")

    #Add the blank pragma to the original function if it's not async, or the asyncCopy if the original is.
    if not async:
        original.addPragma(
            newNimNode(
                nnkExprColonExpr
            ).add(
                newIdentNode(
                    "raises"
                ),
                exceptions
            )
        )
    else:
        asyncCopy.addPragma(
            newNimNode(
                nnkExprColonExpr
            ).add(
                newIdentNode(
                    "raises"
                ),
                exceptions
            )
        )

    #Add a blank raises to the copy.
    copy.addPragma(
        newNimNode(
            nnkExprColonExpr
        ).add(
            newIdentNode(
                "raises"
            ),
            newNimNode(nnkBracket)
        )
    )

    #Replace every raises in the copy with a discard statement.
    copy.removeRaises(6)

    #Add the copy (or copies) to the start of the original proc.
    if not asyncCopy.isNil:
        original[6].insert(
            0,
            asyncCopy
        )

    #Place the copy which stops bubble up in a hint block in order to stop duplicate hints.
    #The async copy is not placed in this block so unused Exceptions produce a hint.
    original[6].insert(
        0,
        newNimNode(
            nnkPragma
        ).add(
            newIdentNode("pop")
        )
    )

    original[6].insert(
        0,
        copy
    )

    original[6].insert(
        0,
        newNimNode(
            nnkPragma
        ).add(
            newIdentNode("push"),
            newNimNode(
                nnkExprColonExpr
            ).add(
                newIdentNode("hints"),
                newIdentNode("off")
            ),
        )
    )

    return original
