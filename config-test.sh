# This config file contains minimal configurations for a test run

# The location of the binaries
BIN="./bin/"
# The location of the generated output data
DATA_DIR="./io500-datadir/"
# The command to execute a parallel job
MPIRUN="mpiexec -np 2"

# Before you change parameters, familarize with the rules:
# https://www.vi4io.org/io500/about/start
# check also the specific challenge you want to submit.
echo -e "WARNING: Generating code for a TEST run\n"
# For a small testing run
STONEWALL_TIMER=10 # set to 0 to disable
IOR_EASY_ARGS="-t 2048k -b 2m -F"
IOR_HARD_IO_COUNT="100"
IOR_HARD_EXTRA_ARGS=""
MDTEST_EASY="-n 250 -u -L"
MDTEST_HARD_FILE_COUNT="150"
MDTEST_HARD_EXTRA_ARGS=""

# Define this variable if you want to use your version of find
# Note that the find script must be submitted to the IO-500 repository to be available
# io_500_userdefined_find="./bin/sfind.sh"

# Include here the information for the job scheduler
function io500_job_header(){
  echo "# Put your batch submission commands QSUB | PBS -n XX"
}

# Information fields; these provide information about your system hardware
# Use https://vi4io.org/io500-info-creator/ to generate information about your hardware
# that you want to include publicly!
function io500_info(){
  # replace this body with the generated text, e.g.
  echo io500_info_institution='""'
}

function io500_prepare(){
  echo "# Please add in io500_prepare() additional scripts to setup/prepare the directories like lfs setstripe"
}
