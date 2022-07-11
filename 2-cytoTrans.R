# read in flow files and perform normalization and arcsinh transformation

cytoTrans <- function(normalize = NULL,
                      plot_norm = NULL,
                      exclude = NULL) {
  
  # create list of flowjo scale files from target directory (exclude bead files)
  file_list <- list.files(path = ".", pattern = "*.csv", recursive = T, full.names = FALSE) %>% 
    stringr::str_subset(., "Beads.csv", negate = T)
  
  # add column indicating original file name
  csv_filename <- function(filename) {
    ret <- read.csv(here::here(filename))
    sample <- sub('.csv*', '', filename)
    ret$Well <- sub('.*/', '', filename)
    ret$Folder <- sub('/.*', '', filename)
    ret
  }
  
  mat.full <- plyr::ldply(file_list, csv_filename)
  
  # remove unwanted channels (include channels already removed at the normalization step, if applicable)
  if(!is.null(removed) == TRUE) {
    removed <- removed
  }
  
  mat <- mat.full %>% select(-contains(c("FSC","SSC","Time","GFP","DAPI","Live","Viability", exclude, removed)))
  
  # define transformation
  asinhtransform <- flowCore::arcsinhTransform(a = 0, b = 1/150)
  
  # perform per-channel normalization
  if (isTRUE(normalize)) {
    
    # double check that cytoNorm was run successfully
    if (exists("norm.fact") != TRUE) {
      print("Error: Can't perform normalization unless cytoNorm has been run. Please run cytoNorm first.")
    }
    
    # get number of columns for each dataframe 
    len <- length(norm.fact) - 1
    norm.len <- len + length(norm.fact)
    
    # join normalization vector with matrix 
    mat <- inner_join(mat, norm.fact[, c(1:len,length(norm.fact))], by = "Folder", suffix = c("",".norm"))
    
    # multiply unnormalized data by normalization factor
    mat.norm <- mat[1:len] * mat[(length(norm.fact) + 2):(norm.len + 1)]
    mat.norm$Well <- mat$Well
    mat.norm$Folder <- mat$Folder
    
    # generate histograms of normalized and unnormalized data
    if (isTRUE(plot_norm)) {
      
      mat.plot <- mat[, c(1:length(norm.fact) + 1)] %>% 
        mutate(dataset = "unnormalized") %>% 
        full_join(mat.norm %>% mutate(dataset = "normalized")) %>% 
        mutate(plot = paste0(Folder, "_", Well, "_", dataset))
      
      colNames <- names(mat.norm[1:len])
      
      for (i in colNames) {
        
        mat.plot[i] <- asinhtransform(mat.plot[i])  
        p <- ggplot(mat.plot, aes_string(x = i, y = "plot", fill = "Folder", color = "Folder")) +
          geom_density_ridges2(alpha = 0.5, 
                               show.legend = FALSE,
                               quantile_lines = TRUE,
                               quantiles = 2) + 
          theme_minimal() + 
          theme(panel.grid = element_blank(),
                axis.title.y = element_blank(),
                axis.text = element_text(size = 11),
                axis.text.x = element_blank())
        print(p)
      }
    }
    
    mat <- mat.norm
    
    # perform arcsinh transformation
    mat.ast <- mat %>%
      select(-c("Well", "Folder")) %>% 
      asinhtransform() %>% 
      mutate(Well = mat$Well) %>% 
      mutate(Folder = mat$Folder) %>% 
      mutate(plot = paste0(Folder, "_", Well))
    
    # export dataframe to envir 
    assign(x = "matrix", value = mat.ast, envir = parent.frame())
    
  }
  
  # prevent user from plotting normalized results if normalization is not specified
  else if (isTRUE(plot_norm) && (isFALSE(normalize) | is.null(normalize))) {
    print("Error: can't plot normalization results if normalize is not set to TRUE. Do you want to normalize the data?")
  }
  
  else {
    
    # perform arcsinh transformation
    mat.ast <- mat %>%
      select(-c("Well", "Folder")) %>% 
      asinhtransform() %>% 
      mutate(Well = mat$Well) %>% 
      mutate(Folder = mat$Folder) %>% 
      mutate(plot = paste0(Folder, "_", Well))
    
    # export dataframe to envir 
    assign(x = "matrix", value = mat.ast, envir = parent.frame()) 
    
  }
}
