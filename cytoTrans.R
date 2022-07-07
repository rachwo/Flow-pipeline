# read in flow files and perform normalization and arcsinh transformation

cytoTrans <- function(ref_flow_foldername,
                      flow_foldername_1 = NULL,
                      flow_foldername_2 = NULL,
                      normalize = NULL,
                      plot_norm = NULL) {
  
  # create list of flowjo scale files from target directory (exclude bead files)
  file_list <- list.files(path = ".", pattern = "*.csv", recursive = T, full.names = FALSE) %>% 
    stringr::str_subset(., "Beads", negate = T)
  
  # add column indicating original file name
  csv_filename <- function(filename){
    ret <- read.csv(here(filename))
    sample <- sub('.csv*', '', filename)
    ret$Well <- sub('.*/', '', filename)
    ret$Folder <- sub('/.*', '', filename)
    ret
  }
  
  mat.full <- plyr::ldply(file_list, csv_filename)

  # remove unwanted channels
  mat <- mat.full %>% select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live")))
  
  if (isTRUE(normalize)) {
  # join normalization vector with matrix 
  mat <- inner_join(mat, norm.fact[,c(1:14,16)], by = "Folder")
  
  # multiply unnormalized data by normalization factor
  len <- length(norm.fact) - 2
  norm.len <- len + length(norm.fact)
  
  mat.norm <- mat[1:len]*mat[(length(norm.fact)+1):(norm.len)]
  #mat.norm <- mat[1:14]*mat[17:30]
  mat.norm$Well <- mat$Well
  mat.norm$Folder <- mat$Folder
  
  if (isTRUE(plot_norm)) {
  
  mat.plot <- mat[,c(1:16)] %>% 
    mutate(dataset = "unnormalized") %>% 
    full_join(mat.norm %>% mutate(dataset = "normalized")) %>% 
    mutate(plot = paste0(dataset,"_",Well))
  
  colNames <- names(mat.norm[1:14])
    
  for (i in colNames) {
  p <- ggplot(mat.plot, aes_string(x = i, y = "plot", fill = "Well", color = "Well")) +
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
  
  mat <- mat.norm
  
  # perform arcsinh transformation
  asinhtransform <- flowCore::arcsinhTransform(a = 0, b = 1/150)
  mat.ast <- mat %>%
    select(-c("Well", "Folder")) %>% 
    asinhtransform() %>% 
    mutate(Well = mat$Well) %>% 
    mutate(Folder = mat$Folder) %>% 
    mutate(plot = paste0(Folder,"_",Well))
  
  # export dataframe to envir 
  assign(x = "matrix", value = mat.ast, envir = parent.frame())
  
  }
  
  # prevent user from plotting normalized results if normalization is not specified
  else if (isTRUE(plot_norm) && (isFALSE(normalize) | is.null(normalize))) {
    
    print("Error: can't plot normalization results if normalize is not set to TRUE. Do you want to normalize the data?")
    
  }
  
  else {
    
    # perform arcsinh transformation
    asinhtransform <- flowCore::arcsinhTransform(a = 0, b = 1/150)
    mat.ast <- mat %>%
      select(-c("Well", "Folder")) %>% 
      asinhtransform() %>% 
      mutate(Well = mat$Well) %>% 
      mutate(Folder = mat$Folder) %>% 
      mutate(plot = paste0(Folder,"_",Well))
    
    # export dataframe to envir 
    assign(x = "matrix", value = mat.ast, envir = parent.frame()) 
    
  }
}
