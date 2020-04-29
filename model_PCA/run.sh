#!/bin/bash

#cmd="source activate base; python /data/users/xklee/storage/studyforrest/model_PCA/PC_only/studyforrest_PC.py"
#
#echo $cmd | $CBIG_SCHEDULER_DIR/qsub -V -q circ-spool -l walltime=6:00:00,mem=36GB,nodes=1:ppn=10 -m ae \
#		  -N XGB_baselines_PConly
        
workdir="/data/users/xklee/storage/studyforrest/model_PCA/PC_only/"

random_seeds=($(shuf -i 0-999 -n 50))

#for i in {0..24}; do 	
for i in {25..49}; do 	

  seed="${random_seeds[${i}]}"
  
  cmd="source activate base; python -c \"import sys; sys.path.insert(1, '$workdir'); import studyforrest_PC; studyforrest_PC.model(i=${i},seed=${seed}); exit()\""
  #cmd="source activate base; python -c \"import os; os.chdir('$workdir'); import studyforrest_TS; studyforrest_TS.model(loops=${i},seed=${seed}); exit()\""
  
  echo $cmd | $CBIG_SCHEDULER_DIR/qsub -V -q circ-spool -l walltime=1:00:00,mem=12GB,nodes=1:ppn=5 -m ae \
  		  -N XGB_baselines_PConly_run${i} -d $workdir      
  
done

