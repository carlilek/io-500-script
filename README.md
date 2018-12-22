# README

This is a new version of the IO-500 suite.
It is easy to use, minimal during the execution to prevent errors, and easy to debug.
To achieve these goals, it splits the execution into phases:
 * A generation phase able to check for errors that creates a hard-coded run-script without branches
 * The run-script can then be inspected / further modified to include *allowed* tuning settings and the batch-submission commands
 * An analysis phase which parses the output of the execution, checks the validity of the result and computes the scores

# Files

  * io-500-gen.sh: This file generates an io-500.sh for execution based on a configuration file. Run it with: ./io-500-gen.sh <CONFIG>
  * Configuration files:
    - config-normal.sh: A regular configuration file using stonewalling and large amounts of data.
    - config-test.sh: A simple configuration useful for the first steps with IO-500.
  * io-500-score.sh: This file parses the output of the io-500.sh, checks the correctness and computes the score.

# Usage

The ./io-500-gen.sh script generates an io-500.sh file with all parameters hard-coded.
That makes it easier to spot errors, change the behavior and test performance by, e.g., removing phases.

The intended usage is:
 - copy an existing configuration file (see the existing templates in config*) into the existing top-level directory as <CONFIG>.
 - modify <CONFIG>
 - run io-500-gen.sh <CONFIG>, check the generated <CONFIG>-io-500.sh
   there should be no need to modify the generated file further!
 - submit the generated file to your batch scheduler
   (there should be no need to add further parameters to the job submission manually)
 - after the run:
   - run io-500-score.sh [job-output] to compute the score

In case of an error, you may use the <CONFIG>-clean-io-500.sh to remove the created temporary data using a parallel execution.
It must be run it with the same scheduler arguments as <CONFIG>-io-500.sh.
