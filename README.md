# Pipeline for flow cytometry analysis

This is a pipeline for merging, normalizing, transforming and visualizing flow cytometry data in R. This pipeline allows you to merge and normalize flow cytometry data collected across different acquisition timepoints (currently up to 3 different timepoints, though I am working on expanding this!). 

The input is csv files which are exported in **scale value** from FlowJo software. The output is normalized and transformed matrices for each flow cytometry channel, as well as UMAP plots.


## A note before starting

To begin, your directory hierarchy should look similar to this. Each tube acquired by flow should be exported in **scale value** from FlowJo (flow_sample_X.csv) and should be contained in a folder with all other samples collected on that day. 

*NOTE: if normalization is not needed, then the Beads.csv files acquired at each timepoint are not required).*


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

## Input file format 

Your data should be exported as scale values from FlowJo. This should generate a csv file which contains rows as single cells and columns as flow cytometry channels. 

## Getting started

Once you have acquired your flow cytometry data and organized it as outlined above, you can execute 3 functions which will perform different normalization and transformation tasks. In order, these include ```cytoNorm```, ```cytoTrans```, and ```cytoUMAP```. 

```
FSC-A	FSC-H	FSC-W	SSC-A	SSC-H	SSC-W	CD8-APC
38575.1	38344.6	104623	22137.9	19825.3	84172.8	9.34196
28336.9	27103.6	100493	13685.1	12352.3	75985.5	19.9199
27329.4	26415.7	100240	21901.7	20629.2	79034.8	34.0306
```




