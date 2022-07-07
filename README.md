# Pipeline for flow cytometry analysis

This is a pipeline for merging, normalizing, transforming and visualizing flow cytometry data in R. This pipeline allows you to merge and normalize flow cytometry data collected across different acquisition days/timepoints (up to 3 different days/timepoints, though I am working on expanding this!). 

The input is csv files which are exported in **scale value** from FlowJo software. The output is normalized and transformed matrices for each flow cytometry channel, as well as UMAP plots.


## A note before starting

To begin, your directory hierarchy should look similar to this (although, if normalization is not needed, then the Beads.csv files are not required). Each tube acquired by flow should be exported in **scale value** from FlowJo (flow_sample_X.csv) and should be contained in a folder with all other samples collected on that day.


```
Parent 
  ├── Flow data collected on day 1
  │    ├── Beads.csv
  │    ├── flow_sample_1.csv
  │    ├── flow_sample_2.csv
  │    └── flow_sample_3.csv
  │
  ├── Flow data collected on day 2
  │    ├── Beads.csv
  │    ├── flow_sample_1.csv
  │    ├── flow_sample_2.csv
  │    └── flow_sample_3.csv
  │
  └── Flow data collected on day 3 
       ├── Beads.csv
       ├── folder_3_csv1.csv
       ├── folder_3_csv2.csv
       └── folder_3_csv3.csv
```


## Analyzing your data 

Once you have acquired your flow cytometry data and organized it as outlined above, you can execute 3 functions which will perform different normalization and transformation tasks. In order, these include ```cytoNorm```, ```cytoTrans```, and ```cytoUMAP```. 


