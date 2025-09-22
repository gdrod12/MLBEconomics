#' Scrape historical and contemporary ballpark data
#'
#' This function scrapes ballpark information from
#' \url{https://www.seamheads.com/ballparks/}. It retrieves inactive
#' ballpark capacity data across teams as well as contemporary
#' (active) ballpark data for a given year, and merges them into a single
#' dataset.
#'
#' @param year Integer. The season year for which to scrape contemporary
#'   ballpark data (e.g., `2024`).
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{Ballpark Name}{Character. Name of the ballpark.}
#'   \item{Capacity}{Character/numeric. Reported seating capacity.}
#'   \item{team_id}{Character. Team identifier extracted from the seamheads URL.}
#'   \item{Year}{Integer. Year associated with the ballpark entry.}
#' }
#'
#' @details
#' The function performs two scrapes:
#' \itemize{
#'   \item Inactive ballparks: visits each historical team link from the
#'   seamheads ballparks index and extracts ballpark capacity data.
#'   \item Active ballparks: retrieves the main ballpark table for the
#'   specified year.
#' }
#' The two datasets are then combined and returned.
#'
#'
#' @examples
#' \dontrun{
#' # Scrape ballpark data for 2024
#' bp_data <- scrape_old_ballparks(2024)
#' head(bp_data)
#' }
#'
#' @export


scrape_old_ballparks <- function(year){
  #get URL for old ballparks
  {url <- "https://www.seamheads.com/ballparks/index.php"
    #read page
    page <- rvest::read_html(url)

    #xxtract the table text (for ballpark names etc.)
    tbl <- page %>%
      rvest::html_node("table") |>
      rvest::html_table(fill = TRUE)

    #xxtract only the hrefs from the FIRST column
    hrefs <- page %>%
      rvest::html_node("table") |>
      rvest::html_nodes("tr td:first-child a") |>  # only <a> tags in first column
      rvest::html_attr("href")

    #add them to the table
    tbl$Link <- hrefs
    #get link for further scraping
    tbl$Link_full <- paste0("https://www.seamheads.com/ballparks/",
                            tbl$Link)}
    #initialize data frame for inactive ballpark capacities
    inactive_capacity_data <- data.frame()
    #initialize for loop to scrape each ballpark
    for (row in 1:nrow(tbl)){
      #get url for specific ballpark page
      new_url <- tbl$Link_full[row]
      #read html
      new_page <- rvest::read_html(new_url)
      #extract the table text (for ballpark names etc.)
      tables <- new_page %>% rvest::html_nodes("table")
      #get the main table
      main_table <- tables[[2]] %>% rvest::html_table(fill = TRUE)
      #get valid colnames
      colnames(main_table) <- make.unique(as.character(unlist(main_table[1, ])))
      #remove first row
      main_table <- main_table[-1, ]
      #get team id for labeling
      team_id <- substr(tbl$Link[row], nchar(tbl$Link[row])-4, nchar(tbl$Link[row]))
      #append teamid
      main_table$team_id <- team_id
      #bind to larger data
      inactive_capacity_data<-rbind(inactive_capacity_data, main_table)
    }

    #Get contemporary stadium data, in this case 2024.
    {url <- paste0("https://www.seamheads.com/ballparks/year.php?Year=", year)
      #read html
      page <- rvest::read_html(url)

      #get all tables
      tables <- page %>% rvest::html_nodes("table")
      #the main ballpark table is usually the second one
      tbl <- tables[[2]] %>% rvest::html_table(fill = TRUE)
      #create valid colnames
      colnames(tbl) <- make.unique(as.character(unlist(tbl[1, ])))
      #change table
      tbl <- tbl[-1, ]
      #extract the hrefs from the first column, scoped to the same table
      hrefs <- tables[[2]] |>
        rvest::html_nodes("tr td:first-child a") |>
        rvest::html_attr("href")

      #add them to the data frame
      tbl$Link <- hrefs
    }
    #edit tables for proper binding
    inactive_capacity_data$Comment <- NULL
    tbl$team_id <- substr(tbl$Link, nchar(tbl$Link)-4, nchar(tbl$Link))
    tbl$Link <- NULL
    #bind inactive and active ballparks together
    final_data <- rbind(inactive_capacity_data |>
                dplyr::reframe(`Ballpark Name`, Capacity, team_id, Year), tbl |>
                dplyr::reframe(`Ballpark Name`, Capacity, team_id, Year=year))
  return(final_data)
}
