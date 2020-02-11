library(Rcrawler)
library(data.table)
library(magrittr)
library(furrr)
library(rvest)

# read postal address data of Victoria, Australia.
poa_dt <- data.table::fread("data/victoria_postal_codes.csv")

cl <- parallel::makeCluster(2)
future::plan(cluster, workers = cl)

res_rent <- furrr::future_map(poa_dt[['postcode']], ~ {
  # we first check if the postal code exists
  # change the state abbrev for other states eg: NSW instead of VIC for New South Wales.
  url <- glue::glue("https://www.auhouseprices.com/sold/list/VIC/{.x}")
  page <- xml2::read_html(url)
  page_txt <- html_text(page)
  if (grepl("No Property Found in", x = page_txt)) {
    return(NULL)
  }
  
  # if POA exists then proceed to extract listings
  # 1:10 means extract only the first 10 pages
  for (i in 1:10) {
    Rcrawler(
      Website = paste0("https://www.auhouseprices.com/sold/list/VIC/", .x, "/1/", i),
      no_cores = 1,
      no_conn = 1,
      # save the extracted data at "./auhouseprices/sold/"
      DIR = here::here("auhouseprices", "sold", .x, i),
      crawlUrlfilter = c("sold/view/VIC", "rent/view/VIC/"),
      ExtractCSSPat = c(
        "div[class='col-md-8'] h2",
        "div[class='col-md-8'] h5",
        "div[class='col-md-8'] ul[class='list-unstyled']",
        "div [class='col-md-4'] ul[class='list-unstyled'] li",
        "div[class='col-md-4 col-sm-5']  > div:nth-child(2) ul",
        "div[class='col-md-4 col-sm-5'] div:nth-child(3) ul[class='list-group sidebar-nav-v1']"
      ),
      PatternsName = c(
        "address", "price_info", "property_info", "structural_info", "distance_to_nearest_pt", "distance_to_nearest_schools"
      ),
      ManyPerPattern = T,
      KeywordsFilter = c("Property Detail"),
      MaxDepth = 1
    )
  }
  return(TRUE)
})

parallel::stopCluster(cl)
