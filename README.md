# Pipeline for flow cytometry analysis

This is a pipeline for merging, normalizing, transforming and visualizing flow cytometry data in R. This pipeline allows you to merge and normalize flow cytometry data collected across different acquisition timepoints. 

The input is csv files (gated on Viable cells) which are exported in **scale value** from FlowJo software. The output is normalized and transformed matrices for each flow cytometry channel, as well as UMAP plots.



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

To begin, your directory hierarchy should look similar to this. Viable cells for each sample acquired by flow should be exported in **scale value** from FlowJo (flow_sample_X.csv) and should be contained in a folder with all other samples collected on that day. 

**NOTE:** if normalization is not needed, then the `Beads.csv` files acquired at each timepoint are not required). However, if you choose to normalize your data, the bead data must be saved as `Beads.csv`, and there must be one `Beads.csv` file per acquisition folder.

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

Once you have acquired your flow cytometry data and organized it as outlined above, you can execute 3 functions which will perform different normalization and transformation tasks. In order, these include ```cytoNorm```, ```cytoTrans```, and ```cytoUMAP```. Sample data to run the analysis can be found in the `Parent` folder of this repository.

**NOTE:** If normalization is not required, then the ```cytoNorm``` function does not need to be run.


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

3. Run the full analysis (normalization, transformation and plotting) using flow cytometry data from multiple different timepoints. Make sure that you `setwd()` as the Parent directory (see <a href="#directory-hierarchy">Directory hierarchy</a> above).

```
cytoNorm(ref_bead_foldername = "day1",
         plot_norm = TRUE,
         exclude = NULL)

cytoTrans(normalize = TRUE, 
          plot_norm = FALSE,
          exclude = NULL)
          
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

This function reads the `Beads.csv` file stored on each acquisition day and generates a per-channel normalization factor based on sample median. The normalization beads should have been stained with the same flow cytometry mastermix for each sample, and thus the csv file should have the same column names as your samples. **NOTE:** In order for your bead file to be recognized, it must be saved as `Beads.csv`. 

Normalization is not performed on non-fluorescent parameters (i.e., FSC, SSC, or Time parameters). Normalization will not be performed on viability dyes provided that they were labelled as "DAPI", "Live", or "Viability" during the sample acquisition steps. Specific channels can also be removed (see `exclude` in the parameters below.)


#### Parameters

* `ref_bead_foldername` a character vector of the folder name containing the first acquisition timepoint (which will be used for normalization)

* `plot_norm` a logical value. If TRUE, normalized and unnormalized histograms will be produced for each channel and for each sample. Default is FALSE.

* `exclude` a character vector of the channels you wish to exclude. For example c("CD8","CD7") will remove channels containing CD8 or CD7 in the channel name. 


#### Examples 

An example of the output for a few channels is shown below.

![CD1a normalization](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/Bead-normalization/CD1a_norm.png)
![CD13 normalization](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/Bead-normalization/CD13_norm.png)


### 2. arcsinh transformation with ```cytoTrans```

This function reads each csv file containing the exported flow cytometry data and merges each file according to the acquisition timepoint. Optional per-channel normalization will be performed if required. Arcsinh transformation (from the `flowCore` package) will also be performed. Specific channels may be removed from the UMAP plot using the `exclude` parameter as described below. By default, non-fluorescent channels such as FSC, SSC and Time are removed. Viability dyes are also removed provided that they are labelled as "DAPI", "Live", or "Viability".

#### Parameters 

* `normalize` a logical value. If TRUE, per-channel normalization will be performed. Default is FALSE. Can only be run if cytoNorm was performed.

* `plot_norm` a logical value. If TRUE, normalized and unnormalized histograms will be produced for each channel and for each sample. Default is FALSE. 

* `exclude` *(optional)* a character vector of the channels you wish to exclude from the UMAP plot. For example c("CD8","CD7") will remove channels containing CD8 or CD7 in the channel name. Note that this is not required if already specified when running cytoNorm. 

### 3. Visualization with ```cytoUMAP```

This function runs UMAP (from the `uwot` package) using the specified range of neighbours and the minimum neighbour distance. The output are UMAP plots in a new folder within the Parent directory called `Neighbour_plots`. **NOTE:** downsampling is highly recommended for large (i.e., >20,000 events) datasets.


#### Parameters 

* `min_nn` an integer indicating the minimum number of neighbours. min_nn must be >= 2.

* `max_nn` an integer indicating the maximum number of neighbours. 

* `interval` an integer indicating the intervals to test between min_nn and max_nn. For example, if min_nn = 50, max_nn = 100, and interval = 10, then 5 plots will be generated indicating 50, 60, 70, 80, 90, and 100 neighbours.

* `min_dist` an integer indicating the minimum neighbour distance. Value must be > 0. 

* `downsample` an integer indicating the number of cells to downsample on (performed per sample). Recommended for large datasets.


#### Examples

In this example, day 2 is plotted alongside data from day 1. The day 2 data contains T-cell and myeloid populations, whereas the day 1 data only contains T-cell populations. Here's what the UMAP looks like when parsed by Sample:

![Sample UMAP](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/UMAP-plots/Sample_UMAP.png)

And now looking at the same plots coloured according to CD marker expression:

![CD7 UMAP](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/UMAP-plots/CD7_UMAP.png)
![CD5 UMAP](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/UMAP-plots/CD5_UMAP.png)
![CD13 UMAP](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/UMAP-plots/CD13_UMAP.png)
![CD33 UMAP](https://github.com/rachwo/Flow-pipeline/blob/main/Example-of-output/UMAP-plots/CD33_UMAP.png)

<p align="right">(<a href="#top">back to top</a>)</p>



## Contact 

Rachel Wong - rwong[at]bccrc.ca





