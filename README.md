
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scrape-property-profiles

<!-- badges: start -->

<!-- badges: end -->

This repo contains codes that scrape house prices from
<https://www.auhouseprices.com>. Please use the website responsibly by
setting the number of crawlers low and around delay between each call.

**Dependencies**

  - Rcrawler: for crawling the website to extract house price data
  - data.table: for processing extracted data
  - furrr: for parallelizing operations
  - parallel
  - rvest
  - magrittr: piping of functions

**R/**

  - extract-rent.R crawls listings of rental properties
  - extract-sold.R crawls listings of sold properties
  - process-data.R processes the extracted data and save it to a csv
    file “extracted\_data.csv”.
