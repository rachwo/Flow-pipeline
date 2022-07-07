# this function calculates a per-channel normalization factor for each acquisition timepoint. 

cytoNorm <- function(ref_bead_foldername, 
                     bead_foldername, 
                     bead_foldername2 = NULL,
                     plot_norm = NULL) { 
  
  # read in ref beads 
  beads.ref <- read.csv(here::here(ref_bead_foldername, "Beads.csv")) %>% 
    select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  
  # read in beads to be normalized
  beads.1 <- read.csv(here::here(bead_foldername, "Beads.csv")) %>% 
    select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  
  # this is only run if there is an additional bead dataset to be normalized
  if(!is.null(bead_foldername2)){
    beads.2 <- read.csv(here::here(bead_foldername2, "Beads.csv")) %>%  
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
  
  # generate histograms of normalized and unnormalized data
  if (isTRUE(plot_norm)) {
    
    # get number of columns for each dataframe 
    len <- length(norm.fact) - 2
    norm.len <- len - 1 + length(norm.fact)
    
    # join bead dataframes 
    mat <- rbind(beads.ref %>% mutate("Folder" = ref_bead_foldername)) %>%
      rbind(beads.1 %>%  mutate(Folder = bead_foldername)) %>% 
      rbind(beads.2 %>%  mutate(Folder = bead_foldername2))
    
    # join normalization vector with matrix 
    mat <- inner_join(mat, norm.fact[,c(1:len,length(norm.fact))], by = "Folder")
    
    # multiply unnormalized data by normalization factor
    mat.norm <- mat[1:len]*mat[(length(norm.fact)):(norm.len)]
    mat.norm$Folder <- mat$Folder
    
    mat.plot <- mat[,c(1:length(norm.fact))] %>% 
      mutate(dataset = "unnormalized") %>% 
      full_join(mat.norm %>% mutate(dataset = "normalized")) %>% 
      mutate(plot = paste0(dataset,"_",Folder))
    
    colNames <- names(mat.norm[1:len])
    
    for (i in colNames) {
      
      p <- ggplot(mat.plot, aes_string(x = i, y = "plot", fill = "Folder", color = "Folder")) +
        geom_density_ridges2(alpha = 0.5, 
                             show.legend = FALSE,
                             quantile_lines=TRUE,
                             quantiles=2) + 
        theme_minimal() + 
        theme(panel.grid=element_blank(),
              axis.title.y = element_blank(),
              axis.text=element_text(size=11),
              axis.text.x=element_blank())
      print(p)
    }
  }
  
}
