# run UMAP using specified vector of neighbours to test
#   min_nn = minimum number of neighbours 
#   max_nn = maximum number of neighbours 
#   interval = interval to increase between min_nn and max_nn 
#   downsample = number of events to downsample on (based on unique sample ID)
#   output: UMAP plots in new folder ("Neighbour_plots) and downsampled matrix ("matrix.down")

cytoUMAP <- function(min_nn, 
                     max_nn, 
                     interval, 
                     min_dist, 
                     downsample = NULL){
  
  # generate error messages
  if(min_nn < 2){
    print("ERROR: Minimum number of neighbours must be >=2")
  }
  
  if (min_dist <= 0) { 
    print("ERROR: Minimum distance must be >0")
  }
  
  if(max_nn < interval){
    print("ERROR: Interval must be smaller than maximum number of neighbours")
  }
  
  else if(min_nn >= 2 && max_nn > interval && min_dist > 0) {
    
    # get range of neighbours to test
    range <- seq(from = min_nn, to = max_nn, by = interval)
    
    # create directory to save plots 
    dir.create("Neighbour_plots")
    
    # downsample matrix (optional)
    if (!is.null(downsample)) {
      mat.down <- with(matrix, ave(matrix[,1], Well, FUN=function(x) {sample.int(length(x), replace = FALSE)}))
      matrix.d <- matrix[mat.down <= as.numeric(downsample),]
      
      assign(x = "matrix.down", value = matrix.d, envir = parent.frame())
    }
    
    else if (is.null(downsample)){
      matrix.d <- matrix
    }
    
    # parallellize
    myCluster <- makeCluster(10, type = "FORK") 
    registerDoParallel(myCluster)
    
    # run umap
    umap.out <- foreach(x = range) %dopar% umap(matrix.d, n_neighbors = x, min_dist = min_dist, ret_model=TRUE, verbose=T)
    
    # generate plots 
    for (i in 1:length(umap.out)){
      p = ggplot(data=as.data.frame(umap.out[[i]]$embedding), aes(x=V1, y=V2)) +
        geom_bin2d(bins=256) + 
        scale_fill_viridis_c(option = "A", trans = "sqrt") + 
        scale_x_continuous(expand = c(0.1,0)) + 
        scale_y_continuous(expand = c(0.1,0)) +
        labs(x = "UMAP-1", 
             y = "UMAP-2") + 
        coord_fixed() + 
        theme_minimal() + 
        theme(panel.grid.major=element_blank(),
              panel.grid.minor=element_blank()) + 
        ggtitle(umap.out[[i]][["n_neighbors"]])
      
      ggsave(p, 
             path = "./Neighbour_plots",
             filename = paste("UMAP",umap.out[[i]][["n_neighbors"]],"neighbours.png"), width=14, height=10, units="cm")
    }
    
    on.exit(stopCluster(myCluster))
  }
}
