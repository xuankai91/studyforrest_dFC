#!/usr/bin/env python
# coding: utf-8

def model(i,seed,steps,spc,epc,n_estimators=100,kn=5,test_size=0.2):
  '''
  input
    i: iteration number.
    seed:  rng seed for replicability.
    steps: intervals to test range of PCs (integer)
    spc: start range of PCs to test (integer)
    epc: end range of PCs to test (integer)
    n_estimators: how many trees for model to run, default 100.
    kn: k-neighbors for SMOTE to generate synthetic training data, default 5.
    test_size: test size for train-test split, train will be 1-test_size, default 0.2.

    classrep paths 
  '''

  import os
  import pandas as pd
  import numpy as np
  import xgboost as XGB
  import pickle
  
  from sklearn.model_selection import train_test_split, GridSearchCV
  from imblearn.over_sampling import SMOTE 
  from sklearn.metrics import accuracy_score, f1_score
  
  print('modules imported')
    
  #root
  filepath = 'C:\Users\Xuan Kai\studyforrest_dFC\model_PCA\vary_PC'
  
  #classrep path (just using as a stand in for error reports, classification reports are not actually generated)
  classrep_path = filepath + '\classreps_k%d\' % kn
  
  if not os.path.exists(classrep_path):
      os.makedirs(classrep_path)
  
  #load data
  df = pd.read_csv("C:\Users\Xuan Kai\studyforrest_dFC\PCA_TitledData_min10.csv",index_col=0)
  print('data loaded.')
  
  #generate feature/target
  y = df.Scene
  X = df.drop(['Scene','Run'],axis=1)
  print('Feature and target matrices generated. \n')
  
  #train model
  clf = XGB.XGBClassifier(objective='multi:softmax',n_estimators=n_estimators,n_jobs=-1)
  print('XGBClassifier model instantiated.')
  
  #get range of PCs to test  
  PC_totest = list(range(spc,epc,steps)) #defined in function
  PC_totest.append(284) #99% PC for comparison
  
  #print('seed, accuracy, precision, recall\n')
  results_file = filepath + '\result_vary_PC_k%d_%dto%d.csv' % (kn,spc,epc)
  
  if not os.path.exists(results_file):
    fo = open(results_file,"w+")
    fo.write('run,seed,')
    for p in range(len(PC_totest)):
      fo.write('%d,' % PC_totest[p])
    fo.write('\n')
    fo.close()
    
  f1_results_file = filepath + '\result_f1_vary_PC_k%d_%dto%d.csv' % (kn,spc,epc)
  if not os.path.exists(f1_results_file):
    f1r = open(f1_results_file,"w+")
    f1r.write('run,seed,')
    for p in range(len(PC_totest)):
      f1r.write('%d,' % PC_totest[p])
    f1r.write('\n')
    f1r.close()
  
  #train test split
  X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=test_size,stratify=y,random_state=seed)
  
  #balance data
  sm = SMOTE(random_state = seed,k_neighbors=kn)
  
  record = '%d,%d,' % (i,seed)
  f1_record = '%d,%d,' % (i,seed)
  
  for PC in PC_totest:
    try:
    
      X_train_new, y_train_new = sm.fit_sample(X_train.iloc[:,range(PC)],y_train)
      
      eval_X = X_test.iloc[:,range(PC)]
      ##get baseline (pre-tuned) results
      baseline = clf.fit(X_train_new,y_train_new,early_stopping_rounds=5, eval_metric='merror', eval_set=[(eval_X, y_test)], verbose=False)
      baseline_preds = baseline.predict(eval_X)
    
      baseline_acc = accuracy_score(y_test,baseline_preds)
      baseline_f1 = f1_score(y_test,baseline_preds,average='macro')
      
      record += str(round(baseline_acc,4)) + ','
      f1_record += str(round(baseline_f1,4)) + ','
    
      print('run %d, %d PCs accuracy: ' % (i,PC) + str(baseline_acc) + ', f1-score: ' +  str(baseline_f1))
      #print('run %d: calculations completed.\n\n' % i)
    
    except Exception as e:
      print('Exception occurred at run %d, seed %d, %d PCs.\n' % (i, seed, PC))
      print(e)
      print('\n')
    
      f = open(classrep_path + 'baseline_run%d_PC%d_error.txt' % (i,PC),"w+")
      f.write('Seed: ' + str(seed) + '\n\n')
      f.write(str(e))
      f.close()
  
  fo = open(results_file,"a")
  fo.write(record + '\n')
  fo.close()
  
  f1r = open(f1_results_file,"a")
  f1r.write(f1_record + '\n')
  f1r.close()
    