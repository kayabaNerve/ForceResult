# ForceResult

A Nimble package which:
- Automatically converts user-defined Exceptions to utilize Results, increasing performance while maintaining preferable syntax and making porting existing codebases over easier.
- Requires handling every Exception, along with Exceptions which are converted to Results, in order to prevent the risk of bubble up.
- Requires preventing error bubble up

# Usage:

`forceResult` takes the place of the existing raises pragma. For usage with asynchronous functions, the pragmas must be in the following order: `{.forceResult: [], async.}`. Every async function can raise `Exception`, or `OSError` in the case of Chronos, making a raises generally worthless. That said, when `forceResult` copies your function, it removes `async` from the copy and replaces every `await` with `waitFor`, allowing proper bubble-up detection.

All user-defined exceptions must be defined like:
```
type
    AError {.forceResult.} = object of Exception
    BError* {.forceResult.} = object of Exception
    CError* {.forceResult.} = object of Exception
        code*: int
```
