# Package

version       = "0.1.0"
author        = "Jacob Torrey"
description   = "Testing JS"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.4"
task javascript, "Builds the package into JS":
    --outdir:"."
    setCommand "js", "src/awscredtester.nim"