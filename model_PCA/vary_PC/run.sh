#!/bin/bash

workdir="C:\Users\Xuan Kai\studyforrest_dFC\model_PCA\vary_PC"

random_seeds=($(shuf -i 0-999 -n 100))

steps=1 #10
spc=1 
epc=20 #281

for i in {0..49}; do 	

  seed="${random_seeds[${i}]}"
  
  cmd="source activate base; python -c \"import sys; sys.path.insert(1, '$workdir'); import studyforrest_vary_PC; studyforrest_vary_PC.model(i=${i},seed=${seed},steps=${steps},spc=${spc},epc=${epc}); exit()\""
  
  echo $cmd | $CBIG_SCHEDULER_DIR/qsub -V -q circ-spool -l walltime=3:00:00,mem=24GB,nodes=1:ppn=10 -m ae \
  		  -N XGB_baselines_vary_PC_run${i} -d $workdir      
  
done

