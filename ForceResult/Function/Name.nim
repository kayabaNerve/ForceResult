import macros

#Return the name of a function.
proc getName*(
    function: NimNode
): string {.compileTime.} =
    #If it's a lambda, the function has no name.
    if function[0].kind == nnkEmpty:
        result = "lambda"
    #If it's a private operator...
    elif function[0].kind == nnkAccQuoted:
        result = function[0][0].strVal
    #If this is a postfix, it's either a public function or an public operator.
    elif function[0].kind == nnkPostfix:
        #Check if it's an operator.
        for c in 0 ..< function[0].len:
            #If it is, return the operator's strVal.
            if function[0][c].kind == nnkAccQuoted:
                return function[0][c][0].strVal

        #If it's not an operator, it's a public function.
        result = function[0][1].strVal
    #If it's a regular function...
    else:
        result = function[0].strVal

#Rename a proc to the passed string.
proc rename*(
    function: var NimNode,
    nameArg: string
) {.compileTime.} =
    var name: NimNode = newIdentNode(nameArg)

    #If this is a lambda defined using proc, it's of nnkLambda, which can't be named.
    #If this is a lambda defined using func, it's of nnkFuncDef, and therefore can be named.
    #There's also a problem with converters/methods. They're required to be at the top level, and therefore must be converted to a proc as well.
    #If this is a problem function type, convert it.
    if (function.kind == nnkLambda) or (function.kind == nnkConverterDef) or (function.kind == nnkMethodDef):
        var functionCopy: NimNode = newNimNode(nnkProcDef)
        function.copyChildrenTo(functionCopy)
        function = functionCopy

        #Methods can have the base pragma, which cannot be applied to procs. If we find one, we need to delete it.[]
        for p in 0 ..< function[4].len:
            if (function[4][p].kind == nnkIdent) and (function[4][p].strVal == "base"):
                function[4].del(p)

    #If it's a private operator, rename it, but preserve it as an operator.
    if function[0].kind == nnkAccQuoted:
        function[0] = newNimNode(
            nnkAccQuoted
        ).add(name)
    #If this function's name node is postfix, it's either a public function or an public operator.
    elif function[0].kind == nnkPostfix:
        #Check if it's an operator.
        for c in 0 ..< function[0].len:
            #If it is, rename it, but preserve it as an operator.
            if function[0][c].kind == nnkAccQuoted:
                function[0] = newNimNode(
                    nnkAccQuoted
                ).add(name)
                return

        #Or, if it's not an operator, just overwrite it with a standard ident node.
        function[0] = name
