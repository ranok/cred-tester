# Package

version       = "0.1.0"
author        = "Jacob Torrey"
description   = "Simple SPA to test is a set of AWS creds are valid"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.4"
task javascript, "Builds the package into JS":
    --outdir:"."
    --define:release
    setCommand "js", "src/awscredtester.nim"