process_onthehouse_data <- function(in_dir, out_dir = NULL, n_cores = 1L) {
  checkmate::assert_directory_exists(in_dir, access = "r")
  checkmate::assert_directory_exists(out_dir, access = "rw")
  checkmate::assert_number(n_cores, na.ok = FALSE, lower = 1, upper = parallel::detectCores(), finite = T)
  
  extracted_data_files <- list.files(in_dir, all.files = T, pattern = "extracted_data.csv", full.names = T, recursive = T)
  
  if (n_cores > 1 & requireNamespace("furrr")) {
    cl <- parallel::makeCluster(n_cores)
    future::plan(future::cluster, workers = cl)
    
    combined_data <-
      furrr::future_map_dfr(extracted_data_files, ~ {
        data.table::fread(.x, header = FALSE)
      })
    
    parallel::stopCluster(cl)
  }
  else {
    if (n_cores > 1) {
      message("Needs the furrr package to run in parallel.")
    }
    combined_data <-
      purrr::map_dfr(extracted_data_files, ~ {
        data.table::fread(.x)
      })
  }
  
  data.table::fwrite(x = combined_data, file = fs::path(out_dir, "extracted_data.csv"))
  
  return(combined_data)
}

process_onthehouse_data(in_dir = "onthehouse-2", out_dir = "extracted-data", n_cores = 10)
