# These are parameters for a full IO-500 test run

# The location of the binaries
BIN="./bin/"
# The location of the generated output data
DATA_DIR="./io500-datadir/"
# The command to execute a parallel job
MPIRUN="mpiexec -np 2"

# Before you change parameters, familarize with the rules:
# https://www.vi4io.org/io500/about/start
# check also the specific challenge you want to submit.
echo "Generating code for a production run"
# The following parameters can be generally modified
# See http://www.io500.org/run for more details about allowed modifications
STONEWALL_TIMER=300 # set to 0 to disable
IOR_EASY_ARGS="-t 2m -b 2000g -F"
IOR_HARD_IO_COUNT="100000"
MDTEST_EASY="-n 25000000 -u -L" # e.g. you may remove -u and -L, if you like
MDTEST_HARD_FILE_COUNT="10000"

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
