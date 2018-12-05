#!/bin/bash -e
# WARNING: This script was automatically created using io-500-gen.sh generator
# Any modifications (below this line) will be lost if io-500-gen.sh is run again
# However, you may modify/tune this script manually or modify the generator to create an improved io-500.sh
# Put your batch submission commands QSUB | PBS -n XX

echo
io500_info_institution=""

echo
echo -n [START TIME] 
date --rfc-3339=seconds

echo
echo [IOR EASY WRITE]
mkdir -p ./io500-datadir//ior_easy ./io500-datadir//ior_hard ./io500-datadir//mdt_hard ./io500-datadir//mdt_easy ./io500-datadir//pfind_results
# Please add here additional scripts to setup/prepare the directories like lfs setstripe
mpiexec -np 2 ./bin//ior -w -C -Q 1 -g -G 27 -k -e -t 2048k -b 2m -F -o ./io500-datadir//ior_easy/ior_file_easy -O stoneWallingStatusFile=./io500-datadir//ior_easy/stonewall -O stoneWallingWearOut=1 -D 10

echo
echo [MDTEST EASY WRITE]
mpiexec -np 2 ./bin//mdtest -C -F -d ./io500-datadir//mdt_easy -n 250 -u -L -x ./io500-datadir//mdt_easy-stonewall -W 10

echo
echo [CREATING TIMESTAMP]
touch ./io500-datadir//timestampfile

echo
echo [IOR HARD WRITE]
mpiexec -np 2 ./bin//ior -w -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s 100 -o ./io500-datadir//ior_hard/IOR_file -O stoneWallingStatusFile=./io500-datadir//ior_hard/stonewall -O stoneWallingWearOut=1 -D 10

echo
echo [MDTEST HARD WRITE]
mpiexec -np 2 ./bin//mdtest -C -t -F -w 3901 -e 3901 -d ./io500-datadir//mdt_hard -n 150 -x ./io500-datadir//mdt_hard-stonewall -W 10

echo
echo [PFIND EASY]
# You may change the pfind command!
mpiexec -np 2 ./bin//pfind ./io500-datadir/ -newer ./io500-datadir//timestampfile -size 3901c -name *01* -s 10 -C -P -D rates

echo
echo [IOR EASY READ]
mpiexec -np 2 ./bin//ior -r -R -C -Q 1 -g -G 27 -k -e -t 2048k -b 2m -F -o ./io500-datadir//ior_easy/ior_file_easy -O stoneWallingStatusFile=./io500-datadir//ior_easy/stonewall

echo
echo [MDTEST EASY STAT]
mpiexec -np 2 ./bin//mdtest -T -F -d ./io500-datadir//mdt_easy -n 250 -u -L -x ./io500-datadir//mdt_easy-stonewall

echo
echo [IOR HARD READ]
mpiexec -np 2 ./bin//ior -r -R -C -Q 1 -g -G 27 -k -e -t 47008 -b 47008 -s 100 -o ./io500-datadir//ior_hard/IOR_file -O stoneWallingStatusFile=./io500-datadir//ior_hard/stonewall

echo
echo [MDTEST HARD STAT]
mpiexec -np 2 ./bin//mdtest -T -t -F -w 3901 -e 3901 -d ./io500-datadir//mdt_hard -n 150 -x ./io500-datadir//mdt_hard-stonewall

echo
echo [MDTEST EASY DELETE]
mpiexec -np 2 ./bin//mdtest -r -F -d ./io500-datadir//mdt_easy -n 250 -u -L -x ./io500-datadir//mdt_easy-stonewall

echo
echo [MDTEST HARD READ]
mpiexec -np 2 ./bin//mdtest -E -t -F -w 3901 -e 3901 -d ./io500-datadir//mdt_hard -n 150 -x ./io500-datadir//mdt_hard-stonewall

echo
echo [MDTEST HARD DELETE]
mpiexec -np 2 ./bin//mdtest -r -t -F -w 3901 -e 3901 -d ./io500-datadir//mdt_hard -n 150 -x ./io500-datadir//mdt_hard-stonewall

echo
echo -n [END TIME]
date --rfc-3339=seconds
echo [IO-500 COMPLETED] Now use io-500-score.sh to compute the score!
