# Pipeline for flow cytometry analysis

This is a pipeline for merging, transforming, normalizing and visualizing flow cytometry data acquired on the LSR II / Symphony.
The input is csv files exported in scale value from FlowJo software. The output is normalized and transformed matrices for each acquisition channel,
as well as UMAP plots.

Your directory hierarchy should contain files similar to this:

```bash
Parent 
  ├── Flow folder 1 (CONTAINS REFERENCE BEADS)
  │    ├── Beads.csv
  │    ├── folder_1_csv1.csv
  │    ├── folder_1_csv2.csv
  │    └── folder_1_csv3.csv
  │
  ├── Flow folder 2
  │    ├── Beads.csv
  │    ├── folder_2_csv1.csv
  │    ├── folder_2_csv2.csv
  │    └── folder_2_csv3.csv
  │
  └── Flow folder 3 
       ├── Beads.csv
       ├── folder_3_csv1.csv
       ├── folder_3_csv2.csv
       └── folder_3_csv3.csv
```
