# Pipeline for flow cytometry analysis

This is a pipeline for merging, normalizing, transforming and visualizing flow cytometry data in R. This pipeline allows you to merge and normalize flow cytometry data collected across different acquisition timepoints (currently up to 3 different timepoints, though I am working on expanding this!). 

The input is csv files which are exported in **scale value** from FlowJo software. The output is normalized and transformed matrices for each flow cytometry channel, as well as UMAP plots.


## A few notes before starting

### Directory hierarchy

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

### R packages 

In addition, the following R packages are required: 

```
library(dplyr)
library(tidyr)
library(flowCore)
library(doParallel)
library(uwot)
library(ggplot2)
library(ggridges)
library(here)
library(ggridges)
```

### Input file format 

Your data should be exported as scale values from FlowJo. This should generate a csv file which contains rows as single cells and columns as flow cytometry channels. 

```
FSC-A	FSC-H	FSC-W	SSC-A	SSC-H	SSC-W	CD8-APC
38575.1	38344.6	104623	22137.9	19825.3	84172.8	9.34196
28336.9	27103.6	100493	13685.1	12352.3	75985.5	19.9199
27329.4	26415.7	100240	21901.7	20629.2	79034.8	34.0306
```

# Quick start guide

Once you have acquired your flow cytometry data and organized it as outlined above, you can execute 3 functions which will perform different normalization and transformation tasks. In order, these include ```cytoNorm```, ```cytoTrans```, and ```cytoUMAP```. 

*NOTE: If normalization is not required, then the ```cytoNorm``` function does not need to be run*

Here is an example of how to run the analysis:

Load the required packages:

```
library(dplyr)
library(tidyr)
library(flowCore)
library(doParallel)
library(uwot)
library(ggplot2)
library(ggridges)
library(here)
library(ggridges)
```

Running the full analysis (normalization, transformation and plotting) using flow cytometry data from 3 different timepoints:

```
cytoNorm(ref_bead_foldername = "day1",
         bead_foldername = "day2",
         bead_foldername2 = "day3")

cytoTrans(ref_flow_foldername = "day1",
          flow_foldername_1 = "day2",
          flow_foldername_2 = "day3",
          normalize = TRUE, 
          plot_norm = TRUE)
          
cytoUMAP(min_nn = 50,
         max_nn = 100,
         interval = 10,
         min_dist = 0.1,
         downsample = 100)
```

This will generate a new folder ```Neighbour_plots``` which will contain several UMAP plots iterated over a range of specified numbers of neighbours for the user-defined minimum distance. 


# Running the analysis

## Sample normalization with ```cytoNorm``` *(optional)*

This function reads the Bead.csv file stored on each acquisition day and generates a per-channel normalization factor based on sample median. The normalization beads should have been stained with the same flow cytometry mastermix for each sample, and thus the csv file should have the same column names as your samples. 

### Parameters

`ref_bead_foldername` the name of the folder containing the first acquisition timepoint (which will be used for normalization)
`bead_foldername` the name of the folder containing the second acquisition timepoint (which will be normalized)
`bead_foldername2` *(optional)* the name of the folder containing the third acquisition timepoint (which will be normalized) 










