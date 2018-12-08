#!/bin/bash -e
# The purpose of this script is to generate an io-500.sh and clean-io-500.sh
# based on a configuration file.
# You should not modify this script!
# Instead modify the configuration scripts.


CONFIG="$1"

if [[ ! -r "$CONFIG" ]] ; then
  echo "Synopsis: $0 <config.sh>"
  exit 1
fi

echo "Using configuration file: \"$CONFIG\""
echo

source $CONFIG

CONF=${CONFIG%%.sh}

# add any check for correctness here
if [[ "$DATA_DIR" == "" || "$DATA_DIR" = *[[:space:]]* ]] ; then
  echo "DATA_DIR should not contain whitespace!"
  exit 1
fi

if [[ "$BIN" == "" ||
      "$DATA_DIR" == "" ||
      "$MPIRUN" == "" ||
      "$STONEWALL_TIMER" == "" ||
      "$IOR_EASY_ARGS" == "" ||
      "$IOR_HARD_IO_COUNT" == "" ||
      "$MDTEST_EASY" == "" ||
      "$MDTEST_HARD_FILE_COUNT" == ""
]] ; then
  echo "Important variable not set!"
  exit 1
fi

if ! declare -f io500_info > /dev/null ; then
  echo "Function io500_info() not defined in configuration"
  exit 1
fi
if ! declare -f io500_prepare > /dev/null ; then
  echo "Function io500_prepare() not defined in configuration"
  exit 1
fi
if ! declare -f io500_job_header > /dev/null ; then
  echo "Function io500_job_header() not defined in configuration"
  exit 1
fi

TIME="echo -e echo -n \"time: \"; date +%s.%N"
NEWLINE="echo -e \\necho"

(
echo "#!/bin/bash -e"
echo "# WARNING: This script was automatically created using ./io-500-gen.sh $CONFIG"
echo "# Any modifications (below this line) will be lost if io-500-gen.sh is run again"
echo "# However, you may modify/tune this script manually or modify the generator to create an improved io-500.sh"
io500_job_header # add the job header
$NEWLINE
io500_info # add the info fields
$NEWLINE
echo "echo -n \"[START TIME] \""
echo "date --rfc-3339=seconds"
echo "mkdir -p $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results"
io500_prepare
$NEWLINE
echo "echo [IOR EASY WRITE]"
$TIME
echo $MPIRUN $BIN/ior $IOR_EASY_ARGS -w -C -Q 1 -g -G 27 -k -e -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER
$NEWLINE
echo "echo [MDTEST EASY WRITE]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_EASY -C -F -d $DATA_DIR/mdt_easy -x $DATA_DIR/mdt_easy-stonewall -W $STONEWALL_TIMER
$NEWLINE
echo "echo [CREATING TIMESTAMP]"
$TIME
echo "touch $DATA_DIR/timestampfile"
$NEWLINE
echo "echo [IOR HARD WRITE]"
$TIME
echo $MPIRUN $BIN/ior $IOR_HARD_EXTRA_ARGS -s $IOR_HARD_IO_COUNT -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall -O stoneWallingWearOut=1 -D $STONEWALL_TIMER
$NEWLINE
echo "echo [MDTEST HARD WRITE]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_HARD_EXTRA_ARGS -n $MDTEST_HARD_FILE_COUNT -C -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -x $DATA_DIR/mdt_hard-stonewall  -W $STONEWALL_TIMER
$NEWLINE

echo "echo [PFIND EASY]"
$TIME
echo "# You may change the find command defining the io_500_userdefined_find() function"
if [[ "$io_500_userdefined_find" != "" ]] ; then
  echo "[Find] Using user defined find: $io_500_userdefined_find" >&2
  echo "$io_500_userdefined_find \"$DATA_DIR\" \"-newer\" \"$DATA_DIR/timestampfile\" \"-size\" \"3901c\" \"-name\" \"*01*\""
else
  echo "[Find] Using pfind" >&2
  echo $MPIRUN $BIN/pfind $DATA_DIR -newer $DATA_DIR/timestampfile -size 3901c -name *01* -s $STONEWALL_TIMER -C -P -D rates #-r $DATA_DIR/pfind_results
fi
$TIME
$NEWLINE
echo "echo [IOR EASY READ]"
$TIME
echo $MPIRUN $BIN/ior $IOR_EASY_ARGS -r -R -C -Q 1 -g -G 27 -k -e -o $DATA_DIR/ior_easy/ior_file_easy -O stoneWallingStatusFile=$DATA_DIR/ior_easy/stonewall
$NEWLINE
echo "echo [MDTEST EASY STAT]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_EASY -T -F -d $DATA_DIR/mdt_easy -x $DATA_DIR/mdt_easy-stonewall
$NEWLINE
echo "echo [IOR HARD READ]"
$TIME
echo $MPIRUN $BIN/ior $IOR_HARD_EXTRA_ARGS -s $IOR_HARD_IO_COUNT -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s $IOR_HARD_IO_COUNT $IOR_HARD_EXTRA_ARGS  -o $DATA_DIR/ior_hard/IOR_file -O stoneWallingStatusFile=$DATA_DIR/ior_hard/stonewall
$NEWLINE
echo "echo [MDTEST HARD STAT]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_HARD_EXTRA_ARGS -n $MDTEST_HARD_FILE_COUNT -T -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo [MDTEST EASY DELETE]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_EASY -r -F -d $DATA_DIR/mdt_easy  -x $DATA_DIR/mdt_easy-stonewall
$NEWLINE
echo "echo [MDTEST HARD READ]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_HARD_EXTRA_ARGS -n $MDTEST_HARD_FILE_COUNT -E -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard  -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo [MDTEST HARD DELETE]"
$TIME
echo $MPIRUN $BIN/mdtest $MDTEST_HARD_EXTRA_ARGS -n $MDTEST_HARD_FILE_COUNT -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -x $DATA_DIR/mdt_hard-stonewall
$NEWLINE
echo "echo Deleting IO-500 $DATA_DIR"
$TIME
echo rm -rf $DATA_DIR/ior_easy $DATA_DIR/ior_hard $DATA_DIR/mdt_hard $DATA_DIR/mdt_easy $DATA_DIR/pfind_results $DATA_DIR/timestampfile $DATA_DIR/mdt_easy-stonewall $DATA_DIR/mdt_hard-stonewall
echo "echo -n \"[END TIME] \""
echo "date --rfc-3339=seconds"
echo "echo [IO-500 COMPLETED] Now use io-500-score.sh to compute the score!"
)  > $CONF-io-500.sh

chmod 755 $CONF-io-500.sh

(
echo "#!/bin/bash"
echo "# This script removes the data, run it with the same parameters as the original script"
echo $MPIRUN $BIN/mdtest $MDTEST_EASY -r -F -d $DATA_DIR/mdt_easy -x $DATA_DIR/mdt_easy-stonewall
echo $MPIRUN $BIN/mdtest $MDTEST_HARD_EXTRA_ARGS -r -t -F -w 3901 -e 3901 -d $DATA_DIR/mdt_hard -n $MDTEST_HARD_FILE_COUNT -x $DATA_DIR/mdt_hard-stonewall

) > $CONF-io-500-clean.sh
chmod 755 $CONF-io-500-clean.sh

echo "IO-500 Script created in $CONF-io-500.sh and $CONF-io-500-clean.sh for cleanup"
