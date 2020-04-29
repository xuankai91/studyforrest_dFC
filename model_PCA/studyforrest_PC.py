#!/usr/bin/env python
# coding: utf-8

def model(i,seed,n_estimators = 100,kn=5,test_size=0.2):
  '''
  inputs:
    i: iteration number
    seed: rng seed for replicability.
    n_estimators: how many trees for model to run, default 100.
    kn: k-neighbors for SMOTE to generate synthetic training data, default 5.
    test_size: test size for train-test split, train will be 1-test_size, default 0.2.
  '''

  import os
  import pandas as pd
  import numpy as np
  import xgboost as XGB
  import pickle
  
  from sklearn.model_selection import train_test_split, GridSearchCV
  from imblearn.over_sampling import SMOTE 
  from sklearn.metrics import accuracy_score, precision_score, recall_score, classification_report
  
  print('modules imported')
  
  #root
  filepath = "C:\Users\Xuan Kai\studyforrest_dFC\model_PCA"
  
  #classrep path
  classrep_path = filepath + '\classreps_k%d' % kn
  
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
  
  #print('seed, accuracy, precision, recall\n')
  results_file = filepath + '\result_k%d.csv' % kn
  
  if not os.path.exists(results_file):
    fo = open(results_file,"w+")
    fo.write('run,seed,accuracy,precision,recall,ntree_limit\n')
    fo.close()
   
  #start modelling
  try:
    #train test split
    X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=test_size,stratify=df.Scene,random_state=seed)

    #balance data
    sm = SMOTE(random_state = seed,k_neighbors=kn)
    X_train_new, y_train_new = sm.fit_sample(X_train,y_train)
            
    #get baseline (pre-tuned) results
    baseline = clf.fit(X_train_new,y_train_new,early_stopping_rounds=5, eval_metric='merror', eval_set=[(X_test, y_test)], verbose=False)
    baseline_preds = baseline.predict(X_test)
    
    baseline_acc = accuracy_score(y_test,baseline_preds)
    baseline_precision = precision_score(y_test,baseline_preds,average='macro')
    baseline_recall = recall_score(y_test,baseline_preds,average='macro')
    baseline_class_rep = classification_report(y_test,baseline_preds)
    
    fo = open(results_file,"a")
    fo.write('%d,%d,%s,%s,%s,%d\n' % (i,seed,round(baseline_acc,4),round(baseline_precision,4),round(baseline_recall,4),baseline.best_ntree_limit))
    fo.close()
    
    f = open(classrep_path + '\baseline_split%d.txt' % i,"w+")
    f.write('X train: ' + str(X_train.shape) + ', X test: ' + str(X_test.shape) + '\n\n')
    f.write('Seed: ' + str(seed) + '\n\n')
    f.write('Baseline model: XGBClassifier with n_estimators=%d\n' % n_estimators)
    f.write('Tree limit: %d\n\n' % baseline.best_ntree_limit)
    f.write('Accuracy: ' + str(baseline_acc) + '\n\n')
    f.write(baseline_class_rep)
    f.close()
    
    print('run %d accuracy: ' % i + str(baseline_acc))
    print('run %d: calculations completed.\n\n' % i)
    
  except Exception as e:
    print('Exception occurred at loop %d, seed %d.\n' % (i, seed))
    print(e)
    print('\n')
    
    f = open(classrep_path + '\baseline_split%d.txt' % i,"w+")
    f.write('Seed: ' + str(seed) + '\n\n')
    f.write(str(e))
    f.close()
      
    fo = open(results_file,"a")
    fo.write(str(i) + ',' + str(seed) + ',NaN,NaN,NaN,NaN\n')
    fo.close()