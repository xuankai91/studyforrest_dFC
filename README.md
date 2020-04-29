#studyforrest_dFC

OVERVIEW

Comparison of dFC vs ROI timeseries activity for scene classification
This dataset utilises the publicy available data from the studyforrest project (studyforrest.org).
MRI volume-to-surface transformations followed the default recon-all pipeline as implemented in Freesurfer 5.3.0.
MRI functional preprocessing followed the preprocessing pipeline created by CBIG (https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/preprocessing/CBIG_fMRI_Preproc2016).
XGBoost in Python API was used for modelling/prediction. 

DATA PREPARATION

MODELLING

DATA FILES
1. PCA_TitleData_min10.csv - Data containing the first 284 PCAs (which account for 99% of the explained variance) of dFC data.
2. timeseries_data_min10.csv - Data containing the timeseries activity across 419 regions as delineated by Schaefer et al 2018 and Freesurfer's subcortical maps.

FOLDERS
1. PCA - contains the coefficients (coefficients.csv), scores (score.csv), means (mu.csv) and explained variances (explained_variance.csv) of the PCA conducted on the full (3,077 by 87,571) dataset, before any corrections. Also contains plots of feature weights of each ROI-to-ROI connection, either in full (top100) or thresholded to the top 10% of absolute weights (top10)

OTHER FILES
1. analysis.m - MATLAB file used to prepare the data for the dFC vs timeseries comparison. Just for methodological reference, not functional.

