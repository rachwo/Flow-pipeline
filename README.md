# Pipeline for flow cytometry analysis

This is a pipeline for merging, normalizing, transforming and visualizing flow cytometry data in R. This pipeline allows you to merge and normalize flow cytometry data collected across different acquisition timepoints (currently up to 3 different timepoints, though I am working on expanding this!). 

The input is csv files which are exported in **scale value** from FlowJo software. The output is normalized and transformed matrices for each flow cytometry channel, as well as UMAP plots.



## Table of Contents 
<ol>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#directory-hierarchy">Directory hierarchy</a></li>
        <li><a href="#r-packages">Required R packages</a></li>
        <li><a href="#input-file-format">Input file format</a></li>
      </ul>
    </li>
    <li><a href="#quick-start-guide">Quick start guide</a></li>
    <li>
      <a href="#running-the-analysis">Running the analysis</a>
      <ul>
        <li><a href="#1-sample-normalization-with-cytonorm-optional">cytoNorm</a></li>
        <li><a href="#2-arcsinh-transformation-with-cytotrans">cytoTrans</a></li>
        <li><a href="#3-Visualization-with-cytoUMAP">cytoUMAP</a></li>
      </ul>
    </li>
    <li><a href="#Added-functions">Functions to add</a></li>
    <li><a href="#contact">Contact</a></li>
    </ol>



## Getting started

### Directory hierarchy

To begin, your directory hierarchy should look similar to this. Each tube acquired by flow should be exported in **scale value** from FlowJo (flow_sample_X.csv) and should be contained in a folder with all other samples collected on that day. 

*NOTE: if normalization is not needed, then the `Beads.csv` files acquired at each timepoint are not required). However, if you choose to normalize your data, the bead data must be saved as `Beads.csv`, and there must be one `Beads.csv` file per acquisition folder

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

<p align="right">(<a href="#top">back to top</a>)</p>



## Quick start guide

Once you have acquired your flow cytometry data and organized it as outlined above, you can execute 3 functions which will perform different normalization and transformation tasks. In order, these include ```cytoNorm```, ```cytoTrans```, and ```cytoUMAP```. Sample data to run the analysis can be found in the `Parent` folder.

*NOTE: If normalization is not required, then the* ```cytoNorm``` *function does not need to be run*


### Here is an example of how to run the analysis:

1. Load the required packages:

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

2. Load the source code:

```
source("cytoNorm")
source("cytoTrans")
source("cytoUMAP")
```

3. Run the full analysis (normalization, transformation and plotting) using flow cytometry data from 3 different timepoints. Make sure that you `setwd()` as the Parent directory (see <a href="#directory-hierarchy">Directory hierarchy</a> above).

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

<p align="right">(<a href="#top">back to top</a>)</p>



## Running the analysis

### 1. Sample normalization with ```cytoNorm``` *(optional)*

This function reads the `Beads.csv` file stored on each acquisition day and generates a per-channel normalization factor based on sample median. The normalization beads should have been stained with the same flow cytometry mastermix for each sample, and thus the csv file should have the same column names as your samples. *NOTE: In order for your bead file to be recognized, it must be saved as* `Beads.csv`. 

Normalization is not performed on FSC, SSC, or Time parameters. Normalization will not be performed on viability dyes provided that they were labelled as "DAPI" or "Live" during sample acquisition.


#### Parameters

* `ref_bead_foldername` a character vector of the folder name containing the first acquisition timepoint (which will be used for normalization)

* `bead_foldername` a character vector of the folder name containing the second acquisition timepoint (which will be normalized)

* `bead_foldername2` *(optional)* a character vector of the folder name containing the third acquisition timepoint (which will be normalized) 



### 2. arcsinh transformation with ```cytoTrans```

This function reads each csv file containing the exported flow cytometry data and merges each file according to the acquisition timepoint. Optional per-channel normalization will be performed if required. Arcsinh transformation (from the `flowCore` package) will also be performed. 

#### Parameters 

* `ref_flow_foldername` a character vector of the folder name containing the first acquisition timepoint

* `flow_foldername_1` a character vector of the folder name containing the second acquisition timepoint

* `flow_foldername_2` *(optional)* the name of the folder containing the third acquisition timepoint

* `normalize` a logical value. If TRUE, per-channel normalization will be performed. Default is FALSE. Can only be run if cytoNorm was performed.

* `plot_norm` a logical value. If TRUE, normalized and unnormalized histograms will be produced for each channel and for each sample. Default is FALSE. 



### 3. Visualization with ```cytoUMAP```

This function runs UMAP (from the `uwot` package) using the specified range of neighbours and the minimum neighbour distance. The output are UMAP plots in a new folder within the Parent directory called `Neighbour_plots`. **NOTE: downsampling is highly recommended for large (i.e., >20,000 events) datasets.**

#### Parameters 

* `min_nn` an integer indicating the minimum number of neighbours. min_nn must be >= 2.

* `max_nn` an integer indicating the maximum number of neighbours. 

* `interval` an integer indicating the intervals to test between min_nn and max_nn. For example, if min_nn = 50, max_nn = 100, and interval = 10, then 5 plots will be generated indicating 50, 60, 70, 80, 90, and 100 neighbours.

* `min_dist` an integer indicating the minimum neighbour distance. Value must be > 0. 

* `downsample` an integer indicating the number of cells to downsample on (performed per sample). Recommended for large datasets.


<p align="right">(<a href="#top">back to top</a>)</p>



## Added functions 

Some things I am planning on adding to make the functions more widely applicable: 

* Create user-defined channels to exclude from normalization 
* Increase the number of timepoints (>3) that can be analyzed
* Make more user friendly (eg, produce error if Beads.csv does not match sample csv)




## Contact 

Rachel Wong - rwong[at]bccrc.ca





