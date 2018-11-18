#!/bin/bash -e
# The purpose of this script is to generate an io-500.sh and clean-io-500.sh
# You may then edit *certain* aspects of the generated io-500.sh
# Also modify that script to contain the batch submission code!

# The location of the binaries
BIN="./bin/"
# The location of the generated output data
DATA_DIR="./io500-datadir/"
# The command to execute a parallel job
MPIRUN="mpirun -np 2"

# For a small testing run, use, e.g.,
IOR_EASY_ARGS="-t 2048k -b 2m -F"
IOR_HARD_COUNT="100"
MDTEST_EASY="-n 250 -u -L" # you may change -u and -L
MDTEST_HARD_COUNT="10"

# For a full run, you may start with these parameters
STONEWALL_TIMER=300 # set to 0 to disable
#IOR_EASY_ARGS="-t 2m -b 2000g -F"
#IOR_HARD_COUNT="100000"
#MDTEST_EASY="-n 25000000 -u -L" # you may change -u and -L
#MDTEST_HARD_COUNT="10000"

# If you want to change the find command to a specific version, check below.
# For most cases, you should not need to modify anything beyond this point.

OUT_SCRIPT_FILE=io-500.sh
(
echo "#!/bin/bash"
echo "# Modify this script to include everything needed to startup with your batch system"
echo "#QSUB|PBS -n XX"
echo ""
echo "echo [IOR EASY WRITE]"
echo "mkdir -p $DATA_DIR/ior_easy $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results"
echo "# Please add here additional scripts to setup/prepare the directories like lfs setstripe"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST EASY WRITE]"
echo $MPIRUN $BIN/mdtest -C -F -d $DATA_DIR/mdt_easy $MDTEST_EASY -x $DATA_DIR/mdt_easy-stonewall -W $STONEWALL_TIMER

echo "touch $DATA_DIR/timestampfile"

echo "echo [IOR HARD WRITE]"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_COUNT  -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST HARD WRITE]"
echo $MPIRUN $BIN/mdtest -C -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $DATA_DIR/mdt_hard-stonewall  -W $STONEWALL_TIMER

echo "echo [PFIND EASY]"
echo "# You may change the pfind command!"
echo $MPIRUN $BIN/pfind $DATA_DIR -newer $DATA_DIR/timestampfile -size 3901c -name *01* -s $STONEWALL_TIMER -r $DATA_DIR/pfind_results

echo "echo [IOR EASY READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall

echo "echo [MDTEST EASY STAT]"
echo $MPIRUN $BIN/mdtest -T -F -d $DATA_DIR/mdt_easy $MDTEST_EASY -x $DATA_DIR/mdt_easy-stonewall

echo "echo [IOR HARD READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_COUNT  -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall

echo "echo [MDTEST HARD STAT]"
echo $MPIRUN $BIN/mdtest -T -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $DATA_DIR/mdt_hard-stonewall

echo "echo [MDTEST EASY DELETE]"
echo $MPIRUN $BIN/mdtest -r -F -d $DATA_DIR/mdt_easy $MDTEST_EASY -x $DATA_DIR/mdt_easy-stonewall

echo "echo [MDTEST HARD READ]"
echo $MPIRUN $BIN/mdtest -E -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $DATA_DIR/mdt_hard-stonewall

echo "echo [MDTEST HARD DELETE]"
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $DATA_DIR/mdt_hard-stonewall
)  > $OUT_SCRIPT_FILE

chmod 755 $OUT_SCRIPT_FILE

CLEANUP_FILE=clean-$OUT_SCRIPT_FILE
(
echo "#!/bin/bash"
echo "# This script removes the data, run it with the same parameters as the original script"
echo $MPIRUN $BIN/mdtest -r -F -d $DATA_DIR/mdt_easy $MDTEST_EASY -x $DATA_DIR/mdt_easy-stonewall
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $DATA_DIR/mdt_hard-stonewall
echo rm -rf $DATA_DIR/ior_easy $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results $DATA_DIR/timestampfile $DATA_DIR/mdt_easy-stonewall $DATA_DIR/mdt_hard-stonewall
) > $CLEANUP_FILE
chmod 755 $CLEANUP_FILE

echo "IO-500 Script created in \"$OUT_SCRIPT_FILE\" and \"$CLEANUP_FILE\""
