#' Load and combine ZiPS batter projection data
#'
#' @description
#' Reads multiple seasons of ZiPS batter projection CSV files from the package's
#' `inst/extdata/` directory, appends a `season` column, and returns a unified
#' dataset with key offensive and defensive metrics.
#'
#' @param end_year Integer. The final season (year) to include. Data are read
#' sequentially from 2010 through `end_year`, inclusive.
#'
#' @details
#' This function searches for CSV files named `zipsbatters{year}.csv` within
#' the package's installed `extdata/` directory. Each CSV is expected to contain
#' ZiPS projection data for that season's batters.
#'
#' For each year:
#' \enumerate{
#'   \item The CSV file is read using `readr::read_csv()`.
#'   \item A `season` column is added to denote the year.
#'   \item The data are combined across all years using `purrr::reduce()` and `rbind()`.
#'   \item A subset of relevant statistical columns is selected for output.
#' }
#'
#' @return
#' A `tibble` containing combined ZiPS batter projection data for all years from
#' 2010 through `end_year`. Includes the following columns:
#' \itemize{
#'   \item `Name` — Player name
#'   \item `PA` — Plate appearances
#'   \item `UBR`, `wSB`, `BsR` — Baserunning metrics
#'   \item `wRC+` — Weighted runs created plus
#'   \item `Fld`, `Off`, `Def` — Fielding, offensive, and defensive values
#'   \item `WAR` — Wins Above Replacement
#'   \item `NameASCII`, `PlayerId`, `MLBAMID` — Identifier fields
#'   \item `season` — Corresponding season year
#' }
#'
#' @examples
#' \dontrun{
#' # Load ZiPS batter projections through 2024
#' zips_data <- get_zips_batters(2024)
#' dplyr::glimpse(zips_data)
#' }
#'
#' @seealso [readr::read_csv()], [system.file()], [purrr::reduce()], [dplyr::select()]
#'
get_zips_batters <- function(end_year) {
  read_data <- function(year) {
    filename <- system.file("extdata", paste0("zipsbatters", year, ".csv"), package = "MLBEconomics")
    new_data <- readr::read_csv(filename)
    new_data$season <- year
    new_data
  }
  purrr::reduce(lapply(2010:end_year, read_data), rbind) |>
    dplyr::select(Name, PA, UBR, wSB, BsR, `wRC+`, Fld, Off, Def, WAR,
                  NameASCII, PlayerId, MLBAMID, season)
}


