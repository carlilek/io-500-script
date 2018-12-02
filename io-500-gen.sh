#!/bin/bash -e
# The purpose of this script is to generate an io-500.sh and clean-io-500.sh
# You may then edit *certain* aspects of the generated io-500.sh
# Also modify that script to contain the batch submission code!

# The location of the binaries
BIN="./bin/"
# The location of the generated output data
DATA_DIR="./io500-datadir/"
# The command to execute a parallel job
MPIRUN="mpiexec -np 2"

# Before you change parameters, familarize with the rules:
# https://www.vi4io.org/io500/about/start
# check also the specific challenge you want to submit.

SIMPLE_TEST=true   # set to "false" for a proper test run
if $SIMPLE_TEST; then
  echo -e "WARNING: Generating code for a TEST run\n"
  # For a small testing run
  STONEWALL_TIMER=10 # set to 0 to disable
  IOR_EASY_ARGS="-t 2048k -b 2m -F"
  IOR_HARD_IO_COUNT="100"
  IOR_HARD_EXTRA_ARGS=""
  MDTEST_EASY="-n 250 -u -L"
  MDTEST_HARD_FILE_COUNT="150"
  MDTEST_HARD_EXTRA_ARGS=""
else # These are parameters for a full IO-500 test run
  echo "Generating code for a production run"
  # The following parameters can be generally modified
  # See http://www.io500.org/run for more details about allowed modifications
  STONEWALL_TIMER=300 # set to 0 to disable
  IOR_EASY_ARGS="-t 2m -b 2000g -F"
  IOR_HARD_IO_COUNT="100000"
  MDTEST_EASY="-n 25000000 -u -L" # e.g. you may remove -u and -L, if you like
  MDTEST_HARD_FILE_COUNT="10000"
fi

# Information fields; these provide information about your system hardware
# Use https://vi4io.org/io500-info-creator/ to generate information about your hardware
# that you want to include publicly!
function io500_info(){
  # replace this body with the generated text, e.g.
  echo io500_info_institution='""'
}

# For most cases, you should not need to modify anything beyond this point.
# If you want to run many different setups, it might be useful to change the batch scheduler, add optimizations etc. here, though.
# You may also change the find command to a specific version, check below.
(
NEWLINE="echo -e \\necho"
echo "#!/bin/bash -e"
echo "# WARNING: This script was automatically created using io-500-gen.sh generator"
echo "# Any modifications (below this line) will be lost if io-500-gen.sh is run again"
echo "# However, you may modify/tune this script manually or modify the generator to create an improved io-500.sh"
echo "# Put your batch submission commands QSUB | PBS -n XX"
$NEWLINE
io500_info # add the info fields
$NEWLINE
echo "echo -n [START TIME] "
echo "date --rfc-3339=seconds"
$NEWLINE
echo "echo [IOR EASY WRITE]"
echo "mkdir -p $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results"
echo "# Please add here additional scripts to setup/prepare the directories like lfs setstripe"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER
$NEWLINE
echo "echo [MDTEST EASY WRITE]"
echo $MPIRUN $BIN/mdtest -C -F -d $DATA_DIR/mdt_easy $MDTEST_EASY $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_easy-stonewall -W $STONEWALL_TIMER
$NEWLINE
echo "echo [CREATING TIMESTAMP]"
echo "touch $DATA_DIR/timestampfile"
$NEWLINE
echo "echo [IOR HARD WRITE]"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_IO_COUNT $IOR_HARD_EXTRA_ARGS  -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER
$NEWLINE
echo "echo [MDTEST HARD WRITE]"
echo $MPIRUN $BIN/mdtest -C -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_hard-stonewall  -W $STONEWALL_TIMER
$NEWLINE
echo "echo [PFIND EASY]"
echo "# You may change the pfind command!"
echo $MPIRUN $BIN/pfind $DATA_DIR -newer $DATA_DIR/timestampfile -size 3901c -name *01* -s $STONEWALL_TIMER -r $DATA_DIR/pfind_results
$NEWLINE
echo "echo [IOR EASY READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall
$NEWLINE
echo "echo [MDTEST EASY STAT]"
echo $MPIRUN $BIN/mdtest -T -F -d $DATA_DIR/mdt_easy $MDTEST_EASY $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_easy-stonewall
$NEWLINE
echo "echo [IOR HARD READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_IO_COUNT $IOR_HARD_EXTRA_ARGS  -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall
$NEWLINE
echo "echo [MDTEST HARD STAT]"
echo $MPIRUN $BIN/mdtest -T -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo [MDTEST EASY DELETE]"
echo $MPIRUN $BIN/mdtest -r -F -d $DATA_DIR/mdt_easy $MDTEST_EASY $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_easy-stonewall
$NEWLINE
echo "echo [MDTEST HARD READ]"
echo $MPIRUN $BIN/mdtest -E -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo [MDTEST HARD DELETE]"
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo -n [END TIME]"
echo "date --rfc-3339=seconds"
echo "echo [IO-500 COMPLETED] Now use io-500-score.sh to compute the score!"
)  > io-500.sh

chmod 755 io-500.sh

(
echo "#!/bin/bash"
echo "# This script removes the data, run it with the same parameters as the original script"
echo $MPIRUN $BIN/mdtest -r -F -d $DATA_DIR/mdt_easy $MDTEST_EASY $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_easy-stonewall
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT $MDTEST_HARD_EXTRA_ARGS -x $DATA_DIR/mdt_hard-stonewall
echo rm -rf $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results $DATA_DIR/timestampfile $DATA_DIR/mdt_easy-stonewall $DATA_DIR/mdt_hard-stonewall
) > io-500-clean.sh
chmod 755 io-500-clean.sh

echo "IO-500 Script created in io-500.sh and io-500-clean.sh for cleanup"
