#!/bin/bash

echo "Computing the IO-500 score (use io-500-validate.py to run extensive checks!)"
set -euo pipefail   # give bash better error handling.
export LC_NUMERIC=C  # prevents printf errors


FILE="$1"
if [[ "$FILE" == "" ]] ; then
  echo "Synopsis: $0 <io500-standard-output>"
  exit 1
fi

if [[ ! -r "$FILE" ]] ; then
  echo "Can't read from file \"$FILE\""
  exit 1
fi

TMP=$(mktemp)
if [[ ! -r "$TMP" ]] ; then
  echo "Can't read from tmp file!"
  exit 1
fi


function section(){
  sed -n "/$1/{:a;n;/$2/b;p;ba}" "$FILE" > $TMP
}

function print_bw  {
  printf "[RESULT] BW   %20s %20.3f GB/s  : time %6.2f seconds\n" "$1" "$2" "$3" >&2
}

function print_iops  {
  printf "[RESULT] IOPS %20s %20.3f kiops\n" "$1" "$2"  >&2
}

function getIOR(){
  section "$1" "$2"
  REP=$(cat $TMP | grep "^repetitions" | sed "s/.*: //")
  if [[ $REP != 1 ]] ; then
    echo "The number of repeats must be 1 for IOR!"
    exit 1
  fi
  data=$(grep "^$3"  $TMP | tail -n 1 | awk '{print $3/1024}')
  if [[ "$data" == "" ]] ; then
    echo "Could not parse section $1"
    exit 1
  fi
  time=$(grep "^$3"  $TMP | head -n 1 | awk '{print $8}')
  print_bw "$1" "$data" "$time"
  echo "$data"
}


function getMD(){
  section "$1" "$2"
  data=$(grep "$3" $TMP | awk '{print $4/1000}')
  if [[ "$data" == "" ]] ; then
    echo "Could not parse section $1"
    exit 1
  fi
  print_iops "$1" "$data"
  echo "$data"
}

function getFind(){
  section "$1" "$2"
  data=$(grep "[DONE]" $TMP | awk '{print $3}')
  if [[ "$data" == "" ]] ; then
    echo "Could not parse section $1"
    exit 1
  fi
  print_iops "$1" "$data"
  echo "$data"
}

bw1=$(getIOR "IOR EASY WRITE" "MDTEST EASY WRITE" "write")
iops1=$(getMD "MDTEST EASY WRITE" "CREATING TIMESTAMP" "File creation")
bw2=$(getIOR "IOR HARD WRITE" "MDTEST HARD WRITE" "write")
iops2=$(getMD "MDTEST HARD WRITE" "PFIND EASY" "File creation")
iops3=$(getFind "PFIND EASY" "IOR EASY READ") # note that the files searched just have been written
bw3=$(getIOR "IOR EASY READ" "MDTEST EASY STAT" "read")
iops4=$(getMD "MDTEST EASY STAT" "IOR HARD READ" "File stat")
bw4=$(getIOR "IOR HARD READ" "MDTEST HARD STAT" "read")
iops5=$(getMD "MDTEST HARD STAT" "MDTEST EASY DELETE" "File stat")
iops6=$(getMD "MDTEST EASY DELETE" "MDTEST HARD READ" "File removal")
iops7=$(getMD "MDTEST HARD READ" "MDTEST HARD DELETE" "File read")
iops8=$(getMD "MDTEST HARD DELETE" "END TIME" "File removal")

rm $TMP

bw_score=`echo $bw1 $bw2 $bw3 $bw4 | awk '{print ($1*$2*$3*$4)^(1/4)}'`
md_score=`echo $iops1 $iops2 $iops3 $iops4 $iops5 $iops6 $iops7 $iops8 | awk '{print ($1*$2*$3*$4*$5*$6*$7*$8)^(1/8)}'`
tot_score=`echo $bw_score $md_score | awk '{print ($1*$2)^(1/2)}'`

echo "[SCORE] Bandwidth $bw_score GB/s : IOPS $md_score kiops : TOTAL $tot_score"
