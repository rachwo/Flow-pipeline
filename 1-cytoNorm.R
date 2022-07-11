# this function calculates a per-channel normalization factor for each acquisition timepoint 
# and (optionally) generates histograms of normalized and unnormalized data.

cytoNorm <- function(ref_bead_foldername, 
                     plot_norm = NULL,
                     exclude = NULL) { 
  
  # add list of parameters to be removed to the environment 
  assign(x = "removed", value = exclude, envir = parent.frame())
  
  # read in all other files that are called "Beads.csv" 
  file_list <- list.files(path = ".", 
                          pattern = "Beads.csv", 
                          recursive = T, 
                          full.names = FALSE)
  
  # add column indicating original folder name
  csv_filename <- function(filename) {
    ret <- read.csv(here::here(filename))
    ret$Folder <- sub('/.*', '', filename)
    ret
  }
  
  # remove non-fluorescent and (optionally) specified parameters
  mat <- plyr::ldply(file_list, csv_filename) %>% 
    select(-contains(c("FSC", "SSC", "Time", 
                       "GFP","DAPI","Live", 
                       "Viability", exclude)))
  
  print("The folders containing your Beads.csv files include:")
  print(unique(mat$Folder))

  # calculate median for each channel
  med <- mat %>% 
    group_by(Folder) %>% 
    select(where(is.numeric)) %>% 
    dplyr::summarise(across(everything(), median)) %>% 
    ungroup() %>% 
    as.data.frame()
  
  # calculate normalization factor 
  ref.beads <- subset(med, Folder == ref_bead_foldername)
  norm.fact <- ref.beads[, -1][col(med)]/med[, -1] 
  norm.fact$Folder <- med$Folder
  
  # export normalization factors to the environment
  assign(x = "norm.fact", value = norm.fact, envir = parent.frame())
  
  # generate histograms of normalized and unnormalized data
  if (isTRUE(plot_norm)) {
    
    # get number of columns for each dataframe 
    len <- length(norm.fact) - 1
    norm.len <- len + length(mat)
    
    # join normalization vector with matrix 
    mat <- inner_join(mat, norm.fact, by = "Folder", suffix = c("", ".med"))
    
    # multiply unnormalized data by normalization factor
    mat.norm <- mat[1:len] * mat[(len + 2):(norm.len)]
    mat.norm$Folder <- mat$Folder
    
    mat.plot <- mat[, c(1:length(norm.fact))] %>% 
      mutate(dataset = "unnormalized") %>% 
      full_join(mat.norm %>% mutate(dataset = "normalized")) %>% 
      mutate(plot = paste0(dataset, "_", Folder))
    
    colNames <- names(mat.norm[1:len])
    
    for (i in colNames) {
      
      p <- ggplot(mat.plot, aes_string(x = i, 
                                       y = "plot", 
                                       fill = "Folder", 
                                       color = "Folder")) +
        geom_density_ridges2(alpha = 0.5, 
                             show.legend = FALSE,
                             quantile_lines = TRUE,
                             quantiles = 2) + 
        theme_minimal() + 
        theme(panel.grid = element_blank(),
              axis.title.y = element_blank(),
              axis.text = element_text(size=11),
              axis.text.x = element_blank())
      print(p)
      
    }
  }
}
