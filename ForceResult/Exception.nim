import macros

type
    ResultException* = ref object of RootObj
        msg: string

    Result*[T] = object
        code: int
        error: ResultException
        value: T

#Global used to keep track of what int each Exception uses.
#Allows using ForceResult across files and projects without conflicts.
var MOST_RECENT_CODE {.compileTime.}: int = 0
macro forceResultException*(
    typeBlock: untyped
): untyped =
    #Create a result with two distinct types.
    #1) A list of constant variables, which is each Exception mapped to an int.
    #2) A list of data types.
    result = newStmtList(
        newNimNode(nnkConstSection),
        typeBlock[0]
    )

    for dE in 0 ..< typeBlock[0].len:
        #Grab the type definition.
        var definedException: NimNode = typeBlock[0][dE]

        #Skip over other types in the same Block which aren't meant to be ResultExceptions.
        if definedException[2][1][0] != ident("ResultException"):
            continue

        #Increment the code. This will skip 0, which is slightly beneficial, as 0 is considered to not be an error.
        inc(MOST_RECENT_CODE)

        #Append the code to the list of constants.
        result[0].add(
            newNimNode(nnkConstDef).add(
                definedException[0],
                ident("int"),
                newIntLitNode(MOST_RECENT_CODE)
            )
        )

        #Rename the object in the type definition.
        case result[1][dE][0].kind:
            of nnkIdent:
                result[1][dE][0] = ident(result[1][dE][0].strVal & "Data")
                break
            of nnkPostfix:
                result[1][dE][0][1] = ident(result[1][dE][0][1].strVal & "Data")
            else:
                doAssert(false, "Unable to handle this type definition.")
