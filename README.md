#studyforrest_dFC

OVERVIEW

Comparison of dFC vs ROI timeseries activity for scene classification.
This dataset utilises the publicy available data from the studyforrest project (studyforrest.org).
MRI volume-to-surface transformations followed the default recon-all pipeline as implemented in Freesurfer 5.3.0.
MRI functional preprocessing followed the preprocessing pipeline created by CBIG (https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/preprocessing/CBIG_fMRI_Preproc2016).
XGBoost in Python 3.7 API was used for modelling/prediction. 

MAIN FINDING

Summary of methods and results are in the Summary.pptx and Summary.pdf file.

DATA FILES
1. PCA_TitleData_min10.csv - Data containing the first 284 PCAs (which account for 99% of the explained variance) of dFC data.
2. timeseries_data_min10.csv - Data containing the timeseries activity across 419 regions as delineated by Schaefer et al 2018 and Freesurfer's subcortical maps.

FOLDERS
1. annotations - "movie_scenes.xlsx" file contains annotations of movie scenes by timestamp, as provided by Labs2015 (see "reference.txt")
2. descriptives - files containing descriptions relevant to the data, as well as a subfolder containing video files plotting the dFC (averaged across participants) for each scanning run.
3. model_PCA - folder contains python script, results, and classification reports for the XGBoost modelling of PCs, with the final model trained on all data saved as "trained_model.dat" and the feature importances saved as "feature_importances.csv". The subfolder "vary_PC" contains the scripts and results. The "run.sh" files in the main folder and subfolder were for job submissions to the TORQUE scheduler.
4. model_timeseries - folder contains python script, results, and classification reports for the XGBoost modelling of ROI timeseries. As before, the "run.sh" file was for job submission to the TORQUE scheduler.
5. PCA - contains the coefficients ("coefficients.txt"), scores ("score.txt"), means ("mu.csv") and explained variances ("explained_variance.csv") of the PCA conducted on the full (3,077 by 87,571) dataset, before any corrections. Subfolder "Plots" also contains plots of feature weights of each ROI-to-ROI connection, either in full (top100) or thresholded to the top 10% of absolute weights (top10). Note that due to the large size of the coefficients and scores files, these two CSV files are hosted on dropbox, with the links to each in their respective text file.

OTHER FILES
1. analysis.m - MATLAB file used to prepare the data for the dFC vs timeseries comparison. Just for methodological reference, not functional.
2. n_PCs.xlsx - excel file plotting the accuracy and F1 scores of XGB modelling across varying numbers of PCs.

