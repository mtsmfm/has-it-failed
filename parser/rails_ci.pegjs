RailsCiResult
  = Noise tests:Test+ {
    return {
      failedTests: tests.filter(t => t.summary).filter(({summary: {failuresCount, errorsCount}}) => failuresCount + errorsCount > 0),
      coreDumpedTests: tests.filter(t => t.dump),
      noises: tests.filter(t => t.noise)
    }
  }

Noise
  = (!Test .)*

Test
  = command:TestCommand
    result:(
      results:TestFailureOrErrorResult* summary:TestFinished TestOutputNoise { return { summary, results } }
      / results:TestSuccessResult summary:TestFinished TestOutputNoise { return { summary, results } }
      / dump:RubyCoreDump { return { dump } }
      / noise:TestOutputNoise { return { noise } }
    ) {
    return { command, ...result };
  }

TestCommand
  = command:$("/home/travis/.rvm" $(!("/bin/" "j"? "ruby -w" / "\n") .)* "/bin/" "j"? "ruby -w" $(!"\n" .)*)
    "\n" { return command }

TestOutputNoise
  = (!TestCommand .)*

TestSuccessResult
  = message:$(!TestFinished .)* { return { message } }

TestFailureOrErrorResult
  = (!(TestFailureOrErrorResultKeyword / TestFinished) .)* meta:TestFailureOrErrorResultKeyword message:TestFailureMessage {
    return { ...meta, message }
  }

TestFailureMessage
  = $(!(TestFailureOrErrorResultKeyword / TestFinished) .)*

TestFailureOrErrorResultKeyword
  = "\n" type:("Failure" / "Error") ":\n" testClass:TestClass "#" method:TestMethod (" [" file:TestFile ":" line:Int "]")? ":\n" {
    return { type, testClass, method }
  }

TestClass
  = $[a-zA-Z:]+

TestMethod
  = $[a-zA-Z_]+

TestFile
  = $[a-z/\._]+

TestFinished
  = "\n" runsCount:Int " runs, " assertionsCount:Int " assertions, " failuresCount:Int " failures, " errorsCount:Int " errors, " skipsCount:Int " skips" "\n" {
    return { runsCount, assertionsCount, failuresCount, errorsCount, skipsCount }
  }

RubyCoreDump
  = $((!RubyCoreDumpNote .)* RubyCoreDumpNote)

RubyCoreDumpNote
  = "\n"
    "[NOTE]\n"
    "You may have encountered a bug in the Ruby interpreter or extension libraries.\n"
    "Bug reports are welcome.\n"
    "For details: https://www.ruby-lang.org/bugreport.html\n"
    "\n"
    "Aborted (core dumped)\n"

Int
  = chars:$[0-9]+ { return parseInt(chars) }
