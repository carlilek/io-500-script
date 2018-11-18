# README

This is a new version of the IO-500 suite.

# Files

io-500-gen.sh: This file must be adjusted and generates an io-500.sh that can be easily adjusted for execution.
io-500-score.sh: This file parses the output of the io-500.sh, checks the correctness and computes the score.

# Usage

The ./io-500-gen.sh script generates an io-500.sh file with all parameters hard-coded.
That makes it easier to change the behavior and test performance by, e.g., removing phases.

The intended usage is:
 - adjust the core parameters in io-500-gen.sh
 - run io-500-gen.sh, check the generated io-500.sh
 - adjust the generated io-500.sh file to include the job scheduler information on top
 - run the io-500.sh (without adding further parameters to the job submission manually)
 - run io-500-score.sh [job-output] to compute the score
