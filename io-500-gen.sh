#!/bin/bash

MPIRUN="mpirun -np 2"
OUT_FILE=io-500.sh
BIN="./bin/"
STONEWALL_TIMER=300 # set to 0 to disable
RESULTS_DIR="./results"

echo "#!/bin/bash" > $OUT_FILE
chmod 755 $OUT_FILE

(
echo "echo [IOR EASY WRITE]"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e -t 2048k -b 2000000m -F -o $RESULTS_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$RESULTS_DIR/ior_easy/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST EASY WRITE]"
echo $MPIRUN $BIN/mdtest -C -F -d $RESULTS_DIR/mdt_easy -n 25000000 -u -L -x $RESULTS_DIR/mdt_easy-stonewall -W $STONEWALL_TIMER

echo "echo [IOR HARD WRITE]"
echo $MPIRUN $BIN/ior -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s 10000000  -o $RESULTS_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$RESULTS_DIR/ior_hard/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER

echo "echo [MDTEST HARD WRITE]"
echo $MPIRUN $BIN/mdtest -C -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n 5000000 -x $RESULTS_DIR/mdt_hard-stonewall  -W $STONEWALL_TIMER

echo "echo [PFIND EASY]"
echo $MPIRUN $BIN/pfind $RESULTS_DIR -newer $RESULTS_DIR/timestampfile -size 3901c -name *01* -s $STONEWALL_TIMER -r /ddn/benchmark/io-500-dev/results/2018.10.15-10.00.59/pfind_results

echo "echo [IOR EASY READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e -t 2048k -b 2000000m -F -o $RESULTS_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$RESULTS_DIR/ior_easy/stonewall

echo "echo [MDTEST EASY STAT]"
echo $MPIRUN $BIN/mdtest -T -F -d $RESULTS_DIR/mdt_easy -n 25000000 -u -L -x $RESULTS_DIR/mdt_easy-stonewall

echo "echo [IOR HARD READ]"
echo $MPIRUN $BIN/ior -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s 10000000  -o $RESULTS_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$RESULTS_DIR/ior_hard/stonewall

echo "echo [MDTEST HARD STAT]"
echo $MPIRUN $BIN/mdtest -T -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n 5000000 -x $RESULTS_DIR/mdt_hard-stonewall

echo "echo [MDTEST EASY DELETE]"
echo $MPIRUN $BIN/mdtest -r -F -d $RESULTS_DIR/mdt_easy -n 25000000 -u -L -x $RESULTS_DIR/mdt_easy-stonewall

echo "echo [MDTEST HARD READ]"
echo $MPIRUN $BIN/mdtest -E -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n 5000000 -x $RESULTS_DIR/mdt_hard-stonewall

echo "echo [MDTEST HARD DELETE]"
echo $MPIRUN $BIN/mdtest -r -t -F -w 3901 -e 3901 -d $RESULTS_DIR/mdt_hard -n 5000000 -x $RESULTS_DIR/mdt_hard-stonewall
)  >> $OUT_FILE

echo "IO-500 Script created in \"$OUT_FILE\""
