#!/bin/bash -e
# The purpose of this script is to generate an io-500.sh
# You may then edit *certain* aspects of the generated io-500.sh
# Also modify that script to contain the batch submission code!

MPIRUN="mpirun -np 2"
OUT_FILE=io-500.sh
BIN="./bin/"
STONEWALL_TIMER=0 # set to 0 to disable
RESULTS_DIR="./results"

# For a full run, you may use
IOR_EASY_ARGS="-t 2048k -b 2000000m -F"
IOR_HARD_COUNT="100000"
MDTEST_EASY="-n 25000000 -u -L" # you may change -u and -L
MDTEST_HARD_COUNT="10000"

# For testing, use, e.g.
IOR_EASY_ARGS="-t 2048k -b 2m -F"
IOR_HARD_COUNT="100"
MDTEST_EASY="-n 250 -u -L" # you may change -u and -L
MDTEST_HARD_COUNT="10"


echo "#!/bin/bash" > $OUT_FILE
chmod 755 $OUT_FILE

(
echo "echo [IOR EASY WRITE]"
echo "mkdir -p $RESULTS_DIR/ior_easy $RESULTS_DIR/ior_easy $RESULTS_DIR/ior_hard $RESULTS_DIR/mdt_hard $RESULTS_DIR/mdt_easy $RESULTS_DIR/pfind_results"
echo "# Please add here additional scripts to setup/prepare the directories like lfs setstripe"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $RESULTS_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$RESULTS_DIR/ior_easy/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST EASY WRITE]"
echo $MPIRUN $BIN/mdtest -C -F -d $RESULTS_DIR/mdt_easy $MDTEST_EASY -x $RESULTS_DIR/mdt_easy-stonewall -W $STONEWALL_TIMER

echo "touch $RESULTS_DIR/timestampfile"

echo "echo [IOR HARD WRITE]"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_COUNT  -o $RESULTS_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$RESULTS_DIR/ior_hard/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST HARD WRITE]"
echo $MPIRUN $BIN/mdtest -C -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $RESULTS_DIR/mdt_hard-stonewall  -W $STONEWALL_TIMER

echo "echo [PFIND EASY]"
echo $MPIRUN $BIN/pfind $RESULTS_DIR -newer $RESULTS_DIR/timestampfile -size 3901c -name *01* -s $STONEWALL_TIMER -r $RESULTS_DIR/pfind_results

echo "echo [IOR EASY READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e $IOR_EASY_ARGS -o $RESULTS_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$RESULTS_DIR/ior_easy/stonewall

echo "echo [MDTEST EASY STAT]"
echo $MPIRUN $BIN/mdtest -T -F -d $RESULTS_DIR/mdt_easy $MDTEST_EASY -x $RESULTS_DIR/mdt_easy-stonewall

echo "echo [IOR HARD READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_COUNT  -o $RESULTS_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$RESULTS_DIR/ior_hard/stonewall

echo "echo [MDTEST HARD STAT]"
echo $MPIRUN $BIN/mdtest -T -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $RESULTS_DIR/mdt_hard-stonewall

echo "echo [MDTEST EASY DELETE]"
echo $MPIRUN $BIN/mdtest -r -F -d $RESULTS_DIR/mdt_easy $MDTEST_EASY -x $RESULTS_DIR/mdt_easy-stonewall

echo "echo [MDTEST HARD READ]"
echo $MPIRUN $BIN/mdtest -E -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $RESULTS_DIR/mdt_hard-stonewall

echo "echo [MDTEST HARD DELETE]"
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n $MDTEST_HARD_COUNT -x $RESULTS_DIR/mdt_hard-stonewall
)  >> $OUT_FILE

echo "IO-500 Script created in \"$OUT_FILE\""
