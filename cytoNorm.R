# this function calculates a per-channel normalization factor for each acquisition timepoint. 

cytoNorm <- function(ref_bead_foldername, 
                     bead_foldername, 
                     bead_foldername2 = NULL) { 
  
  # read in ref beads 
  beads.ref <- read.csv(here(ref_bead_foldername, "Beads.csv")) %>% 
    select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  
  # read in beads to be normalized
  beads.1 <- read.csv(here(bead_foldername, "Beads.csv")) %>% 
    select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  
  # this is only run if there is an additional bead dataset to be normalized
  if(!is.null(bead_foldername2)){
    beads.2 <- read.csv(here(bead_foldername2, "Beads.csv")) %>%  
      select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  }
  
  else if(is.null(bead_foldername2)){
    beads.2 <- NULL
  }
  
  # rename beads according to parent directory
  bead.sum <- list(ref_bead_foldername = beads.ref, 
                   bead_foldername = beads.1,
                   bead_foldername2 = beads.2)
  
  bead.sum <- setNames(bead.sum, c(ref_bead_foldername, bead_foldername, bead_foldername2))
  
  # calculate median for each channel
  med <- do.call(rbind, lapply(bead.sum, function(d) data.frame(med = lapply(d,median))))
  
  # calculate normalization factor
  norm.fact <- as.data.frame(sapply(med, FUN = function(x) x[1]/x))  
  norm.fact$Well <- "Beads"
  norm.fact$Folder <- row.names(med)
  
  # export normalization factors to envir 
  assign(x = "norm.fact", value = norm.fact, envir = parent.frame())
  
}
