#!/bin/bash

workdir="/data/users/xklee/storage/studyforrest/model_timeseries/"

random_seeds=($(shuf -i 0-999 -n 50))

#for i in {0..24}; do 	
for i in {25..49}; do 	

  seed="${random_seeds[${i}]}"
  
  cmd="source activate base; python -c \"import sys; sys.path.insert(1, '$workdir'); import studyforrest_TS; studyforrest_TS.model(loops=${i},seed=${seed}); exit()\""
  #cmd="source activate base; python -c \"import os; os.chdir('$workdir'); import studyforrest_TS; studyforrest_TS.model(loops=${i},seed=${seed}); exit()\""
  
  echo $cmd | $CBIG_SCHEDULER_DIR/qsub -V -q circ-spool -l walltime=3:00:00,mem=12GB -m ae \
  		  -N XGB_baselines_timeseries_loop${i} -d $workdir      
  
done

#for i in {48..49}; do seed="${random_seeds[$i]}"; echo $seed; done
        