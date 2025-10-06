#' Scrape Historical MLB Vegas Win Totals
#'
#' Retrieves preseason MLB win total over/under lines from SportsOddsHistory
#' for the 1990s through the current decade (1990–2020s).
#'
#' The function scrapes tables from SportsOddsHistory, cleans the data,
#' extracts the preseason win totals, and returns a tidy data frame
#' with team names, years, and preseason expectations.
#'
#' @details
#' - For 1990s–2010s: scrapes decade-specific pages.
#' - For 2020s: scrapes the current decade's page.
#' - Uses `rvest`, `stringr`, `tidyr`, and `dplyr` internally.
#' - Filters out erroneous preseason values (<= 10).
#'
#' @return A tibble with the following columns:
#' \describe{
#'   \item{team}{Team name (character).}
#'   \item{year}{Season year (numeric).}
#'   \item{preseason}{Vegas preseason win total (numeric).}
#' }
#'
#' @examples
#' \dontrun{
#' vegas_wins <- get_vegas_wins()
#' head(vegas_wins)
#' }
#'
#' @importFrom rvest read_html html_nodes html_table
#' @importFrom janitor clean_names
#' @importFrom tidyr pivot_longer
#' @importFrom stringr str_remove_all str_extract_all
#' @importFrom purrr map_dbl reduce
#' @importFrom dplyr mutate if_else select arrange filter
#'
#' @export
get_vegas_wins <- function(){
  #function to scrape previous decades
  get_overunder_decade <- function(decade){
    #url based on decade input
      url <- paste0("https://www.sportsoddshistory.com/mlb-regular-season-win-total-results-by-team-",
                    decade,"s/")
    #rvest the html
    page <- rvest::read_html(url)

    #get all tables on the page
    tables <- page |>
      #all tables
      rvest::html_nodes("table") |>
      #convert to table
      rvest::html_table(fill = TRUE)

    #get first table
    raw_tbl <- tables[[1]] |>
      janitor::clean_names()


    return(raw_tbl |>
          tidyr::pivot_longer(-team, names_to = "yr_col", values_to = "raw") |>
        #yr_col looks like "x10", "x11", "x90", etc. Convert to full year robustly.
          dplyr::mutate(y2   = as.integer(stringr::str_remove_all(yr_col, "\\D")),
                        year = dplyr::if_else(y2 >= 90, 1900 + y2, 2000 + y2)) |>
        #extract only preseason win total from cell
          dplyr::mutate(nums = stringr::str_extract_all(raw, "\\d+(?:\\.\\d+)?"),
                        preseason = purrr::map_dbl(nums, ~ if (length(.x) >= 1) as.numeric(.x[1]) else NA_real_)) |>
          #select desired values
          dplyr::select(team, year, preseason) |>
          #arrange for fun
          dplyr::arrange(team, year))
  }
  #run for 1990s, 2000s, 2010s,
  x19902019<-purrr::reduce(lapply(c(1990, 2000, 2010), get_overunder_decade), rbind) |>
    #convert preseason win total to numeric
    dplyr::mutate(preseason=as.numeric(preseason),
                  year=as.numeric(year)) |>
    #get rid of erroneous values
    dplyr::filter(preseason>10)
  #function to scrape current decade
  get_overunder_2020 <- function(){
    #url for current site
    url <- paste0("https://www.sportsoddshistory.com/mlb-regular-season-win-total-results-by-team/")
    #rvest the url
    page <- rvest::read_html(url)

    #get ALL tables on the page
    tables <- page |>
      #get tables
      rvest::html_nodes("table") |>
      #convert to table
      rvest::html_table(fill = TRUE)

    #get first table
    raw_tbl <- tables[[1]] |>
      janitor::clean_names()


    return(raw_tbl |>
             tidyr::pivot_longer(-team, names_to = "yr_col", values_to = "raw") |>
             # yr_col looks like "x10", "x11", "x90", etc. Convert to full year robustly.
             dplyr::mutate(y2   = as.integer(stringr::str_remove_all(yr_col, "\\D")),
                           #simple equation to convert 90s or 2000s
                          year = dplyr::if_else(y2 >= 90, 1900 + y2, 2000 + y2)) |>
           # extract all numbers from each cell; first = preseason line, last = actual win
             dplyr::mutate(nums= stringr::str_extract_all(raw, "\\d+(?:\\.\\d+)?"),
                           preseason = purrr::map_dbl(nums, ~ if (length(.x) >= 1) as.numeric(.x[1]) else NA_real_)) |>
            dplyr::select(team, year, preseason) |>
            dplyr::arrange(team, year))
}
  #run function for 2020
  x2020s <- get_overunder_2020() |>
    #convert preseason and year values to numeric
    dplyr::mutate(year=as.numeric(year),
                preseason=as.numeric(preseason)) |>
    #get rid of non preseason values
    dplyr::filter(preseason>10, year>=2020,
                team!="Team")
  #create output data
  output_data <- rbind(x19902019, x2020s)
  vegas_translations <- read_csv("inst/extdata/vegas_translations.csv")
  #add in proper team labeling
  output_data <- output_data |>
    dplyr::left_join(vegas_translations, by=c("team" = "vegas_name",
                                              "year" = "season"))
  #remove erroneous column
  output_data$team <- NULL

  #return output data
  return(output_data)
}

