#!/usr/bin/env python
# coding: utf-8

import os
import pandas as pd
import numpy as np
import xgboost as XGB
import pickle

from imblearn.over_sampling import SMOTE 

print('modules imported')

n_estimators = 30 #N trees, get max value from training results
kn=5 #k_neighbors for SMOTE

seed = np.random.randint(1,1000,size=1)[0]

df = pd.read_csv("C:\Users\Xuan Kai\studyforrest_dFC\PCA_TitledData_min10.csv",index_col=0)
print('data loaded.')

#generate feature/target
y = df.Scene
X = df.drop(['Scene','Run'],axis=1)
print('Feature and target matrices generated. \n')

clf = XGB.XGBClassifier(objective='multi:softmax',n_estimators=n_estimators,n_jobs=-1)
print('XGBClassifier model instantiated.')

sm = SMOTE(random_state = seed,k_neighbors=kn)
X_train_new, y_train_new = sm.fit_sample(X,y)

model = clf.fit(X_train_new,y_train_new)

pickle.dump(model, open("trained_model.dat", "wb"))
print('model saved.')

idx =(-clf.feature_importances_).argsort()

f = open('feature_importances.csv',"w+")
for i in range (len(idx)):
  f.write('%d\n' % idx[i])
f.close()

print('feature importances saved.')